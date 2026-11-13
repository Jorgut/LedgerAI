import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../ai/ocr_service.dart';
import '../../ai/parsing.dart';
import '../../ai/speech_service.dart';
import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../l10n/app_localizations.dart';
import '../motion/motion.dart';
import '../theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_snack.dart';
import '../widgets/common/category_icon.dart';
import '../widgets/common/category_localization.dart';

/// 记账入口的初始模式。
enum AddTransactionMode { manual, receipt, voice }

/// 记一笔 / 编辑一笔。
///
/// 三个入口共用同一份表单状态：
/// - [AddTransactionMode.manual]：手动填写（大号金额、收支切换、分类网格、备注、日期）。
/// - [AddTransactionMode.receipt]：image_picker 拍照/相册 → [ReceiptOcr] → [ReceiptParser] 预填。
/// - [AddTransactionMode.voice]：按住说话 → [SpeechRecognizer] → [VoiceEntryParser] 预填。
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialReceipt,
    this.initialMode = AddTransactionMode.manual,
  });

  /// 编辑已有记录时传入；为 null 表示新增。
  final Txn? transaction;

  /// 外部已经解析好的小票结果（可选），进入页面即预填。
  final ParsedReceipt? initialReceipt;

  /// 初始入口；编辑时强制为手动模式。
  final AddTransactionMode initialMode;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // 语音示例保持中文：语音识别固定使用 zh-CN，示例同时也是解析器可识别的数据。
  static const List<String> _voiceExamples = [
    '今天午餐花了 42 块',
    '昨天打车 35',
    '工资到账 8500',
  ];

  final SpeechRecognizer _speech = const SpeechRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final FocusNode _amountFocus;

  late AddTransactionMode _mode;
  late bool _isIncome;
  late String _categoryId;
  late DateTime _date;
  late EntrySource _source;

  String? _merchant;
  String? _rawText;
  String? _amountError;
  String? _ocrError;

  bool _showRawText = false;
  bool _justParsed = false;
  bool _typeTouchedByUser = false;
  bool _saving = false;
  bool _ocrBusy = false;

  bool _listening = false;
  bool _voiceHandled = false;
  String _liveText = '';
  bool? _speechAvailable;
  StreamSubscription<SpeechResult>? _speechSubscription;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final txn = widget.transaction;
    final receipt = widget.initialReceipt;
    final now = DateTime.now();

    if (txn != null) {
      _isIncome = txn.isIncome;
    } else if (receipt != null) {
      final categoryId = receipt.categoryId;
      final categoryIsIncome =
          categoryId != null && Category.byId(categoryId).isIncome;
      _isIncome = receipt.isIncome || categoryIsIncome;
    } else {
      _isIncome = false;
    }
    _categoryId = _resolveCategoryId(
      txn?.categoryId ?? receipt?.categoryId,
      _isIncome,
    );

    _amountController = TextEditingController(
      text: _amountInputText(txn?.amount ?? receipt?.amount),
    );
    _noteController = TextEditingController(
      text: txn?.note ?? receipt?.note ?? '',
    );
    _amountFocus = FocusNode();

    final parsedDate = receipt?.date;
    if (txn != null) {
      _date = txn.date;
    } else if (parsedDate != null) {
      _date = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        now.hour,
        now.minute,
      );
    } else {
      _date = now;
    }

    _merchant = txn?.merchant ?? receipt?.merchant;
    final raw = receipt?.rawText;
    _rawText = (raw != null && raw.trim().isNotEmpty) ? raw : null;
    _source = txn?.source ??
        (widget.initialMode == AddTransactionMode.voice
            ? EntrySource.voice
            : (receipt != null ? EntrySource.ocr : EntrySource.manual));
    _justParsed = receipt != null;
    _mode = txn != null ? AddTransactionMode.manual : widget.initialMode;

    _speechSubscription = _speech.results.listen(
      _onSpeechResult,
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted) return;
        setState(() => _listening = false);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSpeech());
  }

  @override
  void dispose() {
    _speechSubscription?.cancel();
    _speech.cancel();
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 初始化辅助
  // ---------------------------------------------------------------------------

  String _resolveCategoryId(String? candidate, bool isIncome) {
    final categories = Category.forType(isIncome);
    if (candidate != null) {
      final category = Category.byId(candidate);
      if (category.isIncome == isIncome &&
          categories.any((item) => item.id == candidate)) {
        return candidate;
      }
    }
    return categories.first.id;
  }

  String _amountInputText(double? amount) {
    if (amount == null || amount <= 0) return '';
    if (amount == amount.roundToDouble()) return amount.toStringAsFixed(0);
    return amount.toStringAsFixed(2);
  }

  double? _parsedAmount() {
    final amount = parseAmount(_amountController.text);
    if (amount == null || amount <= 0) return null;
    return (amount * 100).roundToDouble() / 100;
  }

  Future<void> _checkSpeech() async {
    final available = await _speech.isAvailable();
    if (!mounted) return;
    setState(() => _speechAvailable = available);
  }

  // ---------------------------------------------------------------------------
  // 表单状态
  // ---------------------------------------------------------------------------

  void _setIncome(bool isIncome) {
    if (_isIncome == isIncome) return;
    setState(() {
      _typeTouchedByUser = true;
      _isIncome = isIncome;
      if (Category.byId(_categoryId).isIncome != isIncome) {
        _categoryId = Category.forType(isIncome).first.id;
      }
    });
    if (AppScope.read(context).prefs.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _selectCategory(Category category) {
    if (_categoryId == category.id) return;
    setState(() => _categoryId = category.id);
    if (AppScope.read(context).prefs.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _switchMode(AddTransactionMode mode) {
    if (mode == _mode) return;
    if (_listening) _cancelVoice();
    setState(() {
      _mode = mode;
      if (mode != AddTransactionMode.voice) _liveText = '';
      if (mode != AddTransactionMode.receipt) _ocrError = null;
    });
  }

  void _applyParsed(
    ParsedReceipt parsed, {
    required EntrySource source,
    required String raw,
  }) {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _mode = AddTransactionMode.manual;
      _source = source;
      _justParsed = true;
      _rawText = raw;
      _showRawText = false;
      _voiceHandled = true;
      _listening = false;
      _liveText = '';
      _ocrError = null;
      _amountError = null;
      if (parsed.amount != null) {
        _amountController.text = _amountInputText(parsed.amount);
        _amountController.selection = TextSelection.collapsed(
          offset: _amountController.text.length,
        );
      }
      if (parsed.note.trim().isNotEmpty) {
        _noteController.text = parsed.note.trim();
      }
      if (parsed.merchant != null && parsed.merchant!.trim().isNotEmpty) {
        _merchant = parsed.merchant!.trim();
      }
      // 收支方向以解析器的 isIncome 为准（「今天收入500」这类无分类收入
      // 不能靠 categoryId 推断）；用户已手动切换过时保持用户选择。
      if (!_typeTouchedByUser) {
        _isIncome = parsed.isIncome;
      }
      // 分类一律按当前收支方向回退到 Category.forType(isIncome)；
      // parsed.categoryId 与方向不一致时自动落到该方向的首个分类。
      _categoryId = _resolveCategoryId(parsed.categoryId, _isIncome);
      final date = parsed.date;
      if (date != null) {
        _date = DateTime(
          date.year,
          date.month,
          date.day,
          now.hour,
          now.minute,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // 语音
  // ---------------------------------------------------------------------------

  void _onSpeechResult(SpeechResult result) {
    if (!mounted) return;
    if (result.hasError) {
      if (!_listening) return;
      setState(() => _listening = false);
      AppSnack.error(
        context,
        result.error ?? AppLocalizations.of(context).addVoiceFallbackError,
      );
      return;
    }
    if (result.isFinal) {
      if (_listening) setState(() => _listening = false);
      _handleSpokenText(result.text);
      return;
    }
    if (!_listening) return;
    setState(() => _liveText = result.text);
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _stopVoice();
    } else {
      await _startVoice();
    }
  }

  Future<void> _startVoice() async {
    if (_listening) return;
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    final available = await _speech.isAvailable();
    if (!mounted) return;
    if (!available) {
      setState(() => _speechAvailable = false);
      AppSnack.error(context, l10n.addVoiceNotSupported);
      return;
    }
    setState(() {
      _speechAvailable = true;
      _listening = true;
      _voiceHandled = false;
      _liveText = '';
    });
    final started = await _speech.start(localeId: 'zh-CN');
    if (!mounted) return;
    if (!started) {
      setState(() => _listening = false);
      AppSnack.error(context, l10n.addVoiceStartFailed);
      return;
    }
    if (app.prefs.hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _stopVoice() async {
    if (!_listening) return;
    await _speech.stop();
    if (!mounted) return;
    setState(() => _listening = false);
    final text = _liveText.trim();
    if (text.isEmpty) {
      AppSnack.error(
        context,
        AppLocalizations.of(context).addVoiceNoSpeech,
      );
      return;
    }
    _handleSpokenText(text);
  }

  Future<void> _cancelVoice() async {
    await _speech.cancel();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _liveText = '';
    });
  }

  void _handleSpokenText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _voiceHandled) return;
    final l10n = AppLocalizations.of(context);
    _voiceHandled = true;
    final parsed = const VoiceEntryParser().parse(trimmed);
    if (parsed.amount == null) {
      if (!mounted) return;
      AppSnack.error(context, l10n.addVoiceNoAmount);
      return;
    }
    _applyParsed(parsed, source: EntrySource.voice, raw: trimmed);
    AppSnack.success(context, l10n.addVoiceRecognized);
  }

  // ---------------------------------------------------------------------------
  // 拍照识别
  // ---------------------------------------------------------------------------

  Future<void> _pickReceipt(ImageSource source) async {
    if (_ocrBusy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _ocrBusy = true;
      _ocrError = null;
    });
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2400,
        imageQuality: 88,
      );
      if (picked == null) {
        if (mounted) setState(() => _ocrBusy = false);
        return;
      }
      final result = await const ReceiptOcr().recognizeFile(picked.path);
      if (!mounted) return;
      if (result == null || result.isEmpty) {
        setState(() {
          _ocrBusy = false;
          _ocrError = l10n.addOcrNoTextError;
        });
        AppSnack.error(context, l10n.addOcrNoText);
        return;
      }
      final parsed = const ReceiptParser().parse(result.text);
      setState(() {
        _ocrBusy = false;
        _rawText = result.text;
      });
      if (!parsed.hasUsefulData) {
        setState(() {
          _showRawText = true;
          _ocrError = l10n.addOcrNoAmountError;
        });
        AppSnack.error(context, l10n.addOcrNoAmount);
        return;
      }
      _applyParsed(parsed, source: EntrySource.ocr, raw: result.text);
      AppSnack.success(context, l10n.addOcrRecognized);
    } on PlatformException catch (error) {
      if (!mounted) return;
      final message = _imageErrorMessage(error, source);
      setState(() {
        _ocrBusy = false;
        _ocrError = message;
      });
      AppSnack.error(context, message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ocrBusy = false;
        _ocrError = l10n.addOcrFailedError;
      });
      AppSnack.error(context, l10n.addOcrFailed);
    }
  }

  String _imageErrorMessage(PlatformException error, ImageSource source) {
    final l10n = AppLocalizations.of(context);
    final code = error.code.toLowerCase();
    if (code.contains('camera')) {
      return l10n.addCameraPermission;
    }
    if (code.contains('photo')) {
      return l10n.addPhotoPermission;
    }
    return source == ImageSource.camera
        ? l10n.addCameraOpenFailed
        : l10n.addPhotoReadFailed;
  }

  // ---------------------------------------------------------------------------
  // 日期 / 保存 / 删除
  // ---------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = _date.isBefore(DateTime(2000)) ? _date : DateTime(2000);
    final last = _date.isAfter(today) ? _date : today;
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: first,
        lastDate: last,
        helpText: l10n.addSelectDate,
        cancelText: l10n.commonCancel,
        confirmText: l10n.commonConfirm,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    } catch (_) {
      if (!mounted) return;
      AppSnack.error(context, l10n.addDatePickerFailed);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final amount = _parsedAmount();
    if (amount == null) {
      setState(() => _amountError = l10n.addAmountRequired);
      _amountFocus.requestFocus();
      AppSnack.error(context, l10n.addAmountRequired);
      return;
    }
    setState(() {
      _saving = true;
      _amountError = null;
    });

    final app = AppScope.read(context);
    final existing = widget.transaction;
    final txn = Txn(
      id: existing?.id ?? const Uuid().v4(),
      amount: amount,
      categoryId: _categoryId,
      date: _date,
      note: _noteController.text.trim(),
      isIncome: _isIncome,
      source: existing?.source ?? _source,
      merchant: _merchant,
      createdAt: existing?.createdAt,
    );

    try {
      await app.saveTransaction(txn);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.error(context, l10n.addSaveFailed);
      return;
    }

    // 保存已经成功：反馈与返回不能影响结果，更不能被误报为「保存失败」。
    if (!mounted) return;
    if (app.prefs.hapticsEnabled) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {
        // 触觉反馈失败不影响已保存的数据。
      }
    }
    if (!mounted) return;
    AppSnack.success(
        context, existing == null ? l10n.addSaved : l10n.addUpdated);
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final existing = widget.transaction;
    if (existing == null) return;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addDeleteDialogTitle),
        content: Text(l10n.addDeleteDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final app = AppScope.read(context);
    try {
      await app.deleteTransaction(existing.id);
      if (!mounted) return;
      AppSnack.success(context, l10n.addDeleted);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      AppSnack.error(context, l10n.txDeleteFailed);
    }
  }

  // ---------------------------------------------------------------------------
  // 构建
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.addEditTitle : l10n.addTitle),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.addDeleteTooltip,
              onPressed: _saving ? null : _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        bottom: _mode != AddTransactionMode.manual,
        child: Column(
          children: [
            if (!_isEditing)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _ModeBar(mode: _mode, onChanged: _switchMode),
              ),
            Expanded(
              child: switch (_mode) {
                AddTransactionMode.manual => _buildManualForm(theme),
                AddTransactionMode.receipt => _buildReceiptPanel(theme),
                AddTransactionMode.voice => _buildVoicePanel(theme),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _mode == AddTransactionMode.manual
          ? SafeArea(
              top: false,
              child: Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(
                            _isEditing
                                ? l10n.addSaveChanges
                                : l10n.addSaveRecord,
                          ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildManualForm(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        _buildSourceBanner(theme),
        _buildAmountCard(theme),
        const SizedBox(height: 12),
        _buildTypeToggle(theme),
        const SizedBox(height: 16),
        _buildCategorySection(theme),
        const SizedBox(height: 16),
        _buildDetailsCard(theme),
        if (_rawText != null) ...[
          const SizedBox(height: 16),
          _buildRawTextCard(theme),
        ],
        const SizedBox(height: 8),
        Center(
          child: Text(
            AppLocalizations.of(context).addFooterSaveHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Color _accent(ThemeData theme) => AppTheme.isDark(context)
      ? theme.colorScheme.primary
      : AppTheme.brandTextOf(context);

  Widget _buildSourceBanner(ThemeData theme) {
    if (!_justParsed) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final isOcr = _source == EntrySource.ocr;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isOcr ? Icons.document_scanner_rounded : Icons.mic_rounded,
              size: 20,
              color: _accent(theme),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isOcr ? l10n.addReceiptFilledBanner : l10n.addVoiceFilledBanner,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final accent = _accent(theme);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addAmountLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '¥',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  focusNode: _amountFocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: AppTheme.tabularFigures,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    errorText: _amountError,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintStyle: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      fontWeight: FontWeight.w700,
                    ),
                    errorStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  onChanged: (_) {
                    if (_amountError != null) {
                      setState(() => _amountError = null);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final options = <({bool isIncome, String label, IconData icon})>[
      (isIncome: false, label: l10n.expense, icon: Icons.arrow_upward_rounded),
      (isIncome: true, label: l10n.income, icon: Icons.arrow_downward_rounded),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: _isIncome == option.isIncome,
                label: option.label,
                onTap: () => _setIncome(option.isIncome),
                excludeSemantics: true,
                child: Material(
                  color: _isIncome == option.isIncome
                      ? theme.colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _setIncome(option.isIncome),
                    borderRadius: BorderRadius.circular(10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              option.icon,
                              size: 18,
                              color: _isIncome == option.isIncome
                                  ? (option.isIncome
                                      ? AppTheme.incomeColorOf(context)
                                      : AppTheme.expenseColorOf(context))
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                option.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: _isIncome == option.isIncome
                                      ? (option.isIncome
                                          ? AppTheme.incomeColorOf(context)
                                          : AppTheme.expenseColorOf(context))
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    final categories = Category.forType(_isIncome);
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final columns = scale >= 1.55 ? 4 : 5;
    final extent = 78 + (scale.clamp(1.0, 2.0) - 1.0) * 30;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocalizations.of(context).txCategory,
            style: theme.textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: extent,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategoryCell(context, theme, categories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCell(BuildContext context, ThemeData theme, Category category) {
    final selected = _categoryId == category.id;
    final accent = _accent(theme);
    return Semantics(
      button: true,
      selected: selected,
      label: localizedCategoryName(context, category),
      onTap: () => _selectCategory(category),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _selectCategory(category),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.6,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CategoryIcon(category: category, size: 36),
              const SizedBox(height: 4),
              Text(
                localizedCategoryName(context, category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected ? accent : theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final merchant = _merchant?.trim();
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.addNoteLabel,
              hintText: l10n.addNoteHint,
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          if (merchant != null && merchant.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: InputChip(
                  label: Text(l10n.addMerchantChip(merchant)),
                  deleteButtonTooltipMessage: l10n.addClearMerchant,
                  onDeleted: () => setState(() => _merchant = null),
                ),
              ),
            ),
          Divider(height: 20, color: theme.colorScheme.outlineVariant),
          _buildDateRow(theme),
        ],
      ),
    );
  }

  Widget _buildDateRow(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final label =
        '${formatDateLabel(_date, locale: Localizations.localeOf(context))} ${formatWeekday(_date, locale: Localizations.localeOf(context))}';
    return Semantics(
      button: true,
      label: l10n.addDateSemantic(label),
      onTap: _pickDate,
      excludeSemantics: true,
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(l10n.addDateLabel, style: theme.textTheme.bodyLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRawTextCard(ThemeData theme) {
    final raw = _rawText?.trim() ?? '';
    if (raw.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Semantics(
            button: true,
            label:
                _showRawText ? l10n.addCollapseRawText : l10n.addExpandRawText,
            onTap: () => setState(() => _showRawText = !_showRawText),
            excludeSemantics: true,
            child: InkWell(
              onTap: () => setState(() => _showRawText = !_showRawText),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.text_snippet_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.addRawTextTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Icon(
                      _showRawText
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showRawText)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  raw,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReceiptPanel(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final accent = _accent(theme);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.document_scanner_rounded,
                      size: 44,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.addReceiptTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addReceiptBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _ocrBusy
                          ? null
                          : () => _pickReceipt(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_rounded),
                      label: Text(l10n.addReceiptCamera),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _ocrBusy
                          ? null
                          : () => _pickReceipt(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(l10n.addReceiptGallery),
                    ),
                  ),
                  if (_ocrBusy) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            l10n.addReceiptRecognizing,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_ocrError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 20,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _ocrError!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_rawText != null) ...[
              const SizedBox(height: 16),
              _buildRawTextCard(theme),
            ],
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => _switchMode(AddTransactionMode.manual),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(l10n.addSwitchToManual),
              ),
            ),
          ],
        ),
        if (_ocrBusy) const Positioned.fill(child: ScanLine(active: true)),
      ],
    );
  }

  Widget _buildVoicePanel(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final available = _speechAvailable;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                l10n.addVoiceTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addVoiceBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              if (available == false)
                _buildVoiceUnavailable(theme)
              else ...[
                Semantics(
                  button: true,
                  label: _listening
                      ? l10n.addVoiceListening
                      : l10n.addVoiceHoldToTalk,
                  hint: l10n.addVoiceToggleHint,
                  onTap: _toggleVoice,
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: _toggleVoice,
                    onLongPressStart: (_) => _startVoice(),
                    onLongPressEnd: (_) => _stopVoice(),
                    onLongPressCancel: _stopVoice,
                    behavior: HitTestBehavior.opaque,
                    child: PulseRings(
                      active: _listening,
                      size: 176,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _listening ? 136 : 124,
                        height: _listening ? 136 : 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.brandGradientOf(context),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.brandOf(context)
                                  .withValues(alpha: 0.30),
                              blurRadius: _listening ? 28 : 14,
                              spreadRadius: _listening ? 6 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _listening
                              ? Icons.graphic_eq_rounded
                              : Icons.mic_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _listening ? l10n.addVoiceListening : l10n.addVoiceTapOrHold,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 88),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _liveText.trim().isEmpty
                        ? l10n.addVoiceLivePlaceholder
                        : _liveText,
                    textAlign: TextAlign.center,
                    style: _liveText.trim().isEmpty
                        ? theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.addVoiceExamplesTitle,
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              for (final example in _voiceExamples)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.addVoiceExample(example),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => _switchMode(AddTransactionMode.manual),
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(l10n.addVoiceSwitchToManual),
          ),
        ),
        if (available == null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.addVoiceChecking,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVoiceUnavailable(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Icon(
          Icons.mic_off_rounded,
          size: 44,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.addVoiceUnavailableTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.addVoiceUnavailableBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _switchMode(AddTransactionMode.manual),
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(l10n.addVoiceUseManual),
          ),
        ),
      ],
    );
  }
}

/// 顶部入口切换：手动 / 拍照 / 语音。
class _ModeBar extends StatelessWidget {
  const _ModeBar({required this.mode, required this.onChanged});

  final AddTransactionMode mode;
  final ValueChanged<AddTransactionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final options = <({AddTransactionMode mode, IconData icon, String label})>[
      (
        mode: AddTransactionMode.manual,
        icon: Icons.edit_note_rounded,
        label: l10n.addModeManual
      ),
      (
        mode: AddTransactionMode.receipt,
        icon: Icons.document_scanner_rounded,
        label: l10n.addModeReceipt
      ),
      (
        mode: AddTransactionMode.voice,
        icon: Icons.mic_rounded,
        label: l10n.addModeVoice
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: mode == option.mode,
                label: l10n.addModeSemantic(option.label),
                onTap: () => onChanged(option.mode),
                excludeSemantics: true,
                child: Material(
                  color: mode == option.mode
                      ? theme.colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => onChanged(option.mode),
                    borderRadius: BorderRadius.circular(10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              option.icon,
                              size: 18,
                              color: mode == option.mode
                                  ? (AppTheme.isDark(context)
                                      ? theme.colorScheme.primary
                                      : AppTheme.brandTextOf(context))
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                option.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: mode == option.mode
                                      ? (AppTheme.isDark(context)
                                          ? theme.colorScheme.primary
                                          : AppTheme.brandTextOf(context))
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
