import 'dart:async';

import 'package:flutter/services.dart';

/// 语音识别的一次结果。partial 为实时中间结果，final 为最终结果。
class SpeechResult {
  const SpeechResult({
    required this.text,
    required this.isFinal,
    this.error,
  });

  final String text;
  final bool isFinal;
  final String? error;

  bool get hasError => error != null;
}

/// 设备端语音识别（SFSpeechRecognizer，要求 on-device）。
///
/// 通道协议见 docs/ARCHITECTURE.md。任何异常都以 [SpeechResult.error] 或
/// [start] 返回 false 的形式暴露，绝不把音频写到磁盘或上传。
///
/// 使用方式：先订阅 [results]，再调用 [start]；[stop] 会等待最终结果，
/// [cancel] 立即丢弃本次识别且之后不再推送事件。
class SpeechRecognizer {
  const SpeechRecognizer();

  static const MethodChannel _methods = MethodChannel(
    'com.archintera.ledgerai/speech',
  );
  static const EventChannel _events = EventChannel(
    'com.archintera.ledgerai/speech_events',
  );

  /// 广播流只创建一次：EventChannel 同一通道只允许一个监听句柄，
  /// 每次 `results` 都新建流会让上一次订阅失效。
  static Stream<SpeechResult>? _cachedResults;

  /// 实时结果流；一次 [start] 到 [stop]/[cancel] 之间有效。
  Stream<SpeechResult> get results => _cachedResults ??= _createResultsStream();

  static Stream<SpeechResult> _createResultsStream() {
    final controller = StreamController<SpeechResult>.broadcast();
    StreamSubscription<dynamic>? subscription;
    controller.onListen = () {
      subscription = _events.receiveBroadcastStream().listen(
        (dynamic event) {
          final result = _mapEvent(event);
          if (result != null) controller.add(result);
        },
        onError: (Object error) {
          controller.add(
            SpeechResult(
              text: '',
              isFinal: false,
              error: _errorMessage(error),
            ),
          );
        },
      );
    };
    controller.onCancel = () async {
      final current = subscription;
      if (identical(subscription, current)) {
        subscription = null;
      }
      await current?.cancel();
    };
    return controller.stream;
  }

  static SpeechResult? _mapEvent(dynamic event) {
    if (event is! Map) return null;
    final map = event.cast<dynamic, dynamic>();
    final type = '${map['type'] ?? ''}';
    final rawText = map['text'];
    final text = rawText is String ? rawText : '';
    switch (type) {
      case 'partial':
        return SpeechResult(text: text, isFinal: false);
      case 'final':
        return SpeechResult(text: text, isFinal: true);
      case 'error':
        final rawMessage = map['message'];
        final message = rawMessage is String ? rawMessage.trim() : '';
        return SpeechResult(
          text: text,
          isFinal: false,
          error: message.isEmpty ? '语音识别暂不可用，请改用手动输入。' : message,
        );
      default:
        // 'state' 事件只用于原生侧会话状态，不需要交给界面。
        return null;
    }
  }

  static String _errorMessage(Object error) {
    if (error is MissingPluginException) {
      return '当前设备不支持语音识别，请改用手动输入。';
    }
    if (error is PlatformException) {
      final message = error.message?.trim() ?? '';
      if (message.isNotEmpty) return message;
      return '语音识别启动失败，请重试或改用手动输入。';
    }
    return '语音识别暂不可用，请改用手动输入。';
  }

  /// 设备端模型是否可用。模拟器、无中文离线模型或未授权时返回 false。
  Future<bool> isAvailable() async {
    try {
      return await _methods.invokeMethod<bool>('isAvailable') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// 开始识别。返回 false 时调用方应提示用户改用手动输入。
  ///
  /// 权限被拒、设备端模型缺失等具体原因会通过 [results] 的 error 事件给出中文提示。
  Future<bool> start({String localeId = 'zh-CN'}) async {
    try {
      final ok = await _methods.invokeMethod<bool>(
        'start',
        <String, dynamic>{'localeId': localeId},
      );
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// 停止录音并等待最终结果（final 事件）。无效调用会被忽略。
  Future<void> stop() async {
    try {
      await _methods.invokeMethod<void>('stop');
    } on PlatformException {
      // 停止失败不影响 UI。
    } on MissingPluginException {
      // 模拟器或未接入原生实现时忽略。
    }
  }

  /// 取消本次识别：不再推送 partial/final/error 事件。
  Future<void> cancel() async {
    try {
      await _methods.invokeMethod<void>('cancel');
    } on PlatformException {
      // 取消失败不影响 UI。
    } on MissingPluginException {
      // 忽略。
    }
  }
}
