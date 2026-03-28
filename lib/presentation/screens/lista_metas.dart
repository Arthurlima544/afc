import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/goal_entity.dart';
import '../../utils/share_card_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/goal/goal_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/share_cards/goal_achievement_card.dart';
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
                    ? EmptyState(
                        message: 'Nenhuma meta ainda.',
                        subtitle:
                            'Defina um objetivo financeiro e acompanhe o progresso mês a mês.',
                        icon: Icons.savings_outlined,
                        actionLabel: 'Criar meta',
                        onAction: () async {
                          final GoalCubit goalCubit =
                              context.read<GoalCubit>();
                          final String userId =
                              context.read<AuthBloc>().state.whenOrNull(
                                signedIn: (ClerkAuthState s) => s.user?.id,
                              ) ??
                              '';
                          await showFormSheet<void>(
                            context,
                            builder: (BuildContext ctx) =>
                                BlocProvider<GoalCubit>(
                                  create: (_) => GoalCubit(),
                                  child: const CadastrarMeta(),
                                ),
                          );
                          unawaited(goalCubit.loadGoals(userId));
                        },
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

class _MetaItem extends StatefulWidget {
  const _MetaItem({required this.goal});

  final GoalEntity goal;

  @override
  State<_MetaItem> createState() => _MetaItemState();
}

class _MetaItemState extends State<_MetaItem> {
  final GlobalKey _shareKey = GlobalKey();

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
      widget.goal.deadline.year,
      widget.goal.deadline.month,
      widget.goal.deadline.day,
    );
    final int days = deadline.difference(today).inDays;
    if (days < 0) {
      return 'Prazo encerrado';
    }
    return '$days dias restantes';
  }

  Future<void> _shareCard() async {
    // One frame so the Offstage card is laid out.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) {
      return;
    }
    await ShareCardService.captureAndShare(
      _shareKey,
      'afc_meta_${widget.goal.uuid.substring(0, 8)}.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    final GoalEntity goal = widget.goal;
    final double ratio = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final Color barColor = _progressColor(ratio);
    final bool isComplete = ratio >= 1.0;
    final IconData goalIcon = iconList[goal.icon % iconList.length];

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(goalIcon, size: 24),
              const Gap(12),
              Expanded(child: Text(goal.name, style: AppTextStyles.title)),
              // Share button — visible only when goal is 100% complete.
              if (isComplete)
                AppIconButton(
                  onPressed: _shareCard,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  tooltip: 'Compartilhar conquista',
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
          // ── Off-screen achievement card for share capture ─────────────
          Offstage(
            child: RepaintBoundary(
              key: _shareKey,
              child: GoalAchievementCard(
                goalName: goal.name,
                targetAmount: goal.targetAmount,
                currentAmount: goal.currentAmount,
                deadline: goal.deadline,
                icon: goalIcon,
              ),
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
      await goals.contribute(widget.goal.uuid, amount);
      unawaited(goals.loadGoals(userId));
    }
  }
}
