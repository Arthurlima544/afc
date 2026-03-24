import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../domain/usecase/transaction_grouper.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/transaction/transaction_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_transacao.dart';

enum _ViewMode { byDate, byGroup }

class ListaTransacoes extends StatefulWidget {
  const ListaTransacoes({super.key});

  @override
  State<ListaTransacoes> createState() => _ListaTransacoesState();
}

class _ListaTransacoesState extends State<ListaTransacoes> {
  _ViewMode _viewMode = _ViewMode.byDate;

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
        unawaited(context.read<TransactionCubit>().loadTransactions(userId));
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
                  child: Text('Transações', style: AppTextStyles.heading),
                ),
                AppIconButton(
                  onPressed: () => context.push('/lista-recorrentes'),
                  icon: const Icon(Icons.repeat_outlined),
                  tooltip: 'Recorrências',
                ),
                const Gap(8),
                AppIconButton(
                  onPressed: () => context.push('/relatorio'),
                  icon: const Icon(Icons.analytics_outlined),
                ),
                const Gap(8),
                AppIconButton(
                  onPressed: () => context.push('/importar-extrato'),
                  icon: const Icon(Icons.upload_file_outlined),
                ),
                const Gap(8),
                AppIconButton(
                  onPressed: () => showFormSheet<void>(
                    context,
                    builder: (BuildContext ctx) =>
                        BlocProvider<TransactionCubit>(
                          create: (_) => TransactionCubit()..getCategories(),
                          child: const CadastrarTransacao(),
                        ),
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Gap(12),
            // View-mode toggle
            Row(
              children: <Widget>[
                _ToggleChip(
                  label: 'Por data',
                  selected: _viewMode == _ViewMode.byDate,
                  onTap: () => setState(() => _viewMode = _ViewMode.byDate),
                ),
                const Gap(8),
                _ToggleChip(
                  label: 'Por grupo',
                  selected: _viewMode == _ViewMode.byGroup,
                  onTap: () => setState(() => _viewMode = _ViewMode.byGroup),
                ),
              ],
            ),
            const Gap(16),
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (BuildContext context, TransactionState state) =>
                  state.when(
                    initial: (_) => const SizedBox(),
                    loading: () => const SkeletonList(),
                    error: (String msg) => ErrorState(
                      message: msg,
                      onRetry: () {
                        final String userId =
                            context.read<AuthBloc>().state.whenOrNull(
                              signedIn: (ClerkAuthState s) => s.user?.id,
                            ) ??
                            '';
                        context
                            .read<TransactionCubit>()
                            .loadTransactions(userId);
                      },
                    ),
                    success: (_) => const SizedBox(),
                    listed: (List<TransactionEntity> txs) => txs.isEmpty
                        ? const EmptyState(
                            message:
                                'Nenhuma transação ainda.\nToque em + para adicionar.',
                            icon: Icons.receipt_long_outlined,
                          )
                        : _viewMode == _ViewMode.byDate
                        ? _DateList(txs: txs)
                        : _GroupList(txs: txs),
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// By-date view (original flat list)
// ---------------------------------------------------------------------------

class _DateList extends StatelessWidget {
  const _DateList({required this.txs});

  final List<TransactionEntity> txs;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (final TransactionEntity tx in txs)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TransacaoItem(tx: tx),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// By-group view
// ---------------------------------------------------------------------------

class _GroupList extends StatelessWidget {
  const _GroupList({required this.txs});

  final List<TransactionEntity> txs;

  @override
  Widget build(BuildContext context) {
    final List<TransactionGroup> groups = TransactionGrouper.group(txs);
    return Column(
      children: <Widget>[
        for (final TransactionGroup group in groups) ...<Widget>[
          _GroupHeader(group: group),
          const Gap(6),
          for (final TransactionEntity tx in group.transactions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TransacaoItem(tx: tx),
            ),
          const Gap(12),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final TransactionGroup group;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: Text(group.label, style: AppTextStyles.sectionTitle),
      ),
      Text(
        '${group.transactions.length} · '
        '${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(group.total)}',
        style: AppTextStyles.caption,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Toggle chip
// ---------------------------------------------------------------------------

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.muted.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: selected ? AppColors.primary : null,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Transaction row
// ---------------------------------------------------------------------------

class _TransacaoItem extends StatelessWidget {
  const _TransacaoItem({required this.tx});

  final TransactionEntity tx;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = tx.typeUuid == TypeEntity.income.name;
    final double displayAmount = isIncome ? tx.amount : -tx.amount;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tx.title, style: AppTextStyles.title),
                const Gap(4),
                Text(
                  '${_formatCurrency(displayAmount)} · '
                  '${DateFormat('dd/MM/yyyy').format(tx.data)}',
                  style: AppTextStyles.label.copyWith(
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            onPressed: () => showFormSheet<void>(
              context,
              builder: (BuildContext ctx) => BlocProvider<TransactionCubit>(
                create: (_) => TransactionCubit()..getCategories(),
                child: CadastrarTransacao(initialTransaction: tx),
              ),
            ),
            icon: const Icon(Icons.edit, size: 18),
          ),
          AppIconButton(
            onPressed: () =>
                context.read<TransactionCubit>().deleteTransaction(tx.uuid),
            icon: const Icon(Icons.delete, size: 18),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(amount);
