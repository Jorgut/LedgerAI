import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// 应用内隐私政策页面。内容与 `docs/ARCHITECTURE.md` 的隐私口径一致：
/// 全离线、不登录、不上传、照片与录音仅在本机处理。
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static List<_LegalSection> _sections(AppLocalizations l10n) => [
        _LegalSection(l10n.privacyOneLineTitle, [l10n.privacyOneLineBody]),
        _LegalSection(
          l10n.privacyNotCollectedTitle,
          [l10n.privacyNotCollectedBody],
        ),
        _LegalSection(l10n.privacyStorageTitle, [l10n.privacyStorageBody]),
        _LegalSection(l10n.privacyCameraTitle, [l10n.privacyCameraBody]),
        _LegalSection(l10n.privacyMicTitle, [l10n.privacyMicBody]),
        _LegalSection(
          l10n.privacyExportDeleteTitle,
          [l10n.privacyExportDeleteBody],
        ),
        _LegalSection(
          l10n.privacyPermissionsTitle,
          [l10n.privacyPermissionsBody],
        ),
        _LegalSection(l10n.privacyChildrenTitle, [l10n.privacyChildrenBody]),
        _LegalSection(l10n.privacyUpdatesTitle, [l10n.privacyUpdatesBody]),
        _LegalSection(l10n.privacyContactTitle, [l10n.privacyContactBody]),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = _sections(l10n);
    return _LegalPage(
      title: l10n.privacyPolicy,
      updatedLabel: l10n.legalLastUpdated,
      sections: sections,
    );
  }
}

/// 应用内用户协议页面。
class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  static List<_LegalSection> _sections(AppLocalizations l10n) => [
        _LegalSection(l10n.termsServiceTitle, [l10n.termsServiceBody]),
        _LegalSection(l10n.termsNoticeTitle, [l10n.termsNoticeBody]),
        _LegalSection(l10n.termsFreeTitle, [l10n.termsFreeBody]),
        _LegalSection(l10n.termsBackupTitle, [l10n.termsBackupBody]),
        _LegalSection(l10n.termsDisclaimerTitle, [l10n.termsDisclaimerBody]),
        _LegalSection(l10n.termsIpTitle, [l10n.termsIpBody]),
        _LegalSection(l10n.termsChangesTitle, [l10n.termsChangesBody]),
        _LegalSection(l10n.termsLawTitle, [l10n.termsLawBody]),
        _LegalSection(l10n.termsContactTitle, [l10n.termsContactBody]),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = _sections(l10n);
    return _LegalPage(
      title: l10n.userAgreement,
      updatedLabel: l10n.legalLastUpdated,
      sections: sections,
    );
  }
}

class _LegalSection {
  const _LegalSection(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}

/// 法务页共用骨架：可滚动、可选中正文、支持大字号。
class _LegalPage extends StatelessWidget {
  const _LegalPage({
    required this.title,
    required this.updatedLabel,
    required this.sections,
  });

  final String title;
  final String updatedLabel;
  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Text(
                updatedLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              for (final section in sections) ...[
                Semantics(
                  header: true,
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                for (final paragraph in section.paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      paragraph,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.75,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
