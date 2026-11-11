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
/// 返回 false 的形式暴露，绝不把音频写到磁盘或上传。
class SpeechRecognizer {
  const SpeechRecognizer();

  static const MethodChannel _methods = MethodChannel('com.jorgut.ledgerai/speech');
  static const EventChannel _events = EventChannel('com.jorgut.ledgerai/speech_events');

  /// 实时结果流；一次 [start] 到 [stop]/[cancel] 之间有效。
  Stream<SpeechResult> get results {
    return _events.receiveBroadcastStream().where((event) => event is Map).map((event) {
      final map = (event as Map).cast<dynamic, dynamic>();
      final type = '${map['type'] ?? ''}';
      final text = '${map['text'] ?? ''}';
      switch (type) {
        case 'error':
          return SpeechResult(
            text: text,
            isFinal: false,
            error: '${map['message'] ?? '语音识别暂不可用'}',
          );
        case 'final':
          return SpeechResult(text: text, isFinal: true);
        default:
          return SpeechResult(text: text, isFinal: false);
      }
    });
  }

  Future<bool> isAvailable() async {
    try {
      return await _methods.invokeMethod<bool>('isAvailable') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> start({String localeId = 'zh-CN'}) async {
    try {
      final ok = await _methods.invokeMethod<bool>('start', {'localeId': localeId});
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _methods.invokeMethod<void>('stop');
    } on PlatformException {
      // 停止失败不影响 UI。
    } on MissingPluginException {
      // 模拟器或未接入原生实现时忽略。
    }
  }

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
