import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart'
    hide
        Card,
        Colors,
        Theme,
        TextField,
        IconButton,
        ButtonStyle;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide AlertDialog, Column, Row, Expanded, showDialog, LinearProgressIndicator;

import '../../domain/entity/goal_entity.dart';
import '../../utils/app_spacing.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/goal/goal_cubit.dart';
import '../screens/cadastrar_categoria.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';

class ListaMetas extends StatelessWidget {
  const ListaMetas({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        unawaited(context.read<GoalCubit>().loadGoals(userId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text('Metas', style: AppTextStyles.heading),
                ),
                IconButton(
                  variance: const ButtonStyle.outline(),
                  onPressed: () => context.push('/cadastro-meta'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Gap(16),
            BlocBuilder<GoalCubit, GoalState>(
              builder: (BuildContext context, GoalState state) =>
                  state.when(
                    initial: () => const SizedBox(),
                    loading: () => const SkeletonList(),
                    error: (String msg) => ErrorState(
                      message: msg,
                      onRetry: () {
                        final String userId = context
                                .read<AuthBloc>()
                                .state
                                .whenOrNull(
                                  signedIn: (ClerkAuthState s) => s.user?.id,
                                ) ??
                            '';
                        context.read<GoalCubit>().loadGoals(userId);
                      },
                    ),
                    success: (_) => const SizedBox(),
                    listed: (List<GoalEntity> goals) => goals.isEmpty
                        ? const EmptyState(
                            message:
                                'Nenhuma meta ainda.\nToque em + para criar.',
                            icon: Icons.savings_outlined,
                          )
                        : Column(
                            children: <Widget>[
                              for (final GoalEntity goal in goals)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _MetaItem(goal: goal),
                                ),
                            ],
                          ),
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.goal});

  final GoalEntity goal;

  Color _progressColor(double ratio) {
    if (ratio >= 1.0) {
      return AppColors.income;
    }
    if (ratio > 0.8) {
      return AppColors.warning;
    }
    return const Color(0xFF6366F1);
  }

  String _daysLabel() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime deadline = DateTime(
      goal.deadline.year,
      goal.deadline.month,
      goal.deadline.day,
    );
    final int days = deadline.difference(today).inDays;
    if (days < 0) {
      return 'Prazo encerrado';
    }
    return '$days dias restantes';
  }

  @override
  Widget build(BuildContext context) {
    final double ratio = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final Color barColor = _progressColor(ratio);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(iconList[goal.icon % iconList.length], size: 24),
                const Gap(12),
                Expanded(
                  child: Text(goal.name, style: AppTextStyles.title),
                ),
                IconButton(
                  variance: const ButtonStyle.outline(),
                  onPressed: () =>
                      context.push('/editar-meta', extra: goal),
                  icon: const Icon(Icons.edit, size: 18),
                ),
                IconButton(
                  variance: const ButtonStyle.outline(),
                  onPressed: () =>
                      context.read<GoalCubit>().delete(goal.uuid),
                  icon: const Icon(Icons.delete, size: 18),
                ),
              ],
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'R\$ ${goal.currentAmount.toStringAsFixed(2)} / R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.label,
                ),
                Text(
                  _daysLabel(),
                  style: AppTextStyles.caption.copyWith(
                    color: goal.deadline.isBefore(DateTime.now())
                        ? AppColors.expense
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: const Color(0xFF3A3A3A),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const Gap(12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlineButton(
                onPressed: () => _showContributeDialog(context),
                child: const Text('Contribuir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContributeDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Adicionar contribuição'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          placeholder: const Text('Valor (ex: 100.00)'),
        ),
        actions: <Widget>[
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            onPressed: () {
              final String raw = controller.text.replaceAll(',', '.');
              final double? amount = double.tryParse(raw);
              if (amount != null && amount > 0) {
                context.read<GoalCubit>().contribute(goal.uuid, amount);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
