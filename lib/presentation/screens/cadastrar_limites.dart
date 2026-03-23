import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/calendar_entity.dart';
import '../../domain/entity/category_entity.dart';
import '../../domain/entity/limit_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/limit/limit_cubit.dart';
import '../widgets/design_system.dart';

class CadastrarLimites extends StatefulWidget {
  const CadastrarLimites({super.key, this.initialLimit});

  final LimitEntity? initialLimit;

  @override
  State<CadastrarLimites> createState() => _CadastrarLimitesState();
}

class _CadastrarLimitesState extends State<CadastrarLimites> {
  final TextEditingController _amountController = TextEditingController();
  String? _monthValue;
  String? _categoryUuid;

  String? _monthError;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    final LimitCubit cubit = context.read<LimitCubit>();
    Future<void>.microtask(cubit.getCategories);
    if (widget.initialLimit != null) {
      final LimitEntity limit = widget.initialLimit!;
      _amountController.text = limit.limitAmount.toString();
      _monthValue = CalendarEntity.values.any(
        (CalendarEntity m) => m.name == limit.month,
      )
          ? limit.month
          : null;
      _categoryUuid = limit.categoryUUid;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _monthError = _monthValue == null ? 'Selecione o mês' : null;
      _categoryError = _categoryUuid == null ? 'Selecione uma categoria' : null;
    });
    return _monthError == null && _categoryError == null;
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
    unawaited(context.read<LimitCubit>().getCategories());
    setState(() => _categoryUuid = newCat.uuid);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocConsumer<LimitCubit, LimitState>(
        listener: (BuildContext context, LimitState state) {
          state.whenOrNull(
            initial: (List<CategoryEntity> categories) {
              if (widget.initialLimit != null && _categoryUuid == null) {
                for (final CategoryEntity cat in categories) {
                  if (cat.uuid == widget.initialLimit!.categoryUUid) {
                    setState(() => _categoryUuid = cat.uuid);
                    break;
                  }
                }
              }
            },
          );
        },
        builder: (BuildContext context, LimitState state) => state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (String message) => Center(child: Text(message)),
          loaded: (_) => const SizedBox(),
          listed: (_) => const SizedBox(),
          success: (_) => const SizedBox(),
          initial: (List<CategoryEntity> categories) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.initialLimit != null ? 'Editar Limite' : 'Novo Limite',
                style: AppTextStyles.heading,
              ),
              const Gap(24),

              // Amount
              AppTextField(
                controller: _amountController,
                hintText: 'Valor do limite',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const Gap(16),

              // Month dropdown
              DropdownButtonFormField<String>(
                initialValue: _monthValue,
                hint: const Text('Mês'),
                decoration: const InputDecoration(),
                onChanged: (String? value) {
                  setState(() {
                    _monthValue = value;
                    _monthError = null;
                  });
                },
                items: CalendarEntity.values
                    .map(
                      (CalendarEntity m) => DropdownMenuItem<String>(
                        value: m.name,
                        child: Text(m.name),
                      ),
                    )
                    .toList(),
              ),
              if (_monthError != null) ...<Widget>[
                const Gap(4),
                Text(
                  _monthError!,
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
                  context.read<AuthBloc>().state.whenOrNull(
                    signedIn: (ClerkAuthState authState) {
                      final String userId = authState.user?.id ?? '';
                      if (widget.initialLimit != null) {
                        context.read<LimitCubit>().updateLimit(
                          LimitEntity(
                            uuid: widget.initialLimit!.uuid,
                            limitAmount: amount,
                            categoryUUid: _categoryUuid!,
                            month: _monthValue ?? '',
                            userId: userId,
                          ),
                        );
                      } else {
                        context.read<LimitCubit>().saveLimit(
                          LimitEntity(
                            uuid: const Uuid().v1(),
                            limitAmount: amount,
                            categoryUUid: _categoryUuid!,
                            month: _monthValue ?? '',
                            userId: userId,
                          ),
                        );
                      }
                    },
                  );
                },
                child: Text(
                  widget.initialLimit != null ? 'Salvar' : 'Adicionar',
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
