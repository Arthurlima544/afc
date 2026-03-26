import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/goal_entity.dart';
import '../../utils/connectivity_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/goal/goal_cubit.dart';
import '../widgets/design_system.dart';
import 'cadastrar_categoria.dart';

class CadastrarMeta extends StatefulWidget {
  const CadastrarMeta({super.key, this.initialGoal});

  final GoalEntity? initialGoal;

  @override
  State<CadastrarMeta> createState() => _CadastrarMetaState();
}

class _CadastrarMetaState extends State<CadastrarMeta> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  int _selectedIcon = 0;

  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    if (widget.initialGoal != null) {
      final GoalEntity g = widget.initialGoal!;
      _nameController.text = g.name;
      _amountController.text = g.targetAmount.toString();
      _deadline = g.deadline;
      _selectedIcon = g.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Informe o nome da meta'
          : null;
      final double? amount = double.tryParse(
        _amountController.text.replaceAll(',', '.'),
      );
      _amountError = (amount == null || amount <= 0)
          ? 'Informe um valor válido'
          : null;
    });
    return _nameError == null && _amountError == null;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
    body: BlocListener<GoalCubit, GoalState>(
    listener: (BuildContext context, GoalState state) {
      state.whenOrNull(
        success: (_) {
          if (!ConnectivityService.isOnlineSafe) {
            showOfflineSavedSnackBar(context);
          }
          context.pop();
        },
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
              widget.initialGoal != null ? 'Editar Meta' : 'Nova Meta',
              style: AppTextStyles.heading,
            ),
            const Gap(20),
            AppTextField(
              controller: _nameController,
              hintText: 'Nome da meta',
              onChanged: (_) => setState(() => _nameError = null),
            ),
            if (_nameError != null) ...<Widget>[
              const Gap(4),
              Text(
                _nameError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.expense),
              ),
            ],
            const Gap(16),
            AppTextField(
              controller: _amountController,
              hintText: 'Valor alvo (ex: 1000.00)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              onChanged: (_) => setState(() => _amountError = null),
            ),
            if (_amountError != null) ...<Widget>[
              const Gap(4),
              Text(
                _amountError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.expense),
              ),
            ],
            const Gap(16),
            Row(
              children: <Widget>[
                const Text('Prazo:', style: AppTextStyles.body),
                const Gap(12),
                OutlineButton(
                  onPressed: _pickDate,
                  child: Text(
                    '${_deadline.day.toString().padLeft(2, '0')}/'
                    '${_deadline.month.toString().padLeft(2, '0')}/'
                    '${_deadline.year}',
                  ),
                ),
              ],
            ),
            const Gap(20),
            const Text('Ícone', style: AppTextStyles.bodyBold),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (int i = 0; i < iconList.length; i++)
                  _selectedIcon == i
                      ? AppIconButton.circle(
                          onPressed: () => setState(() => _selectedIcon = i),
                          icon: Icon(iconList[i], color: AppColors.onPrimary),
                        )
                      : AppIconButton(
                          onPressed: () => setState(() => _selectedIcon = i),
                          icon: Icon(iconList[i]),
                        ),
              ],
            ),
            const Gap(24),
            BlocBuilder<GoalCubit, GoalState>(
              builder: (BuildContext context, GoalState state) {
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
                      : Text(widget.initialGoal != null ? 'Salvar' : 'Criar'),
                );
              },
            ),
          ],
        ),
      ),
    ),
  ),
  );

  void _save() {
    if (!_validate()) {
      return;
    }

    final double targetAmount = double.parse(
      _amountController.text.replaceAll(',', '.'),
    );

    context.read<AuthBloc>().state.whenOrNull(
      signedIn: (ClerkAuthState authState) {
        final String userId = authState.user?.id ?? '';
        if (widget.initialGoal != null) {
          context.read<GoalCubit>().update(
            widget.initialGoal!.copyWith(
              name: _nameController.text.trim(),
              targetAmount: targetAmount,
              deadline: _deadline,
              icon: _selectedIcon,
            ),
          );
        } else {
          context.read<GoalCubit>().create(
            GoalEntity(
              uuid: const Uuid().v1(),
              userId: userId,
              name: _nameController.text.trim(),
              targetAmount: targetAmount,
              deadline: _deadline,
              icon: _selectedIcon,
            ),
          );
        }
      },
    );
  }
}
