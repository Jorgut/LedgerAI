import 'package:flutter/widgets.dart';

import '../../../core/models.dart';
import '../../../l10n/app_localizations.dart';

String localizedSourceLabel(BuildContext context, EntrySource source) {
  final l10n = AppLocalizations.of(context);
  return switch (source) {
    EntrySource.manual => l10n.sourceManual,
    EntrySource.ocr => l10n.sourceOcr,
    EntrySource.voice => l10n.sourceVoice,
    EntrySource.csv => l10n.sourceCsv,
  };
}
