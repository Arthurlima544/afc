import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../../domain/entity/frequency_entity.dart';
import '../../domain/entity/recurring_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/logger.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/recurring/recurring_cubit.dart';
import '../blocs/transaction/transaction_cubit.dart';
import '../widgets/design_system.dart';

class CadastrarRecorrente extends StatefulWidget {
  const CadastrarRecorrente({super.key});

  @override
  State<CadastrarRecorrente> createState() => _CadastrarRecorrenteState();
}

class _CadastrarRecorrenteState extends State<CadastrarRecorrente> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _typeValue;
  String? _categoryUuid;
  String _frequency = FrequencyEntity.monthly.name;
  DateTime? _startDate;

  String? _typeError;
  String? _categoryError;
  String? _dateError;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _typeError = _typeValue == null ? 'Selecione o tipo' : null;
      _categoryError = _categoryUuid == null ? 'Selecione uma categoria' : null;
      _dateError = _startDate == null ? 'Selecione a data de início' : null;
    });
    return _typeError == null && _categoryError == null && _dateError == null;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _dateError = null;
      });
      logger.d('Start date: $_startDate');
    }
  }

  String _frequencyLabel(String freq) {
    switch (freq) {
      case 'daily':
        return 'Diário';
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensal';
      default:
        return freq;
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
        child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (BuildContext context, TransactionState state) => state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (String msg) => Center(child: Text(msg)),
          success: (_) => const SizedBox(),
          listed: (_) => const SizedBox(),
          initial: (List<CategoryEntity> categories) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Nova Recorrência', style: AppTextStyles.heading),
              const Gap(24),

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

              // Type
              DropdownButtonFormField<String>(
                initialValue: _typeValue,
                hint: const Text('Tipo'),
                decoration: const InputDecoration(),
                onChanged: (String? v) => setState(() {
                  _typeValue = v;
                  _typeError = null;
                }),
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

              // Frequency
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: const InputDecoration(),
                onChanged: (String? v) =>
                    setState(() => _frequency = v ?? _frequency),
                items: FrequencyEntity.values
                    .map(
                      (FrequencyEntity f) => DropdownMenuItem<String>(
                        value: f.name,
                        child: Text(_frequencyLabel(f.name)),
                      ),
                    )
                    .toList(),
              ),
              const Gap(16),

              // Start date
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(
                  _startDate == null
                      ? 'Selecionar data de início'
                      : '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}',
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
              const Gap(24),

              PrimaryButton(
                onPressed: () {
                  if (!_validate()) {
                    return;
                  }
                  final double amount =
                      double.tryParse(
                        _amountController.text.replaceAll(',', '.'),
                      ) ??
                      0;
                  final CategoryEntity selectedCategory = categories.firstWhere(
                    (CategoryEntity c) => c.uuid == _categoryUuid,
                  );
                  context.read<AuthBloc>().state.whenOrNull(
                    signedIn: (ClerkAuthState auth) {
                      final String userId = auth.user?.id ?? '';
                      final String txUuid = const Uuid().v1();
                      final TransactionEntity template = TransactionEntity(
                        uuid: txUuid,
                        amount: amount,
                        categoryUUid: selectedCategory.uuid,
                        typeUuid: _typeValue!,
                        data: _startDate!,
                        title: _titleController.text,
                        userId: userId,
                      );
                      context.read<RecurringCubit>().create(
                        RecurringEntity(
                          uuid: const Uuid().v1(),
                          userId: userId,
                          templateTransaction: template,
                          frequency: _frequency,
                          nextDue: _startDate!,
                          active: true,
                        ),
                      );
                    },
                  );
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  );
}
