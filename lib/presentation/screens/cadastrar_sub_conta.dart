import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/sub_account_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/sub_account/sub_account_cubit.dart';
import '../widgets/design_system.dart';

class CadastrarSubConta extends StatefulWidget {
  const CadastrarSubConta({super.key, this.initialAccount});

  final SubAccountEntity? initialAccount;

  @override
  State<CadastrarSubConta> createState() => _CadastrarSubContaState();
}

class _CadastrarSubContaState extends State<CadastrarSubConta> {
  final TextEditingController _nameController = TextEditingController();

  SubAccountType _selectedType = SubAccountType.personal;
  int _selectedColor = 0xFF2196F3;

  String? _nameError;

  static const List<int> _colors = <int>[
    0xFF2196F3,
    0xFF4CAF50,
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
    if (widget.initialAccount != null) {
      final SubAccountEntity a = widget.initialAccount!;
      _nameController.text = a.name;
      _selectedType = a.type;
      _selectedColor = a.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Informe o nome da conta'
          : null;
    });
    return _nameError == null;
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
    if (widget.initialAccount != null) {
      final SubAccountEntity updated = widget.initialAccount!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        color: _selectedColor,
      );
      context.read<SubAccountCubit>().update(updated);
    } else {
      context.read<SubAccountCubit>().create(
        SubAccountEntity(
          uuid: const Uuid().v4(),
          userId: userId,
          name: _nameController.text.trim(),
          type: _selectedType,
          color: _selectedColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
    body: BlocListener<SubAccountCubit, SubAccountState>(
      listener: (BuildContext context, SubAccountState state) {
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
                widget.initialAccount != null
                    ? 'Editar Sub-conta'
                    : 'Nova Sub-conta',
                style: AppTextStyles.heading,
              ),
              const Gap(20),
              AppTextField(
                controller: _nameController,
                hintText: 'Nome (ex: Pessoal, Empresa, Cartão PJ)',
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
                  for (final SubAccountType type in SubAccountType.values)
                    ChoiceChip(
                      label: Text(_typeLabel(type)),
                      selected: _selectedType == type,
                      onSelected: (_) =>
                          setState(() => _selectedType = type),
                    ),
                ],
              ),
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
              BlocBuilder<SubAccountCubit, SubAccountState>(
                builder: (BuildContext context, SubAccountState state) {
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
                            widget.initialAccount != null ? 'Salvar' : 'Criar',
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

  static String _typeLabel(SubAccountType type) => switch (type) {
    SubAccountType.personal => 'Pessoal',
    SubAccountType.company => 'Empresa',
    SubAccountType.benefit => 'Benefício',
  };
}
