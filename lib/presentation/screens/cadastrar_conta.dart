import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/bill_entity.dart';
import '../../domain/entity/category_entity.dart';
import '../../utils/app_spacing.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/bill/bill_cubit.dart';
import '../blocs/category/category_cubit.dart';

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
      _nameError = _nameController.text.trim().isEmpty ? 'Informe o nome' : null;
      final double? amount = double.tryParse(
        _amountController.text.replaceAll(',', '.'),
      );
      _amountError = (amount == null || amount <= 0) ? 'Valor inválido' : null;
      final int? day = int.tryParse(_dueDayController.text);
      _dueDayError =
          (day == null || day < 1 || day > 31) ? 'Dia deve ser entre 1 e 31' : null;
      _categoryError =
          _selectedCategoryUuid == null ? 'Selecione uma categoria' : null;
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

  @override
  Widget build(BuildContext context) => Scaffold(
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  variance: const ButtonStyle.outline(),
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    widget.initialBill != null
                        ? 'Editar Conta'
                        : 'Nova Conta',
                    style: AppTextStyles.heading,
                  ),
                ),
              ],
            ),
            const Gap(24),
            const Text('Nome', style: AppTextStyles.label),
            const Gap(6),
            TextField(
              controller: _nameController,
              placeholder: const Text('Ex: Aluguel'),
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
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.expense,
                ),
              ),
            ],
            const Gap(16),
            const Text('Valor (R\$)', style: AppTextStyles.label),
            const Gap(6),
            TextField(
              controller: _amountController,
              placeholder: const Text('0.00'),
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
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.expense,
                ),
              ),
            ],
            const Gap(16),
            const Text('Dia de vencimento (1-31)', style: AppTextStyles.label),
            const Gap(6),
            TextField(
              controller: _dueDayController,
              placeholder: const Text('Dia de vencimento (1-31)'),
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
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.expense,
                ),
              ),
            ],
            const Gap(16),
            const Text('Categoria', style: AppTextStyles.label),
            const Gap(8),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (BuildContext context, CategoryState state) {
                final List<CategoryEntity> categories = state.whenOrNull(
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
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat.name,
                            style: AppTextStyles.label.copyWith(
                              color: _selectedCategoryUuid == cat.uuid
                                  ? const Color(0xFFFFFFFF)
                                  : null,
                            ),
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
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.expense,
                ),
              ),
            ],
            const Gap(24),
            BlocConsumer<BillCubit, BillState>(
              listener: (BuildContext context, BillState state) {
                state.whenOrNull(
                  success: (_) => context.pop(),
                );
              },
              builder: (BuildContext context, BillState state) {
                final bool isLoading = state == const BillState.loading();
                return SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: isLoading ? null : () => _submit(context),
                    child: isLoading
                        ? const CircularProgressIndicator(size: 20)
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
