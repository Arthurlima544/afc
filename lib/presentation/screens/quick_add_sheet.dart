import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../../domain/entity/sub_account_entity.dart';
import '../../domain/entity/template_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../blocs/receipt_ocr/receipt_ocr_cubit.dart';
import '../blocs/sub_account/sub_account_cubit.dart';
import '../blocs/template/template_cubit.dart';
import '../blocs/transaction/transaction_cubit.dart';
import '../widgets/design_system.dart';

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({required this.userId, required this.onClose, super.key});

  final String userId;
  final VoidCallback onClose;

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final TransactionCubit _cubit = TransactionCubit()..getCategories();
  late final TemplateCubit _templateCubit = TemplateCubit()
    ..loadTemplates(widget.userId);
  final ReceiptOcrCubit _ocrCubit = ReceiptOcrCubit();
  late final SubAccountCubit _subAccountCubit = SubAccountCubit()
    ..loadAccounts(widget.userId);

  String _amountBuffer = '';
  String _type = TypeEntity.expense.name;
  String? _categoryUuid;
  String? _subAccountUuid;
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    _templateCubit.close();
    _ocrCubit.close();
    _subAccountCubit.close();
    _titleController.dispose();
    super.dispose();
  }

  void _applyTemplate(TemplateEntity template) {
    setState(() {
      _amountBuffer = template.amount.toString();
      _type = template.typeUuid;
      _categoryUuid = template.categoryUUid;
      _titleController.text = template.title;
    });
  }

  double get _amount => double.tryParse(_amountBuffer) ?? 0.0;

  String get _displayAmount {
    if (_amountBuffer.isEmpty) {
      return 'R\$ 0';
    }
    final double? parsed = double.tryParse(_amountBuffer);
    if (parsed == null) {
      return 'R\$ $_amountBuffer';
    }
    return 'R\$ $_amountBuffer';
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountBuffer.isNotEmpty) {
          _amountBuffer = _amountBuffer.substring(0, _amountBuffer.length - 1);
        }
      } else if (key == '.') {
        if (!_amountBuffer.contains('.')) {
          _amountBuffer = _amountBuffer.isEmpty ? '0.' : '$_amountBuffer.';
        }
      } else {
        if (_amountBuffer.length < 10) {
          _amountBuffer += key;
        }
      }
    });
  }

  Future<void> _showAddCategoryDialog() async {
    final String? name = await showInputDialog(
      context: context,
      title: 'Nova categoria',
      hintText: 'Nome da categoria',
    );
    if (name == null || !mounted) {
      return;
    }
    final CategoryEntity newCat = CategoryEntity(
      uuid: const Uuid().v1(),
      name: name,
      iconType: 0,
    );
    await FirebaseFirestore.instance
        .collection('category')
        .add(newCat.toJson());
    await _cubit.getCategories();
    if (mounted) {
      setState(() => _categoryUuid = newCat.uuid);
    }
  }

  Future<void> _save(List<CategoryEntity> categories) async {
    if (_categoryUuid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma categoria')));
      return;
    }
    if (_amount <= 0) {
      return;
    }
    final String title = _titleController.text.trim().isEmpty
        ? (categories
                  .where((CategoryEntity c) => c.uuid == _categoryUuid)
                  .firstOrNull
                  ?.name ??
              '')
        : _titleController.text.trim();

    await _cubit.saveTransaction(
      TransactionEntity(
        uuid: const Uuid().v1(),
        amount: _amount,
        categoryUUid: _categoryUuid!,
        typeUuid: _type,
        data: DateTime.now(),
        title: title,
        userId: widget.userId,
        subAccountUuid: _subAccountUuid,
      ),
    );
    await HapticFeedback.mediumImpact();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<TransactionCubit>.value(value: _cubit),
      BlocProvider<TemplateCubit>.value(value: _templateCubit),
      BlocProvider<ReceiptOcrCubit>.value(value: _ocrCubit),
      BlocProvider<SubAccountCubit>.value(value: _subAccountCubit),
    ],
    child: BlocListener<ReceiptOcrCubit, ReceiptOcrState>(
      listener: (BuildContext context, ReceiptOcrState ocrState) {
        ocrState.whenOrNull(
          success: (double? amount, String? merchant) {
            setState(() {
              if (amount != null && amount > 0) {
                _amountBuffer = amount
                    .toStringAsFixed(2)
                    .replaceAll(RegExp(r'\.?0+$'), '');
              }
              if (merchant != null && merchant.isNotEmpty) {
                _titleController.text = merchant;
              }
            });
          },
        );
      },
      child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (BuildContext ctx, TransactionState state) {
          final List<CategoryEntity> categories =
              state.whenOrNull(initial: (List<CategoryEntity> cats) => cats) ??
              <CategoryEntity>[];

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.muted.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Templates shelf
                    BlocBuilder<TemplateCubit, TemplateState>(
                      builder:
                          (BuildContext context, TemplateState templateState) {
                            final List<TemplateEntity> templates =
                                templateState.whenOrNull(
                                  listed: (List<TemplateEntity> t) => t,
                                ) ??
                                <TemplateEntity>[];
                            if (templates.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Modelos',
                                  style: AppTextStyles.labelBold,
                                ),
                                const Gap(8),
                                SizedBox(
                                  height: 36,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: templates.length,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Gap(8),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final TemplateEntity t =
                                              templates[index];
                                          return GestureDetector(
                                            onTap: () => _applyTemplate(t),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.muted
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: AppColors.muted
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text(
                                                t.title,
                                                style: AppTextStyles.label,
                                              ),
                                            ),
                                          );
                                        },
                                  ),
                                ),
                                const Gap(16),
                              ],
                            );
                          },
                    ),

                    // Amount display
                    Center(
                      child: Text(_displayAmount, style: AppTextStyles.display),
                    ),
                    const Gap(16),

                    // Income / Expense toggle
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _type == TypeEntity.income.name
                              ? PrimaryButton(
                                  onPressed: () => setState(
                                    () => _type = TypeEntity.income.name,
                                  ),
                                  child: const Text('Receita'),
                                )
                              : OutlineButton(
                                  onPressed: () => setState(
                                    () => _type = TypeEntity.income.name,
                                  ),
                                  child: const Text('Receita'),
                                ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: _type == TypeEntity.expense.name
                              ? PrimaryButton(
                                  onPressed: () => setState(
                                    () => _type = TypeEntity.expense.name,
                                  ),
                                  child: const Text('Despesa'),
                                )
                              : OutlineButton(
                                  onPressed: () => setState(
                                    () => _type = TypeEntity.expense.name,
                                  ),
                                  child: const Text('Despesa'),
                                ),
                        ),
                      ],
                    ),
                    const Gap(16),

                    // Category chips
                    const Text('Categoria', style: AppTextStyles.labelBold),
                    const Gap(8),
                    if (state.whenOrNull(loading: () => true) == true)
                      const Center(child: CircularProgressIndicator())
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (final CategoryEntity cat in categories)
                            GestureDetector(
                              onTap: () => setState(() {
                                _categoryUuid = cat.uuid;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _categoryUuid == cat.uuid
                                      ? AppColors.primary
                                      : AppColors.muted.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _categoryUuid == cat.uuid
                                        ? AppColors.primary
                                        : AppColors.muted.withValues(
                                            alpha: 0.3,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _categoryUuid == cat.uuid
                                        ? AppColors.onPrimary
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          // "+" chip to create a new category inline
                          GestureDetector(
                            onTap: _showAddCategoryDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.muted.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    size: 14,
                                    color: AppColors.muted,
                                  ),
                                  Gap(4),
                                  Text(
                                    'Nova',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    const Gap(16),

                    // Optional title
                    AppTextField(
                      controller: _titleController,
                      hintText: 'Título (opcional)',
                    ),
                    const Gap(16),

                    // OCR scan — camera / gallery buttons + error feedback
                    BlocBuilder<ReceiptOcrCubit, ReceiptOcrState>(
                      builder: (BuildContext context, ReceiptOcrState ocrState) {
                        final bool isLoading =
                            ocrState.whenOrNull(loading: () => true) == true;
                        final String? errorMsg = ocrState.whenOrNull(
                          error: (String m) => m,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: OutlineButton(
                                      onPressed: () => context
                                          .read<ReceiptOcrCubit>()
                                          .pickAndScan(),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.camera_alt_outlined,
                                            size: 18,
                                          ),
                                          Gap(6),
                                          Text('Câmera'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: OutlineButton(
                                      onPressed: () => context
                                          .read<ReceiptOcrCubit>()
                                          .pickAndScan(fromCamera: false),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.photo_library_outlined,
                                            size: 18,
                                          ),
                                          Gap(6),
                                          Text('Galeria'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (errorMsg != null) ...<Widget>[
                              const Gap(6),
                              Text(
                                'Falha ao ler o comprovante. Tente novamente.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.expense,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const Gap(16),

                    // Sub-account chips (only when ≥ 1 exists)
                    BlocBuilder<SubAccountCubit, SubAccountState>(
                      builder: (
                        BuildContext context,
                        SubAccountState saState,
                      ) {
                        final List<SubAccountEntity> accounts =
                            saState.whenOrNull(
                              listed: (List<SubAccountEntity> a, _) => a,
                            ) ??
                            <SubAccountEntity>[];
                        if (accounts.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Sub-conta',
                              style: AppTextStyles.labelBold,
                            ),
                            const Gap(8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                for (final SubAccountEntity acc in accounts)
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _subAccountUuid =
                                          _subAccountUuid == acc.uuid
                                          ? null
                                          : acc.uuid;
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _subAccountUuid == acc.uuid
                                            ? Color(acc.color)
                                            : AppColors.muted.withValues(
                                                alpha: 0.15,
                                              ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _subAccountUuid == acc.uuid
                                              ? Color(acc.color)
                                              : AppColors.muted.withValues(
                                                  alpha: 0.3,
                                                ),
                                        ),
                                      ),
                                      child: Text(
                                        acc.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _subAccountUuid == acc.uuid
                                              ? AppColors.onPrimary
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(16),
                          ],
                        );
                      },
                    ),

                    // Numpad
                    _Numpad(onKey: _onKey),
                    const Gap(16),

                    // Save button
                    PrimaryButton(
                      onPressed: _amount > 0 ? () => _save(categories) : null,
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onKey});

  final void Function(String) onKey;

  static const List<String> _keys = <String>[
    '7',
    '8',
    '9',
    '4',
    '5',
    '6',
    '1',
    '2',
    '3',
    '.',
    '0',
    '⌫',
  ];

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 3,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 2.5,
    children: <Widget>[
      for (final String key in _keys)
        OutlineButton(
          onPressed: () => onKey(key),
          child: Text(key, style: AppTextStyles.sectionTitle),
        ),
    ],
  );
}
