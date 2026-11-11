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

  static const MethodChannel channel = MethodChannel('com.jorgut.ledgerai/ocr');

  /// 识别失败（权限、格式、通道不可用）时返回 null，调用方回退到手动输入。
  Future<OcrResult?> recognizeFile(String imagePath) async {
    try {
      final result = await channel.invokeMapMethod<String, dynamic>(
        'recognizeText',
        {'path': imagePath},
      );
      if (result == null) return null;
      final text = result['text'] as String? ?? '';
      final rawLines = result['lines'];
      final lines = rawLines is List
          ? rawLines.map((line) => '$line').where((line) => line.trim().isNotEmpty).toList()
          : const <String>[];
      if (text.trim().isEmpty && lines.isEmpty) return null;
      return OcrResult(text: text, lines: lines);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
