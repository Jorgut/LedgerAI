import 'dart:async';

import 'package:flutter/services.dart';

/// 本机 OCR 结果。
class OcrResult {
  const OcrResult({required this.text, this.lines = const []});

  final String text;
  final List<String> lines;

  bool get isEmpty => text.trim().isEmpty;
}

/// 调用 iOS Vision 做设备端文字识别。图片不离开本机。
class ReceiptOcr {
  const ReceiptOcr();

  static const MethodChannel channel = MethodChannel('com.archintera.ledgerai/ocr');

  /// 单次识别的最长等待时间：超过后回退到手动输入，避免界面一直转圈。
  static const Duration timeout = Duration(seconds: 25);

  /// 识别失败（权限、格式、通道不可用、超时）时返回 null，调用方回退到手动输入。
  ///
  /// [imagePath] 由 image_picker 管理的临时文件，读取后不会复制或持久化。
  Future<OcrResult?> recognizeFile(String imagePath) async {
    final path = imagePath.trim();
    if (path.isEmpty) return null;
    try {
      final result = await channel
          .invokeMapMethod<String, dynamic>(
            'recognizeText',
            <String, dynamic>{'path': path},
          )
          .timeout(timeout);
      if (result == null) return null;
      final rawText = result['text'];
      final text = rawText is String ? rawText.trim() : '';
      final rawLines = result['lines'];
      final lines = rawLines is List
          ? rawLines
                .map((line) => '$line'.trim())
                .where((line) => line.isNotEmpty)
                .toList()
          : const <String>[];
      if (text.isEmpty && lines.isEmpty) return null;
      return OcrResult(
        text: text.isEmpty ? lines.join('\n') : text,
        lines: lines,
      );
    } on TimeoutException {
      return null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
