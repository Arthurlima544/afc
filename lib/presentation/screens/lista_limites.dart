import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;

import '../blocs/limit/limit_cubit.dart';

class ListaLimites extends StatelessWidget {
  const ListaLimites({super.key});

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
                  'Limites',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                variance: const ButtonStyle.outline(),
                onPressed: () => context.push('/cadastro-limite'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Gap(16),
          BlocBuilder<LimitCubit, LimitState>(
            builder: (BuildContext context, LimitState state) => state.when(
              initial: (_) => const SizedBox(),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: Text.new,
              loaded: (_) => const SizedBox(),
              success: (_) => const SizedBox(),
              listed: (List<LimitListItem> items) => items.isEmpty
                  ? const Center(child: Text('Sem limites'))
                  : Column(
                      children: <Widget>[
                        for (final LimitListItem item in items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LimiteItem(item: item),
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

class _LimiteItem extends StatelessWidget {
  const _LimiteItem({required this.item});

  final LimitListItem item;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.categoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  '${item.limit.month} · R\$ ${item.limit.limitAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            variance: const ButtonStyle.outline(),
            onPressed: () =>
                context.push('/editar-limite', extra: item.limit),
            icon: const Icon(Icons.edit, size: 18),
          ),
          IconButton(
            variance: const ButtonStyle.outline(),
            onPressed: () =>
                context.read<LimitCubit>().deleteLimit(item.limit.uuid),
            icon: const Icon(Icons.delete, size: 18),
          ),
        ],
      ),
    ),
  );
}
