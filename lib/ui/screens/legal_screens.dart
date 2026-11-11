import 'package:flutter/material.dart';

/// 应用内隐私政策页面。内容与 `docs/ARCHITECTURE.md` 的隐私口径一致：
/// 全离线、不登录、不上传、照片与录音仅在本机处理。
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<_LegalSection> _sections = [
    _LegalSection(
      '一句话说明',
      [
        '衡账是一款本地优先的记账 App：不登录、不联网、不上传你的任何账单数据。'
            '文字识别、语音识别与统计建议全部在你的 iPhone 上完成。',
      ],
    ),
    _LegalSection(
      '我们不收集什么',
      [
        '开发者不收集、不存储、不传输你的任何个人信息或记账数据。App 没有账号体系，'
            '也不包含第三方统计、广告、推送或社交登录 SDK。因此 App Store 的隐私标签为'
            '「Data Not Collected」（不收集数据）。',
      ],
    ),
    _LegalSection(
      '数据保存在哪里',
      [
        '账单记录、预算和偏好设置只写入 App 在本机的沙盒数据库。'
            '除非你主动在「设置 → 数据」中导出并分享，这些数据不会离开你的设备。',
      ],
    ),
    _LegalSection(
      '相机与照片',
      [
        '使用拍照识别小票时，App 通过系统相机或相册获取一张图片，并使用 iOS 内置的 Vision '
            '文字识别功能在本机提取文字。原始图片不会被保存到相册，也不会被上传；'
            '识别完成后即从内存释放。',
      ],
    ),
    _LegalSection(
      '麦克风与语音',
      [
        '语音记账使用 iOS 系统语音识别，并强制要求设备端识别。音频不会被写入磁盘，'
            '也不会被上传。若系统无法在本机完成识别，该功能会提示暂不可用，'
            '而不会改用云端识别。',
      ],
    ),
    _LegalSection(
      '数据导出与删除',
      [
        '你可以在「设置 → 数据」导出 CSV 表格或 JSON 备份，文件由你自己保存与分享；'
            '也可以在「设置 → 清空全部账单」一键删除全部账单记录。'
            '卸载 App 会删除本机保存的全部数据，请提前导出备份。',
      ],
    ),
    _LegalSection(
      '权限说明',
      [
        '相机、照片、麦克风与语音识别权限都是可选的，只在对应功能中按需申请。'
            '即使拒绝这些权限，手动记账、报表、预算与导出等功能仍可正常使用。',
      ],
    ),
    _LegalSection(
      '儿童隐私',
      [
        '本 App 不收集任何用户的数据，也不含广告或第三方追踪，适用于包括未成年人在内的'
            '所有用户；我们不会针对儿童推送定向内容。',
      ],
    ),
    _LegalSection(
      '政策更新',
      [
        '如果未来的版本改变了数据处理方式，我们会在 App 内更新本页面，'
            '并同步调整 App Store 的隐私标签。',
      ],
    ),
    _LegalSection(
      '联系我们',
      [
        '如对本政策有疑问，可以通过 App Store 商品页上的「App 支持」链接联系我们。',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: '隐私政策',
      updatedLabel: '最后更新：2026 年 11 月',
      sections: _sections,
    );
  }
}

/// 应用内用户协议页面。
class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  static const List<_LegalSection> _sections = [
    _LegalSection(
      '服务说明',
      [
        '衡账是一款免费、本地优先的个人记账工具，提供手动记账、拍照识别、语音记账、'
            '收支统计报表、预算提醒与数据导出等功能。App 的全部功能都在这台设备上运行。',
      ],
    ),
    _LegalSection(
      '使用须知',
      [
        '你需要对录入信息的准确性负责。拍照识别与语音识别的结果可能因为小票模糊、'
            '口音或环境噪音出现误差，请在保存前核对。建议定期导出 JSON 备份。',
      ],
    ),
    _LegalSection(
      '免费与内购',
      [
        '当前版本免费提供，没有订阅、没有内购、没有广告。若未来调整收费方式，'
            '我们会提前在 App 内说明，不会影响你已保存在本机的数据。',
      ],
    ),
    _LegalSection(
      '数据与备份',
      [
        '你的数据只保存在本机，开发者无法访问，也无法替你恢复。'
            '因设备丢失、系统故障、卸载 App 或主动清空数据造成的数据丢失，'
            '在适用法律允许的范围内由你自行承担。你可以随时在设置中导出备份。',
      ],
    ),
    _LegalSection(
      '免责声明',
      [
        'App 中的统计、预算提醒与「智能建议」均基于本机数据和固定规则生成，'
            '仅作为个人记账参考，不构成投资、理财、税务、法律或医疗建议。'
            '你依据本 App 内容做出的任何决定，风险由你自行承担。',
      ],
    ),
    _LegalSection(
      '知识产权',
      [
        'App 的界面、图标、文案与代码归开发者所有。你可以将导出的个人账单数据'
            '用于个人用途，但不得将其用于侵犯他人权益的用途。',
      ],
    ),
    _LegalSection(
      '服务变更与终止',
      [
        '我们可能随系统版本更新调整或改进功能。若未来停止维护，会在 App 内提前告知；'
            '你仍然可以继续使用本地数据，并随时导出备份。',
      ],
    ),
    _LegalSection(
      '适用法律',
      [
        '本协议适用中华人民共和国法律。因本协议产生的争议，双方应先友好协商解决。',
      ],
    ),
    _LegalSection(
      '联系我们',
      [
        '如对本协议有疑问，可以通过 App Store 商品页上的「App 支持」链接联系我们。',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: '用户协议',
      updatedLabel: '最后更新：2026 年 11 月',
      sections: _sections,
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
