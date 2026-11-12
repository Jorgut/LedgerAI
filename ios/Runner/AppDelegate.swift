import AVFoundation
import CloudKit
import Flutter
import ImageIO
import Speech
import UIKit
import Vision

/// 衡账 LedgerAI 的 iOS 原生入口。
///
/// 所有原生通道都写在本文档内（不新增 Swift 文件，避免修改 pbxproj）。
/// 实现约束：
/// - 100% 离线：OCR 用 Vision 本地模型，语音用 SFSpeechRecognizer 设备端识别。
/// - 图片只读取 image_picker 提供的临时文件，不复制、不写入；音频只以内存
///   buffer 形式喂给识别器，不落盘、不上传。
/// - 模拟器没有麦克风/设备端模型：`isAvailable` 返回 false，错误通过事件
///   以中文提示给出，不崩溃。
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let ocrHandler = LedgerAIOcrHandler()
  private let speechHandler = LedgerAISpeechHandler()
  private let cloudKitHandler = LedgerAICloudKitHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerLedgerAIChannels(with: engineBridge)
  }

  /// 用隐式引擎的 pluginRegistry 拿 messenger，注册应用级通道。
  private func registerLedgerAIChannels(with engineBridge: FlutterImplicitEngineBridge) {
    let registry = engineBridge.pluginRegistry
    let registrar = registry.registrar(forPlugin: "LedgerAIInputChannels")
    let messenger = registrar?.messenger() ?? engineBridge.applicationRegistrar.messenger()

    let ocrChannel = FlutterMethodChannel(
      name: "com.archintera.ledgerai/ocr",
      binaryMessenger: messenger
    )
    ocrChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "engine_detached", message: "应用正在退出", details: nil))
        return
      }
      self.ocrHandler.handle(call, result: result)
    }

    let speechChannel = FlutterMethodChannel(
      name: "com.archintera.ledgerai/speech",
      binaryMessenger: messenger
    )
    speechChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "engine_detached", message: "应用正在退出", details: nil))
        return
      }
      self.speechHandler.handle(call, result: result)
    }

    let speechEvents = FlutterEventChannel(
      name: "com.archintera.ledgerai/speech_events",
      binaryMessenger: messenger
    )
    speechEvents.setStreamHandler(speechHandler)

    let cloudChannel = FlutterMethodChannel(
      name: "com.archintera.ledgerai/cloudkit",
      binaryMessenger: messenger
    )
    cloudChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "engine_detached", message: "应用正在退出", details: nil))
        return
      }
      self.cloudKitHandler.handle(call, result: result)
    }
  }
}

// MARK: - OCR（Vision 设备端文字识别）

