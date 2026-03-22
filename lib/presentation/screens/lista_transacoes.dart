import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;

import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/app_spacing.dart';
import '../blocs/transaction/transaction_cubit.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';

class ListaTransacoes extends StatelessWidget {
  const ListaTransacoes({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Transações',
                  style: AppTextStyles.heading,
                ),
              ),
              IconButton(
                variance: const ButtonStyle.outline(),
                onPressed: () => context.push('/cadastro-transacao'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Gap(16),
          BlocBuilder<TransactionCubit, TransactionState>(
            builder: (BuildContext context, TransactionState state) =>
                state.when(
                  initial: (_) => const SizedBox(),
                  loading: () => const SkeletonList(),
                  error: (String msg) => EmptyState(
                    message: msg,
                    icon: Icons.error_outline,
                  ),
                  success: (_) => const SizedBox(),
                  listed: (List<TransactionEntity> txs) => txs.isEmpty
                      ? const EmptyState(
                          message: 'Nenhuma transação ainda.\nToque em + para adicionar.',
                          icon: Icons.receipt_long_outlined,
                        )
                      : Column(
                          children: <Widget>[
                            for (final TransactionEntity tx in txs)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TransacaoItem(tx: tx),
                              ),
                          ],
                        ),
                ),
          ),
        ],
      ),
    ),
  );
}

class _TransacaoItem extends StatelessWidget {
  const _TransacaoItem({required this.tx});

  final TransactionEntity tx;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = tx.typeUuid == TypeEntity.income.name;
    final double displayAmount = isIncome ? tx.amount : -tx.amount;

    return Card(
      child: Padding(
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
            IconButton(
              variance: const ButtonStyle.outline(),
              onPressed: () =>
                  context.push('/editar-transacao', extra: tx),
              icon: const Icon(Icons.edit, size: 18),
            ),
            IconButton(
              variance: const ButtonStyle.outline(),
              onPressed: () =>
                  context.read<TransactionCubit>().deleteTransaction(tx.uuid),
              icon: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCurrency(double amount) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(amount);
