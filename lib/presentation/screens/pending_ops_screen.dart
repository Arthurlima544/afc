import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/pending_operation_entity.dart';
import '../blocs/pending_ops/pending_ops_cubit.dart';
import '../widgets/design_system.dart';

class PendingOpsScreen extends StatelessWidget {
  const PendingOpsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Operações pendentes'),
      actions: <Widget>[
        AppIconButton(
          onPressed: () => context.read<PendingOpsCubit>().retryNow(),
          icon: const Icon(AppIcons.sync, size: 20),
          tooltip: 'Sincronizar agora',
        ),
      ],
    ),
    body: BlocBuilder<PendingOpsCubit, PendingOpsState>(
      builder: (BuildContext context, PendingOpsState state) {
        if (state.ops.isEmpty) {
          return const _EmptyState();
        }
        return _PendingList(state: state);
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          AppIcons.sync,
          size: 64,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const Gap(16),
        Text(
          'Nenhuma operação pendente',
          style: AppTextStyles.body.copyWith(
            color: AppColors.muted,
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Non-empty list
// ---------------------------------------------------------------------------

class _PendingList extends StatelessWidget {
  const _PendingList({required this.state});

  final PendingOpsState state;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          '${state.total} ${state.total == 1 ? 'operação aguardando' : 'operações aguardando'} sincronização',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: <Widget>[
            for (final MapEntry<String, int> entry in state.groups.entries) ...<Widget>[
              _SectionHeader(
                label: _humanLabel(entry.key),
                count: entry.value,
              ),
              for (final PendingOperationEntity op in state.ops
                  .where(
                    (PendingOperationEntity o) => o.collection == entry.key,
                  )
                  .toList())
                _OpTile(op: op),
              const Gap(8),
            ],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: SecondaryButton(
                onPressed: () => context.read<PendingOpsCubit>().retryNow(),
                child: const Text('Sincronizar tudo'),
              ),
            ),
            const Gap(8),
            DestructiveButton(
              onPressed: () => context.read<PendingOpsCubit>().clear(),
              child: const Text('Limpar fila'),
            ),
          ],
        ),
      ),
    ],
  );

  static String _humanLabel(String collection) => switch (collection) {
    'transaction' => 'Transações',
    'goal' => 'Metas',
    'limit' => 'Limites',
    'investment' => 'Investimentos',
    'bill' => 'Contas',
    'recurring' => 'Recorrentes',
    'template' => 'Templates',
    'category' => 'Categorias',
    _ => collection,
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Row(
      children: <Widget>[
        Text(label, style: AppTextStyles.bodyBold),
        const Gap(6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    ),
  );
}

class _OpTile extends StatelessWidget {
  const _OpTile({required this.op});

  final PendingOperationEntity op;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: <Widget>[
        Icon(_typeIcon(op.type), size: 18, color: AppColors.muted),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_typeLabel(op.type), style: AppTextStyles.bodyBold),
              Text(
                'Criado em ${DateFormat('dd/MM/yyyy HH:mm').format(op.createdAt)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
              if (op.retries > 0)
                Text(
                  '${op.retries} tentativa(s)',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
        AppIconButton(
          onPressed: () => context.read<PendingOpsCubit>().retryNow(),
          icon: const Icon(AppIcons.refresh, size: 18),
          tooltip: 'Tentar novamente',
        ),
      ],
    ),
  );

  static IconData _typeIcon(OperationType type) => switch (type) {
    OperationType.create => AppIcons.add,
    OperationType.update => AppIcons.edit,
    OperationType.delete => AppIcons.delete,
  };

  static String _typeLabel(OperationType type) => switch (type) {
    OperationType.create => 'Criar',
    OperationType.update => 'Atualizar',
    OperationType.delete => 'Excluir',
  };
}
