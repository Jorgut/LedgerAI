import AVFoundation
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
