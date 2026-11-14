import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_info.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/common/app_card.dart';

enum _FeedbackType { bug, feature, other }

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();
  _FeedbackType _type = _FeedbackType.bug;
  bool _includeInfo = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l10n) => switch (_type) {
        _FeedbackType.bug => l10n.feedbackTypeBug,
        _FeedbackType.feature => l10n.feedbackTypeFeature,
        _FeedbackType.other => l10n.feedbackTypeOther,
      };

  String _buildReport(AppLocalizations l10n) {
    final app = AppScope.read(context);
    final buffer = StringBuffer()
      ..writeln(_typeLabel(l10n))
      ..writeln()
      ..writeln(_controller.text.trim());
    if (_includeInfo) {
      buffer
        ..writeln()
        ..writeln('---')
        ..writeln('HENG $kAppVersion ($kBuildNumber)')
        ..writeln('iOS: ${Platform.operatingSystemVersion}')
        ..writeln('Language: ${app.prefs.language.nativeLabel}')
        ..writeln('Theme: ${app.prefs.colorTheme.name}');
    }
    return buffer.toString().trim();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (_controller.text.trim().isEmpty) {
      _snack(l10n.feedbackEmpty);
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: kFeedbackEmail,
      queryParameters: {
        'subject': l10n.feedbackReportSubject,
        'body': _buildReport(l10n),
      },
    );
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) await _share(l10n);
    } catch (_) {
      await _share(l10n);
    }
  }

  Future<void> _share(AppLocalizations l10n) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          subject: l10n.feedbackReportSubject,
          title: l10n.feedbackTitle,
          text: _buildReport(l10n),
        ),
      );
      if (mounted) _snack(l10n.feedbackThanks);
    } catch (_) {
      if (mounted) _snack(l10n.feedbackCopy);
    }
  }

  void _copy() {
    final l10n = AppLocalizations.of(context);
    if (_controller.text.trim().isEmpty) {
      _snack(l10n.feedbackEmpty);
      return;
    }
    Clipboard.setData(ClipboardData(text: _buildReport(l10n)));
    _snack(l10n.feedbackCopied);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pageInsets,
          children: [
            Text(
              l10n.feedbackSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.feedbackMessageLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_FeedbackType>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: _FeedbackType.bug,
                        label: Text(l10n.feedbackTypeBug),
                      ),
                      ButtonSegment(
                        value: _FeedbackType.feature,
                        label: Text(l10n.feedbackTypeFeature),
                      ),
                      ButtonSegment(
                        value: _FeedbackType.other,
                        label: Text(l10n.feedbackTypeOther),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) =>
                        setState(() => _type = selection.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    minLines: 5,
                    maxLines: 10,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.feedbackMessageHint,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.info_outline_rounded),
                    title: Text(l10n.feedbackIncludeInfo),
                    subtitle: Text(l10n.feedbackIncludeInfoSub),
                    value: _includeInfo,
                    onChanged: (value) => setState(() => _includeInfo = value),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.feedbackPrivacyNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.mail_outline_rounded),
              label: Text(l10n.feedbackSend),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _copy,
              icon: const Icon(Icons.copy_rounded),
              label: Text(l10n.feedbackCopy),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.feedbackShareHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
