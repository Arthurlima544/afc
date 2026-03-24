import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/bill_entity.dart';
import '../../domain/entity/category_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/bill/bill_cubit.dart';
import '../blocs/category/category_cubit.dart';
import '../widgets/design_system.dart';

class CadastrarConta extends StatefulWidget {
  const CadastrarConta({super.key, this.initialBill});

  final BillEntity? initialBill;

  @override
  State<CadastrarConta> createState() => _CadastrarContaState();
}

class _CadastrarContaState extends State<CadastrarConta> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDayController = TextEditingController();

  String? _selectedCategoryUuid;
  String? _nameError;
  String? _amountError;
  String? _dueDayError;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    final CategoryCubit cubit = context.read<CategoryCubit>();
    Future<void>.microtask(cubit.loadCategories);
    if (widget.initialBill != null) {
      final BillEntity bill = widget.initialBill!;
      _nameController.text = bill.name;
      _amountController.text = bill.amount.toString();
      _dueDayController.text = bill.dueDay.toString();
      _selectedCategoryUuid = bill.categoryUuid;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Informe o nome'
          : null;
      final double? amount = double.tryParse(
        _amountController.text.replaceAll(',', '.'),
      );
      _amountError = (amount == null || amount <= 0) ? 'Valor inválido' : null;
      final int? day = int.tryParse(_dueDayController.text);
      _dueDayError = (day == null || day < 1 || day > 31)
          ? 'Dia deve ser entre 1 e 31'
          : null;
      _categoryError = _selectedCategoryUuid == null
          ? 'Selecione uma categoria'
          : null;
    });
    if (_nameError != null ||
        _amountError != null ||
        _dueDayError != null ||
        _categoryError != null) {
      valid = false;
    }
    return valid;
  }

  void _submit(BuildContext context) {
    if (!_validate()) {
      return;
    }

    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
          signedIn: (ClerkAuthState s) => s.user?.id,
        ) ??
        '';

    final double amount = double.parse(
      _amountController.text.replaceAll(',', '.'),
    );
    final int dueDay = int.parse(_dueDayController.text);

    if (widget.initialBill != null) {
      final BillEntity updated = widget.initialBill!.copyWith(
        name: _nameController.text.trim(),
        amount: amount,
        dueDay: dueDay,
        categoryUuid: _selectedCategoryUuid!,
      );
      context.read<BillCubit>().update(updated);
    } else {
      final BillEntity bill = BillEntity(
        uuid: const Uuid().v1(),
        userId: userId,
        name: _nameController.text.trim(),
        amount: amount,
        dueDay: dueDay,
        categoryUuid: _selectedCategoryUuid!,
      );
      context.read<BillCubit>().create(bill);
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
    unawaited(context.read<CategoryCubit>().loadCategories());
    setState(() => _selectedCategoryUuid = newCat.uuid);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  widget.initialBill != null ? 'Editar Conta' : 'Nova Conta',
                  style: AppTextStyles.heading,
                ),
              ),
            ],
          ),
          const Gap(24),
          const Text('Nome', style: AppTextStyles.label),
          const Gap(6),
          AppTextField(
            controller: _nameController,
            hintText: 'Ex: Aluguel',
            onChanged: (_) {
              if (_nameError != null) {
                setState(() => _nameError = null);
              }
            },
          ),
          if (_nameError != null) ...<Widget>[
            const Gap(4),
            Text(
              _nameError!,
              style: AppTextStyles.caption.copyWith(color: AppColors.expense),
            ),
          ],
          const Gap(16),
          const Text('Valor (R\$)', style: AppTextStyles.label),
          const Gap(6),
          AppTextField(
            controller: _amountController,
            hintText: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            onChanged: (_) {
              if (_amountError != null) {
                setState(() => _amountError = null);
              }
            },
          ),
          if (_amountError != null) ...<Widget>[
            const Gap(4),
            Text(
              _amountError!,
              style: AppTextStyles.caption.copyWith(color: AppColors.expense),
            ),
          ],
          const Gap(16),
          const Text('Dia de vencimento (1-31)', style: AppTextStyles.label),
          const Gap(6),
          AppTextField(
            controller: _dueDayController,
            hintText: 'Dia de vencimento (1-31)',
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (_) {
              if (_dueDayError != null) {
                setState(() => _dueDayError = null);
              }
            },
          ),
          if (_dueDayError != null) ...<Widget>[
            const Gap(4),
            Text(
              _dueDayError!,
              style: AppTextStyles.caption.copyWith(color: AppColors.expense),
            ),
          ],
          const Gap(16),
          const Text('Categoria', style: AppTextStyles.label),
          const Gap(8),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (BuildContext context, CategoryState state) {
              final List<CategoryEntity> categories =
                  state.whenOrNull(
                    listed: (List<CategoryEntity> cats) => cats,
                  ) ??
                  <CategoryEntity>[];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final CategoryEntity cat in categories)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryUuid = cat.uuid;
                          _categoryError = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedCategoryUuid == cat.uuid
                              ? AppColors.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.name,
                          style: AppTextStyles.label.copyWith(
                            color: _selectedCategoryUuid == cat.uuid
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
              );
            },
          ),
          if (_categoryError != null) ...<Widget>[
            const Gap(4),
            Text(
              _categoryError!,
              style: AppTextStyles.caption.copyWith(color: AppColors.expense),
            ),
          ],
          const Gap(24),
          BlocConsumer<BillCubit, BillState>(
            listener: (BuildContext context, BillState state) {
              state.whenOrNull(
                success: (_) => context.pop(),
                error: (String msg) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    ),
              );
            },
            builder: (BuildContext context, BillState state) {
              final bool isLoading = state == const BillState.loading();
              return SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: isLoading ? null : () => _submit(context),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          widget.initialBill != null ? 'Salvar' : 'Cadastrar',
                        ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  ),
  );
}
