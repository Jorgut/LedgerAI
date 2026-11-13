import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// SnackBar 统一封装：中文提示、浮动样式、支持「撤销」。
class AppSnack {
  AppSnack._();

  static void show(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Semantics(liveRegion: true, child: Text(message)),
          action: action,
          duration: duration,
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, duration: const Duration(seconds: 2));

  static void error(BuildContext context, String message) => show(
        context,
        message,
        duration: const Duration(seconds: 5),
      );

  /// 删除后的撤销提示；[onUndo] 应恢复被删除的数据。
  static void undo(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    String? actionLabel,
  }) {
    show(
      context,
      message,
      action: SnackBarAction(
        label: actionLabel ?? AppLocalizations.of(context).undo,
        onPressed: onUndo,
      ),
      duration: const Duration(seconds: 5),
    );
  }
}
