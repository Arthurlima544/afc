import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/recurring_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/recurring/recurring_cubit.dart';
import '../blocs/transaction/transaction_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_recorrente.dart';

class ListaRecorrentes extends StatelessWidget {
  const ListaRecorrentes({super.key});

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
          unawaited(context.read<RecurringCubit>().loadRecurring(userId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  const Gap(8),
                  const Expanded(
                    child: Text('Recorrências', style: AppTextStyles.heading),
                  ),
                  AppIconButton(
                    onPressed: () => showFormSheet<void>(
                      context,
                      builder: (BuildContext ctx) => MultiBlocProvider(
                        providers: <BlocProvider<dynamic>>[
                          BlocProvider<TransactionCubit>(
                            create: (_) => TransactionCubit()..getCategories(),
                          ),
                          BlocProvider<RecurringCubit>(
                            create: (_) => RecurringCubit(),
                          ),
                        ],
                        child: const CadastrarRecorrente(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            const Gap(16),
            BlocBuilder<RecurringCubit, RecurringState>(
              builder: (BuildContext context, RecurringState state) => state.when(
                initial: () => const SizedBox(),
                loading: () => const SkeletonList(),
                error: (String msg) => ErrorState(
                  message: msg,
                  onRetry: () {
                    final String userId =
                        context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                        '';
                    context.read<RecurringCubit>().loadRecurring(userId);
                  },
                ),
                success: (_) => const SizedBox(),
                listed: (List<RecurringEntity> rules) => rules.isEmpty
                    ? EmptyState(
                        message: 'Nenhuma recorrência ainda.',
                        subtitle:
                            'Configure transações que se repetem (salário, aluguel, assinaturas) e elas serão lançadas automaticamente.',
                        icon: Icons.repeat_outlined,
                        actionLabel: 'Criar recorrente',
                        onAction: () => showFormSheet<void>(
                          context,
                          builder: (BuildContext ctx) => MultiBlocProvider(
                            providers: <BlocProvider<dynamic>>[
                              BlocProvider<TransactionCubit>(
                                create: (_) =>
                                    TransactionCubit()..getCategories(),
                              ),
                              BlocProvider<RecurringCubit>(
                                create: (_) => RecurringCubit(),
                              ),
                            ],
                            child: const CadastrarRecorrente(),
                          ),
                        ),
                      )
                    : Column(
                        children: <Widget>[
                          for (final RecurringEntity rule in rules)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RecorrenteItem(rule: rule),
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

class _RecorrenteItem extends StatelessWidget {
  const _RecorrenteItem({required this.rule});

  final RecurringEntity rule;

  String _frequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Diário';
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensal';
      default:
        return frequency;
    }
  }

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(rule.templateTransaction.title, style: AppTextStyles.title),
              const Gap(4),
              Text(
                '${_frequencyLabel(rule.frequency)} · '
                'R\$ ${rule.templateTransaction.amount.toStringAsFixed(2)}',
                style: AppTextStyles.label,
              ),
              const Gap(2),
              Text(
                'Próxima: ${DateFormat('dd/MM/yyyy').format(rule.nextDue)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        Switch(
          value: rule.active,
          onChanged: (bool value) {
            if (value) {
              context.read<RecurringCubit>().resume(rule.uuid);
            } else {
              context.read<RecurringCubit>().pause(rule.uuid);
            }
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (String action) {
            if (action == 'delete') {
              context.read<RecurringCubit>().delete(rule.uuid);
            }
          },
          itemBuilder: (_) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'delete',
              child: Text('Excluir'),
            ),
          ],
        ),
      ],
    ),
  );
}
