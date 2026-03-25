import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../../domain/entity/sub_account_entity.dart';
import '../../domain/entity/template_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/logger.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/sub_account/sub_account_cubit.dart';
import '../blocs/template/template_cubit.dart';
import '../blocs/transaction/transaction_cubit.dart';
import '../widgets/design_system.dart';

class CadastrarTransacao extends StatefulWidget {
  const CadastrarTransacao({super.key, this.initialTransaction});

  final TransactionEntity? initialTransaction;

  @override
  State<CadastrarTransacao> createState() => _CadastrarTransacaoState();
}

class _CadastrarTransacaoState extends State<CadastrarTransacao> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime? _selectedDate;
  String? _typeValue;
  String? _categoryUuid;

  bool _saveAsTemplate = false;

  String? _subAccountUuid;

  String? _dateError;
  String? _typeError;
  String? _categoryError;

  final TemplateCubit _templateCubit = TemplateCubit();
  final SubAccountCubit _subAccountCubit = SubAccountCubit();

  @override
  void initState() {
    super.initState();
    final TransactionCubit cubit = context.read<TransactionCubit>();
    Future<void>.microtask(cubit.getCategories);
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';
    Future<void>.microtask(() => _subAccountCubit.loadAccounts(userId));
    final TransactionEntity? tx = widget.initialTransaction;
    if (tx != null) {
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toString();
      _selectedDate = tx.data;
      _typeValue = TypeEntity.values.any((TypeEntity t) => t.name == tx.typeUuid)
          ? tx.typeUuid
          : null;
      _categoryUuid = tx.categoryUUid;
      _subAccountUuid = tx.subAccountUuid;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _templateCubit.close();
    _subAccountCubit.close();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _dateError = _selectedDate == null ? 'Selecione uma data' : null;
      _typeError = _typeValue == null ? 'Selecione o tipo' : null;
      _categoryError = _categoryUuid == null ? 'Selecione uma categoria' : null;
    });
    return _dateError == null && _typeError == null && _categoryError == null;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
      logger.d('Date picked $_selectedDate');
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final String? name = await showInputDialog(
      context: context,
      title: 'Nova categoria',
      hintText: 'Nome da categoria',
    );
    if (name == null || name.trim().isEmpty || !mounted) {
      return;
    }
    final CategoryEntity newCat = CategoryEntity(
      uuid: const Uuid().v1(),
      name: name.trim(),
      iconType: 0,
    );
    await FirebaseFirestore.instance
        .collection('category')
        .add(newCat.toJson());
    if (!mounted) {
      return;
    }
    unawaited(context.read<TransactionCubit>().getCategories());
    setState(() => _categoryUuid = newCat.uuid);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocConsumer<TransactionCubit, TransactionState>(
        listener: (BuildContext context, TransactionState state) {
          state.whenOrNull(
            success: (_) => context.pop(),
            error: (String msg) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            ),
            initial: (List<CategoryEntity> categories) {
              final TransactionEntity? tx = widget.initialTransaction;
              if (tx != null && _categoryUuid != null) {
                return;
              }
            },
          );
        },
        builder: (BuildContext context, TransactionState state) => state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (String message) => Center(child: Text(message)),
          success: (_) => const SizedBox(),
          listed: (_) => const SizedBox(),
          initial: (List<CategoryEntity> categories) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.initialTransaction != null
                    ? 'Editar Transação'
                    : 'Nova Transação',
                style: AppTextStyles.heading,
              ),
              const Gap(24),

              // Date picker
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null
                      ? 'Selecionar data'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                ),
              ),
              if (_dateError != null) ...<Widget>[
                const Gap(4),
                Text(
                  _dateError!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.expense,
                  ),
                ),
              ],
              const Gap(16),

              // Title
              AppTextField(controller: _titleController, hintText: 'Título'),
              const Gap(16),

              // Amount
              AppTextField(
                controller: _amountController,
                hintText: 'Valor',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const Gap(16),

              // Type dropdown
              DropdownButtonFormField<String>(
                initialValue: _typeValue,
                hint: const Text('Tipo'),
                decoration: const InputDecoration(),
                onChanged: (String? value) {
                  setState(() {
                    _typeValue = value;
                    _typeError = null;
                  });
                },
                items: TypeEntity.values
                    .map(
                      (TypeEntity t) => DropdownMenuItem<String>(
                        value: t.name,
                        child: Text(t.name),
                      ),
                    )
                    .toList(),
              ),
              if (_typeError != null) ...<Widget>[
                const Gap(4),
                Text(
                  _typeError!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.expense,
                  ),
                ),
              ],
              const Gap(16),

              // Category chips
              const Text('Categoria', style: AppTextStyles.labelBold),
              const Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final CategoryEntity cat in categories)
                    GestureDetector(
                      onTap: () => setState(() {
                        _categoryUuid = cat.uuid;
                        _categoryError = null;
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
                                : AppColors.muted.withValues(alpha: 0.3),
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
                  // "+" chip — inline category creation
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
                          Icon(Icons.add, size: 14, color: AppColors.muted),
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
              if (_categoryError != null) ...<Widget>[
                const Gap(4),
                Text(
                  _categoryError!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.expense,
                  ),
                ),
              ],
              const Gap(16),

              // Sub-account selector (only shown when ≥ 1 sub-account exists)
              BlocBuilder<SubAccountCubit, SubAccountState>(
                bloc: _subAccountCubit,
                builder: (BuildContext context, SubAccountState saState) {
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
                      const Text('Sub-conta', style: AppTextStyles.labelBold),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (final SubAccountEntity acc in accounts)
                            GestureDetector(
                              onTap: () => setState(() {
                                _subAccountUuid = _subAccountUuid == acc.uuid
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
                                      : AppColors.muted.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _subAccountUuid == acc.uuid
                                        ? Color(acc.color)
                                        : AppColors.muted.withValues(alpha: 0.3),
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

              // Save as template
              if (widget.initialTransaction == null) ...<Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _saveAsTemplate,
                      onChanged: (_) =>
                          setState(() => _saveAsTemplate = !_saveAsTemplate),
                    ),
                    const Gap(8),
                    const Text(
                      'Salvar como modelo',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
                const Gap(16),
              ],

              PrimaryButton(
                onPressed: () {
                  if (!_validate()) {
                    return;
                  }
                  final double money =
                      double.tryParse(
                        _amountController.text.replaceAll(',', '.'),
                      ) ??
                      0;
                  context.read<AuthBloc>().state.whenOrNull(
                    signedIn: (ClerkAuthState authState) {
                      final String userId = authState.user?.id ?? '';
                      if (widget.initialTransaction != null) {
                        context.read<TransactionCubit>().updateTransaction(
                          TransactionEntity(
                            uuid: widget.initialTransaction!.uuid,
                            amount: money,
                            categoryUUid: _categoryUuid!,
                            typeUuid: _typeValue ?? '',
                            data: _selectedDate ?? DateTime.now(),
                            title: _titleController.text,
                            userId: userId,
                            subAccountUuid: _subAccountUuid,
                          ),
                        );
                      } else {
                        final String title = _titleController.text;
                        context.read<TransactionCubit>().saveTransaction(
                          TransactionEntity(
                            uuid: const Uuid().v1(),
                            amount: money,
                            categoryUUid: _categoryUuid!,
                            typeUuid: _typeValue ?? '',
                            data: _selectedDate ?? DateTime.now(),
                            title: title,
                            userId: userId,
                            subAccountUuid: _subAccountUuid,
                          ),
                        );
                        if (_saveAsTemplate) {
                          final CategoryEntity cat = categories.firstWhere(
                            (CategoryEntity c) => c.uuid == _categoryUuid,
                          );
                          _templateCubit.save(
                            TemplateEntity(
                              uuid: const Uuid().v1(),
                              userId: userId,
                              title: title.isEmpty ? cat.name : title,
                              amount: money,
                              categoryUUid: _categoryUuid!,
                              typeUuid: _typeValue ?? '',
                            ),
                          );
                        }
                      }
                    },
                  );
                },
                child: Text(
                  widget.initialTransaction != null ? 'Salvar' : 'Adicionar',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