private final class LedgerAIOcrHandler {
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "recognizeText" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let arguments = call.arguments as? [String: Any],
      let rawPath = arguments["path"] as? String
    else {
      result(FlutterError(code: "invalid_arguments", message: "缺少图片路径", details: nil))
      return
    }
    let path = rawPath.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !path.isEmpty else {
      result(FlutterError(code: "invalid_arguments", message: "图片路径为空", details: nil))
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let outcome = LedgerAIOcrHandler.recognize(path: path)
      DispatchQueue.main.async {
        result(outcome)
      }
    }
  }

  /// 成功返回 `["text": String, "lines": [String]]`，失败返回 [FlutterError]。
  private static func recognize(path: String) -> Any {
    guard FileManager.default.fileExists(atPath: path) else {
      return FlutterError(code: "file_not_found", message: "找不到要识别的图片", details: nil)
    }
    guard let image = UIImage(contentsOfFile: path), let cgImage = image.cgImage else {
      return FlutterError(
        code: "image_unreadable",
        message: "无法读取图片，请重新拍照或从相册选择",
        details: nil
      )
    }

    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = ["zh-Hans", "en-US"]
    if #available(iOS 16.0, *) {
      // 已经显式指定语言，关闭自动探测，识别更稳定。
      request.automaticallyDetectsLanguage = false
    }

    let handler = VNImageRequestHandler(
      cgImage: cgImage,
      orientation: cgImageOrientation(from: image.imageOrientation),
      options: [:]
    )
    do {
      try handler.perform([request])
    } catch {
      return FlutterError(
        code: "ocr_failed",
        message: "文字识别失败，请重试或手动输入",
        details: error.localizedDescription
      )
    }

    let observations = request.results ?? []
    let lines = orderedLines(from: observations)
    let text = lines.joined(separator: "\n")
    return ["text": text, "lines": lines]
  }

  /// Vision 的 boundingBox 原点在左下角；按「先上后下、先左后右」排序，
  /// 同一视觉行里被拆开的观测合并成一个空格分隔的行，便于 Dart 侧解析。
  private static func orderedLines(from observations: [VNRecognizedTextObservation]) -> [String] {
    var items: [(text: String, top: CGFloat, left: CGFloat)] = []
    items.reserveCapacity(observations.count)
    for observation in observations {
      guard let candidate = observation.topCandidates(1).first else { continue }
      let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !text.isEmpty else { continue }
      let box = observation.boundingBox
      items.append((text: text, top: box.maxY, left: box.minX))
    }
    items.sort { lhs, rhs in
      if lhs.top != rhs.top { return lhs.top > rhs.top }
      return lhs.left < rhs.left
    }

    var lines: [String] = []
    var rowParts: [String] = []
    var rowTop: CGFloat = 0
    for item in items {
      if rowParts.isEmpty {
        rowTop = item.top
        rowParts = [item.text]
      } else if abs(item.top - rowTop) <= 0.012 {
        rowParts.append(item.text)
      } else {
        lines.append(rowParts.joined(separator: " "))
        rowTop = item.top
        rowParts = [item.text]
      }
    }
    if !rowParts.isEmpty {
      lines.append(rowParts.joined(separator: " "))
    }
    return lines
  }
}

private func cgImageOrientation(from orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
  switch orientation {
  case .up:
    return .up
  case .down:
    return .down
  case .left:
    return .left
  case .right:
    return .right
  case .upMirrored:
    return .upMirrored
  case .downMirrored:
    return .downMirrored
  case .leftMirrored:
    return .leftMirrored
  case .rightMirrored:
    return .rightMirrored
  default:
    return .up
  }
}

// MARK: - 语音（SFSpeechRecognizer，强制设备端识别）

