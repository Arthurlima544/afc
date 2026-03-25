import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/benefit_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/benefit/benefit_cubit.dart';
import '../widgets/design_system.dart';

class CadastrarBeneficio extends StatefulWidget {
  const CadastrarBeneficio({super.key, this.initialBenefit});

  final BenefitEntity? initialBenefit;

  @override
  State<CadastrarBeneficio> createState() => _CadastrarBeneficioState();
}

class _CadastrarBeneficioState extends State<CadastrarBeneficio> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();

  BenefitType _selectedType = BenefitType.va;
  int _selectedColor = 0xFF4CAF50;

  String? _nameError;
  String? _creditError;

  static const List<int> _colors = <int>[
    0xFF4CAF50,
    0xFF2196F3,
    0xFFF44336,
    0xFFFF9800,
    0xFF9C27B0,
    0xFF009688,
    0xFFE91E63,
    0xFF607D8B,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialBenefit != null) {
      final BenefitEntity b = widget.initialBenefit!;
      _nameController.text = b.name;
      _creditController.text = b.monthlyCredit.toString();
      _selectedType = b.type;
      _selectedColor = b.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Informe o nome do benefício'
          : null;
      final double? credit = double.tryParse(
        _creditController.text.replaceAll(',', '.'),
      );
      _creditError = (credit == null || credit <= 0)
          ? 'Informe um valor válido'
          : null;
    });
    return _nameError == null && _creditError == null;
  }

  void _save() {
    if (!_validate()) {
      return;
    }
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';
    final double credit = double.parse(
      _creditController.text.replaceAll(',', '.'),
    );
    if (widget.initialBenefit != null) {
      final BenefitEntity updated = widget.initialBenefit!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        monthlyCredit: credit,
        color: _selectedColor,
      );
      context.read<BenefitCubit>().update(updated);
    } else {
      context.read<BenefitCubit>().create(
        BenefitEntity(
          uuid: const Uuid().v4(),
          userId: userId,
          name: _nameController.text.trim(),
          type: _selectedType,
          monthlyCredit: credit,
          balance: credit,
          color: _selectedColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
    body: BlocListener<BenefitCubit, BenefitState>(
      listener: (BuildContext context, BenefitState state) {
        state.whenOrNull(
          success: (_) => context.pop(),
          error: (String msg) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          ),
        );
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.initialBenefit != null
                    ? 'Editar Benefício'
                    : 'Novo Benefício',
                style: AppTextStyles.heading,
              ),
              const Gap(20),
              AppTextField(
                controller: _nameController,
                hintText: 'Nome (ex: VA Sodexo)',
                onChanged: (_) => setState(() => _nameError = null),
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
              const Text('Tipo', style: AppTextStyles.bodyBold),
              const Gap(8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final BenefitType type in BenefitType.values)
                    ChoiceChip(
                      label: Text(_typeLabel(type)),
                      selected: _selectedType == type,
                      onSelected: (_) =>
                          setState(() => _selectedType = type),
                    ),
                ],
              ),
              const Gap(16),
              AppTextField(
                controller: _creditController,
                hintText: 'Crédito mensal (ex: 500.00)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                onChanged: (_) => setState(() => _creditError = null),
              ),
              if (_creditError != null) ...<Widget>[
                const Gap(4),
                Text(
                  _creditError!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.expense,
                  ),
                ),
              ],
              const Gap(16),
              const Text('Cor', style: AppTextStyles.bodyBold),
              const Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final int color in _colors)
                    GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(24),
              BlocBuilder<BenefitCubit, BenefitState>(
                builder: (BuildContext context, BenefitState state) {
                  final bool isLoading =
                      state.whenOrNull(loading: () => true) ?? false;
                  return PrimaryButton(
                    onPressed: isLoading ? null : _save,
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
                            widget.initialBenefit != null
                                ? 'Salvar'
                                : 'Criar',
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  static String _typeLabel(BenefitType type) => switch (type) {
    BenefitType.va => 'Vale Alimentação',
    BenefitType.vt => 'Vale Transporte',
    BenefitType.vr => 'Vale Refeição',
    BenefitType.other => 'Outro',
  };
}
