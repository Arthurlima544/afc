import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/goal_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/goal/goal_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_categoria.dart';
import 'cadastrar_meta.dart';

class ListaMetas extends StatelessWidget {
  const ListaMetas({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
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
                AppIconButton(
                  onPressed: () async {
                    final GoalCubit goals = context.read<GoalCubit>();
                    final String userId =
                        context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                        '';
                    await showFormSheet<void>(
                      context,
                      builder: (BuildContext ctx) => BlocProvider<GoalCubit>(
                        create: (_) => GoalCubit(),
                        child: const CadastrarMeta(),
                      ),
                    );
                    unawaited(goals.loadGoals(userId));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Gap(16),
            BlocConsumer<GoalCubit, GoalState>(
              listener: (BuildContext context, GoalState state) {
                state.whenOrNull(
                  error: (String msg) =>
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      ),
                );
              },
              builder: (BuildContext context, GoalState state) => state.when(
                initial: () => const SizedBox(),
                loading: () => const SkeletonList(itemHeight: 140),
                error: (String msg) => ErrorState(
                  message: msg,
                  onRetry: () {
                    final String userId =
                        context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                        '';
                    context.read<GoalCubit>().loadGoals(userId);
                  },
                ),
                success: (_) => const SkeletonList(itemHeight: 140),
                listed: (List<GoalEntity> goals) => goals.isEmpty
                    ? const EmptyState(
                        message: 'Nenhuma meta ainda.\nToque em + para criar.',
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

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(iconList[goal.icon % iconList.length], size: 24),
              const Gap(12),
              Expanded(child: Text(goal.name, style: AppTextStyles.title)),
              AppIconButton(
                onPressed: () async {
                  final GoalCubit goals = context.read<GoalCubit>();
                  final String userId =
                      context.read<AuthBloc>().state.whenOrNull(
                        signedIn: (ClerkAuthState s) => s.user?.id,
                      ) ??
                      '';
                  await showFormSheet<void>(
                    context,
                    builder: (BuildContext ctx) => BlocProvider<GoalCubit>(
                      create: (_) => GoalCubit(),
                      child: CadastrarMeta(initialGoal: goal),
                    ),
                  );
                  unawaited(goals.loadGoals(userId));
                },
                icon: const Icon(Icons.edit, size: 18),
              ),
              AppIconButton(
                onPressed: () async {
                  final GoalCubit goals = context.read<GoalCubit>();
                  final String userId =
                      context.read<AuthBloc>().state.whenOrNull(
                        signedIn: (ClerkAuthState s) => s.user?.id,
                      ) ??
                      '';
                  await goals.delete(goal.uuid);
                  unawaited(goals.loadGoals(userId));
                },
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
    );
  }

  Future<void> _showContributeDialog(BuildContext context) async {
    final GoalCubit goals = context.read<GoalCubit>();
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
          signedIn: (ClerkAuthState s) => s.user?.id,
        ) ??
        '';
    final String? result = await showInputDialog(
      context: context,
      title: 'Adicionar contribuição',
      hintText: 'Valor (ex: 100.00)',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    if (result == null) {
      return;
    }
    final double? amount = double.tryParse(result.replaceAll(',', '.'));
    if (amount != null && amount > 0) {
      await goals.contribute(goal.uuid, amount);
      unawaited(goals.loadGoals(userId));
    }
  }
}