private final class LedgerAISpeechHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  private var recognizer: SFSpeechRecognizer?
  private var audioEngine: AVAudioEngine?
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?

  private var tapInstalled = false
  private var isListening = false
  private var isStopping = false
  private var suppressEvents = false
  private var latestTranscript = ""
  private var stopTimeout: DispatchWorkItem?
  private var lastStartError: String?

  /// 会话代号：每次启动/收尾都自增，旧回调直接丢弃，避免泄漏与串话。
  private var generation = 0

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    // 新的订阅重新允许推送事件（上一次 onCancel/取消的静默到此结束）。
    suppressEvents = false
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.suppressEvents = true
      self.teardownSession()
    }
    return nil
  }

  // MARK: MethodChannel

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      result(isOnDeviceRecognitionAvailable())
    case "start":
      let arguments = call.arguments as? [String: Any]
      let localeId = (arguments?["localeId"] as? String) ?? "zh-CN"
      start(localeId: localeId, result: result)
    case "stop":
      stopRecognition()
      result(nil)
    case "cancel":
      cancelRecognition()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func isOnDeviceRecognitionAvailable() -> Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) else {
      return false
    }
    // 只看「设备本身是否支持离线识别」：isAvailable 受网络/Siri 开关影响，
    // 首次启动时可能还是 false，会误挡住后面的授权流程。
    return recognizer.supportsOnDeviceRecognition
    #endif
  }

  private func start(localeId: String, result: @escaping FlutterResult) {
    // 每次 start 都恢复事件推送：上一次 cancel 的静默只作用于那一次会话。
    suppressEvents = false
    #if targetEnvironment(simulator)
    emitError("模拟器不支持设备端语音识别，请使用真机，或改用手动输入。")
    result(false)
    #else
    let localeIdentifier = localeId.replacingOccurrences(of: "_", with: "-")
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)) else {
      emitError("暂不支持该语言的语音识别，请改用手动输入。")
      result(false)
      return
    }
    guard recognizer.supportsOnDeviceRecognition else {
      emitError("当前设备没有离线语音模型，请改用手动输入。")
      result(false)
      return
    }
    if isListening || isStopping {
      teardownSession()
    }
    requestPermissions { [weak self] granted, message in
      guard let self = self else {
        result(false)
        return
      }
      guard granted else {
        self.emitError(message ?? "没有获得麦克风和语音识别权限，请改用手动输入。")
        result(false)
        return
      }
      let started = self.beginRecognition(
        localeIdentifier: localeIdentifier,
        recognizer: recognizer
      )
      if !started {
        self.emitError(self.lastStartError ?? "语音识别启动失败，请改用手动输入。")
      }
      result(started)
    }
    #endif
  }

  // MARK: 权限

  private func requestPermissions(completion: @escaping (Bool, String?) -> Void) {
    requestMicrophonePermission { microphoneGranted in
      guard microphoneGranted else {
        completion(false, "没有麦克风权限，请在系统设置中允许「衡账」使用麦克风。")
        return
      }
      SFSpeechRecognizer.requestAuthorization { status in
        DispatchQueue.main.async {
          switch status {
          case .authorized:
            completion(true, nil)
          case .denied:
            completion(false, "语音识别权限被拒绝，请在系统设置中开启「语音识别」。")
          case .restricted:
            completion(false, "当前设备限制了语音识别，请改用手动输入。")
          case .notDetermined:
            completion(false, "尚未获得语音识别权限，请重试并允许授权。")
          @unknown default:
            completion(false, "语音识别权限状态异常，请改用手动输入。")
          }
        }
      }
    }
  }

  private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
    if #available(iOS 17.0, *) {
      AVAudioApplication.requestRecordPermission { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    } else {
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    }
  }

  // MARK: 启动 / 停止 / 取消

  private func beginRecognition(
    localeIdentifier: String,
    recognizer: SFSpeechRecognizer
  ) -> Bool {
    lastStartError = nil
    teardownSession()

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      lastStartError = "无法启用麦克风，请检查系统设置后重试。"
      return false
    }

    let engine = AVAudioEngine()
    let inputNode = engine.inputNode
    let recordingFormat = inputNode.inputFormat(forBus: 0)
    guard recordingFormat.sampleRate > 0, recordingFormat.channelCount > 0 else {
      deactivateAudioSession()
      lastStartError = "当前没有可用的麦克风输入，请改用手动输入。"
      return false
    }

    let request = SFSpeechAudioBufferRecognitionRequest()
    request.requiresOnDeviceRecognition = true
    request.shouldReportPartialResults = true
    if #available(iOS 16.0, *) {
      request.addsPunctuation = true
    }

    generation += 1
    let currentGeneration = generation

    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      // 只把内存 buffer 交给识别器：不落盘、不上传。
      request.append(buffer)
    }
    tapInstalled = true

    engine.prepare()
    do {
      try engine.start()
    } catch {
      if tapInstalled {
        inputNode.removeTap(onBus: 0)
        tapInstalled = false
      }
      deactivateAudioSession()
      lastStartError = "麦克风启动失败，请稍后重试。"
      return false
    }

    audioEngine = engine
    recognitionRequest = request
    self.recognizer = recognizer
    recognitionTask = recognizer.recognitionTask(with: request) { [weak self] taskResult, taskError in
      DispatchQueue.main.async {
        self?.handleRecognitionUpdate(
          generation: currentGeneration,
          result: taskResult,
          error: taskError
        )
      }
    }

    isListening = true
    isStopping = false
    suppressEvents = false
    latestTranscript = ""
    emitEvent(["type": "state", "state": "listening"])
    return true
  }

  private func stopRecognition() {
    guard isListening, !isStopping else { return }
    isStopping = true
    recognitionRequest?.endAudio()
    audioEngine?.stop()
    deactivateAudioSession()
    // 等系统把最终结果送回来；3 秒没等到就用已有的文字兜底收尾。
    let timeout = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      guard self.isListening || self.isStopping else { return }
      if !self.suppressEvents, !self.latestTranscript.isEmpty {
        self.emitEvent(["type": "final", "text": self.latestTranscript])
      }
      self.finishSession(emitIdle: true)
    }
    stopTimeout?.cancel()
    stopTimeout = timeout
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: timeout)
  }

  private func cancelRecognition() {
    suppressEvents = true
    stopTimeout?.cancel()
    stopTimeout = nil
    teardownSession()
    latestTranscript = ""
  }

  private func handleRecognitionUpdate(
    generation: Int,
    result: SFSpeechRecognitionResult?,
    error: Error?
  ) {
    guard generation == self.generation else { return }
    guard isListening || isStopping else { return }

    if let result = result {
      let text = result.bestTranscription.formattedString
      latestTranscript = text
      if result.isFinal {
        if !suppressEvents {
          emitEvent(["type": "final", "text": text])
        }
        finishSession(emitIdle: true)
        return
      }
      if isListening && !isStopping && !suppressEvents {
        emitEvent(["type": "partial", "text": text])
      }
    }

    if let error = error {
      if isStopping || suppressEvents {
        // 收尾阶段系统会返回「取消/结束」类错误，不是用户可见的失败。
        finishSession(emitIdle: !suppressEvents)
        return
      }
      emitError(message(for: error))
      finishSession(emitIdle: true)
    }
  }

  /// 结束会话：取消任务、移除 tap、停引擎、释放音频会话，不留资源。
  private func finishSession(emitIdle: Bool) {
    let shouldEmitIdle = (isListening || isStopping) && emitIdle && !suppressEvents
    teardownSession()
    if shouldEmitIdle {
      emitEvent(["type": "state", "state": "idle"])
    }
  }

  private func teardownSession() {
    stopTimeout?.cancel()
    stopTimeout = nil
    isListening = false
    isStopping = false
    generation += 1

    recognitionTask?.cancel()
    recognitionTask = nil
    recognitionRequest?.endAudio()
    recognitionRequest = nil

    if let engine = audioEngine {
      engine.stop()
      if tapInstalled {
        engine.inputNode.removeTap(onBus: 0)
        tapInstalled = false
      }
    }
    audioEngine = nil
    recognizer = nil
    deactivateAudioSession()
  }

  private func deactivateAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setActive(
        false,
        options: .notifyOthersOnDeactivation
      )
    } catch {
      // 音频会话可能已被系统回收，忽略即可。
    }
  }

  // MARK: 事件

  private func emitEvent(_ event: [String: Any]) {
    guard !suppressEvents else { return }
    guard let sink = eventSink else { return }
    if Thread.isMainThread {
      sink(event)
    } else {
      DispatchQueue.main.async { [weak self] in
        guard let self = self, !self.suppressEvents, let currentSink = self.eventSink else {
          return
        }
        currentSink(event)
      }
    }
  }

  private func emitError(_ message: String) {
    emitEvent(["type": "error", "message": message])
  }

  private func message(for error: Error) -> String {
    let nsError = error as NSError
    if nsError.domain == "kAFAssistantErrorDomain" {
      switch nsError.code {
      case 203:
        return "没有识别到语音内容，请靠近麦克风再说一次。"
      case 216:
        return "语音识别被中断，请重试或改用手动输入。"
      case 1110:
        return "没有识别到语音内容，请重试或改用手动输入。"
      default:
        break
      }
    }
    return "语音识别失败，请重试或改用手动输入。"
  }
}


