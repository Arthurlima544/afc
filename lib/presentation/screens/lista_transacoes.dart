import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;

import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../blocs/transaction/transaction_cubit.dart';

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
              IconButton(
                variance: const ButtonStyle.outline(),
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const Gap(8),
              const Expanded(
                child: Text(
                  'Transações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: Text.new,
                  success: (_) => const SizedBox(),
                  listed: (List<TransactionEntity> txs) => txs.isEmpty
                      ? const Center(child: Text('Sem transações'))
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
                  Text(
                    tx.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${_formatCurrency(displayAmount)} · '
                    '${DateFormat('dd/MM/yyyy').format(tx.data)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isIncome ? Colors.green : Colors.red,
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
