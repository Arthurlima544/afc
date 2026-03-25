import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/sub_account_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/sub_account/sub_account_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_sub_conta.dart';

class SubAccountsScreen extends StatelessWidget {
  const SubAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            unawaited(
              context.read<SubAccountCubit>().loadWithTotals(userId),
            );
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
                      child: Text('Sub-contas', style: AppTextStyles.heading),
                    ),
                    AppIconButton(
                      onPressed: () async {
                        final SubAccountCubit cubit =
                            context.read<SubAccountCubit>();
                        await showFormSheet<void>(
                          context,
                          builder: (BuildContext ctx) =>
                              BlocProvider<SubAccountCubit>(
                            create: (_) => SubAccountCubit(),
                            child: const CadastrarSubConta(),
                          ),
                        );
                        unawaited(cubit.loadWithTotals(userId));
                      },
                      icon: const Icon(AppIcons.add, size: 20),
                    ),
                  ],
                ),
                const Gap(16),
                BlocBuilder<SubAccountCubit, SubAccountState>(
                  builder: (BuildContext context, SubAccountState state) =>
                      state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => const SkeletonList(),
                    listed: (
                      List<SubAccountEntity> accounts,
                      Map<String, SubAccountTotals> totals,
                    ) {
                      if (accounts.isEmpty) {
                        return EmptyState(
                          message: 'Nenhuma sub-conta cadastrada',
                          icon: Icons.account_balance_wallet_outlined,
                          subtitle:
                              'Crie sub-contas para separar despesas pessoais, empresariais ou de benefícios.',
                          actionLabel: 'Adicionar sub-conta',
                          onAction: () async {
                            final SubAccountCubit cubit =
                                context.read<SubAccountCubit>();
                            await showFormSheet<void>(
                              context,
                              builder: (BuildContext ctx) =>
                                  BlocProvider<SubAccountCubit>(
                                create: (_) => SubAccountCubit(),
                                child: const CadastrarSubConta(),
                              ),
                            );
                            unawaited(cubit.loadWithTotals(userId));
                          },
                        );
                      }
                      return Column(
                        children: <Widget>[
                          for (final SubAccountEntity account in accounts) ...<
                              Widget>[
                            _SubAccountCard(
                              account: account,
                              totals: totals[account.uuid] ??
                                  const SubAccountTotals(
                                    income: 0,
                                    expenses: 0,
                                  ),
                              userId: userId,
                            ),
                            const Gap(12),
                          ],
                        ],
                      );
                    },
                    success: (_) => const SizedBox.shrink(),
                    error: (String msg) => ErrorState(
                      message: msg,
                      onRetry: () => context
                          .read<SubAccountCubit>()
                          .loadWithTotals(userId),
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
}

// ---------------------------------------------------------------------------
// Sub-account card
// ---------------------------------------------------------------------------

class _SubAccountCard extends StatelessWidget {
  const _SubAccountCard({
    required this.account,
    required this.totals,
    required this.userId,
  });

  final SubAccountEntity account;
  final SubAccountTotals totals;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final bool isPositive = totals.balance >= 0;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(account.color),
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(account.name, style: AppTextStyles.bodyBold),
                    Text(
                      _typeLabel(account.type),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                onPressed: () async {
                  final SubAccountCubit cubit =
                      context.read<SubAccountCubit>();
                  await showFormSheet<void>(
                    context,
                    builder: (BuildContext ctx) =>
                        BlocProvider<SubAccountCubit>(
                      create: (_) => SubAccountCubit(),
                      child: CadastrarSubConta(initialAccount: account),
                    ),
                  );
                  unawaited(cubit.loadWithTotals(userId));
                },
                icon: const Icon(AppIcons.edit, size: 20),
              ),
              AppIconButton(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(AppIcons.delete, size: 20),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: <Widget>[
              _StatChip(
                label: 'Receitas',
                value: fmt.format(totals.income),
                color: AppColors.income,
              ),
              const Gap(8),
              _StatChip(
                label: 'Despesas',
                value: fmt.format(totals.expenses),
                color: AppColors.expense,
              ),
              const Gap(8),
              _StatChip(
                label: 'Saldo',
                value: fmt.format(totals.balance),
                color: isPositive ? AppColors.income : AppColors.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final SubAccountCubit cubit = context.read<SubAccountCubit>();
    unawaited(
      showAppDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AppAlertDialog(
          title: const Text('Excluir sub-conta'),
          content: Text(
            'Deseja excluir "${account.name}"? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            SecondaryButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            DestructiveButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                unawaited(cubit.delete(account.uuid, userId));
                unawaited(cubit.loadWithTotals(userId));
              },
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }

  static String _typeLabel(SubAccountType type) => switch (type) {
    SubAccountType.personal => 'Pessoal',
    SubAccountType.company => 'Empresa',
    SubAccountType.benefit => 'Benefício',
  };
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          const Gap(2),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