// MARK: - iCloud 同步（CloudKit private database）

/// 数据只写入用户自己的 iCloud private database，开发者不接触。
/// 通道：com.archintera.ledgerai/cloudkit
/// - status: 账号/网络是否可用
/// - pull: 拉取全部 Txn（含墓碑），返回 records + deleted
/// - push: 全量上传本地 Txn + 删除墓碑
private final class LedgerAICloudKitHandler {
  private let container = CKContainer(identifier: "iCloud.com.archintera.ledgerai")
  private let zoneID = CKRecordZone.ID(
    zoneName: "LedgerZone",
    ownerName: CKCurrentUserDefaultName
  )
  private let recordType = "Txn"

  private var database: CKDatabase { container.privateCloudDatabase }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "status":
      accountStatus(result)
    case "pull":
      ensureZone { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          self.fail(error, result)
          return
        }
        self.fetchAllRecords(cursor: nil, collected: [], deleted: [], result: result)
      }
    case "push":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad_args", message: "同步参数不正确", details: nil))
        return
      }
      ensureZone { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          self.fail(error, result)
          return
        }
        self.push(args: args, result: result)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func accountStatus(_ result: @escaping FlutterResult) {
    container.accountStatus { status, error in
      DispatchQueue.main.async {
        if let error = error {
          result([
            "available": false,
            "message": self.message(for: error),
          ])
          return
        }
        switch status {
        case .available:
          result(["available": true, "message": "iCloud 已连接"])
        case .noAccount:
          result(["available": false, "message": "请先在系统设置中登录 iCloud"])
        case .restricted:
          result(["available": false, "message": "iCloud 被系统限制，无法同步"])
        case .couldNotDetermine:
          result(["available": false, "message": "无法确定 iCloud 状态，请稍后重试"])
        case .temporarilyUnavailable:
          result(["available": false, "message": "iCloud 暂时不可用，请稍后重试"])
        @unknown default:
          result(["available": false, "message": "iCloud 状态未知"])
        }
      }
    }
  }

  private func ensureZone(completion: @escaping (Error?) -> Void) {
    let zone = CKRecordZone(zoneID: zoneID)
    database.save(zone) { _, error in
      DispatchQueue.main.async { completion(error) }
    }
  }

  private func fetchAllRecords(
    cursor: CKQueryOperation.Cursor?,
    collected: [CKRecord],
    deleted: [CKRecord],
    result: @escaping FlutterResult
  ) {
    var all = collected
    var tombstones = deleted

    let operation: CKQueryOperation
    if let cursor = cursor {
      operation = CKQueryOperation(cursor: cursor)
    } else {
      let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
      operation = CKQueryOperation(query: query)
      operation.zoneID = zoneID
      operation.resultsLimit = 200
    }

    operation.recordFetchedBlock = { record in
      if record["deletedAt"] is Date {
        tombstones.append(record)
      } else {
        all.append(record)
      }
    }
    operation.queryCompletionBlock = { [weak self] nextCursor, error in
      guard let self = self else { return }
      if let error = error {
        DispatchQueue.main.async { self.fail(error, result) }
        return
      }
      if let nextCursor = nextCursor {
        self.fetchAllRecords(
          cursor: nextCursor,
          collected: all,
          deleted: tombstones,
          result: result
        )
        return
      }
      DispatchQueue.main.async {
        result([
          "records": all.compactMap { self.encode($0) },
          "deleted": tombstones.compactMap { record -> [String: Any]? in
            guard let at = record["deletedAt"] as? Date else { return nil }
            return [
              "id": record.recordID.recordName,
              "deletedAt": Int64(at.timeIntervalSince1970 * 1000),
            ]
          },
        ])
      }
    }
    database.add(operation)
  }

  private func push(args: [String: Any], result: @escaping FlutterResult) {
    let rawRecords = args["records"] as? [[String: Any]] ?? []
    let rawDeleted = args["deleted"] as? [[String: Any]] ?? []

    var records: [CKRecord] = []
    for map in rawRecords {
      guard let id = map["id"] as? String else { continue }
      let record = CKRecord(
        recordType: recordType,
        recordID: CKRecord.ID(recordName: id, zoneID: zoneID)
      )
      record["amount"] = NSNumber(value: map["amount"] as? Double ?? 0)
      record["categoryId"] = (map["categoryId"] as? String ?? "other_expense") as NSString
      if let dateMs = map["date"] as? Int64 {
        record["date"] = Date(timeIntervalSince1970: Double(dateMs) / 1000) as NSDate
      }
      record["note"] = (map["note"] as? String ?? "") as NSString
      record["isIncome"] = NSNumber(value: map["isIncome"] as? Bool ?? false)
      record["source"] = (map["source"] as? String ?? "manual") as NSString
      if let merchant = map["merchant"] as? String, !merchant.isEmpty {
        record["merchant"] = merchant as NSString
      }
      if let updatedMs = map["updatedAt"] as? Int64 {
        record["updatedAt"] = Date(timeIntervalSince1970: Double(updatedMs) / 1000) as NSDate
      }
      records.append(record)
    }

    for map in rawDeleted {
      guard let id = map["id"] as? String else { continue }
      let record = CKRecord(
        recordType: recordType,
        recordID: CKRecord.ID(recordName: id, zoneID: zoneID)
      )
      if let at = map["deletedAt"] as? Int64 {
        record["deletedAt"] = Date(timeIntervalSince1970: Double(at) / 1000) as NSDate
      }
      records.append(record)
    }

    guard !records.isEmpty else {
      result(["saved": 0])
      return
    }
    saveBatches(records: records, index: 0, saved: 0, result: result)
  }

  private func saveBatches(
    records: [CKRecord],
    index: Int,
    saved: Int,
    result: @escaping FlutterResult
  ) {
    if index >= records.count {
      result(["saved": saved])
      return
    }
    let end = min(index + 100, records.count)
    let batch = Array(records[index..<end])
    let operation = CKModifyRecordsOperation(recordsToSave: batch, recordIDsToDelete: nil)
    operation.savePolicy = .allKeys
    operation.isAtomic = false
    operation.modifyRecordsCompletionBlock = { [weak self] _, _, error in
      guard let self = self else { return }
      if let error = error {
        DispatchQueue.main.async { self.fail(error, result) }
        return
      }
      DispatchQueue.main.async {
        self.saveBatches(records: records, index: end, saved: saved + batch.count, result: result)
      }
    }
    database.add(operation)
  }

  private func encode(_ record: CKRecord) -> [String: Any] {
    var map: [String: Any] = [
      "id": record.recordID.recordName,
      "amount": (record["amount"] as? NSNumber)?.doubleValue ?? 0,
      "categoryId": record["categoryId"] as? String ?? "other_expense",
      "note": record["note"] as? String ?? "",
      "isIncome": (record["isIncome"] as? NSNumber)?.boolValue ?? false,
      "source": record["source"] as? String ?? "manual",
    ]
    if let date = record["date"] as? Date {
      map["date"] = Int64(date.timeIntervalSince1970 * 1000)
    }
    if let updated = record["updatedAt"] as? Date {
      map["updatedAt"] = Int64(updated.timeIntervalSince1970 * 1000)
    }
    if let merchant = record["merchant"] as? String {
      map["merchant"] = merchant
    }
    return map
  }

  private func fail(_ error: Error, _ result: @escaping FlutterResult) {
    let message = self.message(for: error)
    result(FlutterError(code: "cloudkit_error", message: message, details: nil))
  }

  private func message(for error: Error) -> String {
    if let ckError = error as? CKError {
      switch ckError.code {
      case .notAuthenticated:
        return "请先在系统设置中登录 iCloud"
      case .networkUnavailable, .networkFailure:
        return "网络不可用，请稍后重试"
      case .quotaExceeded:
        return "iCloud 空间不足，请清理后重试"
      case .serviceUnavailable, .zoneBusy:
        return "iCloud 繁忙，请稍后重试"
      default:
        return "iCloud 同步失败：\(ckError.localizedDescription)"
      }
    }
    return "iCloud 同步失败：\(error.localizedDescription)"
  }
}
