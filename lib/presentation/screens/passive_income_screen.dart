import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/passive_income_entity.dart';
import '../blocs/passive_income/passive_income_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';

// ─── Source helpers ───────────────────────────────────────────────────────────

const Map<String, String> _sourceLabels = <String, String>{
  'dividend': 'Dividendos',
  'interest': 'Juros / Renda Fixa',
  'rent': 'Aluguel',
  'other': 'Outro',
};

const Map<String, IconData> _sourceIcons = <String, IconData>{
  'dividend': Icons.account_balance_outlined,
  'interest': Icons.savings_outlined,
  'rent': Icons.home_outlined,
  'other': Icons.attach_money,
};

const Map<String, String> _freqLabels = <String, String>{
  'monthly': 'Mensal',
  'quarterly': 'Trimestral',
  'annual': 'Anual',
};

// ─── Screen ────────────────────────────────────────────────────────────────────

class PassiveIncomeScreen extends StatelessWidget {
  const PassiveIncomeScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Renda Passiva'),
      centerTitle: false,
      actions: <Widget>[
        AppIconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Adicionar fonte',
          onPressed: () => _showAddSheet(context),
        ),
      ],
    ),
    body: BlocBuilder<PassiveIncomeCubit, PassiveIncomeState>(
      builder: (BuildContext context, PassiveIncomeState state) =>
          state.when(
        initial: () => const SizedBox(),
        loading: () => const SkeletonList(),
        error: (String msg) => ErrorState(
          message: msg,
          onRetry: () =>
              context.read<PassiveIncomeCubit>().loadStreams(userId),
        ),
        listed: (List<PassiveIncomeEntity> streams) {
          if (streams.isEmpty) {
            return const EmptyState(
              message:
                  'Nenhuma fonte de renda passiva.\nToque em + para adicionar.',
            );
          }
          return _PassiveIncomeBody(streams: streams);
        },
      ),
    ),
  );

  void _showAddSheet(BuildContext context) {
    unawaited(
      showFormSheet<void>(
        context,
        builder: (BuildContext ctx) => BlocProvider<PassiveIncomeCubit>.value(
          value: context.read<PassiveIncomeCubit>(),
          child: const _AddStreamSheet(),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _PassiveIncomeBody extends StatelessWidget {
  const _PassiveIncomeBody({required this.streams});

  final List<PassiveIncomeEntity> streams;

  @override
  Widget build(BuildContext context) {
    final double totalMonthly = streams.fold(
      0,
      (double s, PassiveIncomeEntity e) =>
          s + monthlyEquivalent(e.amount, e.frequency),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TotalCard(totalMonthly: totalMonthly),
          const Gap(16),
          const _SectionLabel('Fontes de renda'),
          const Gap(8),
          for (final PassiveIncomeEntity stream in streams) ...<Widget>[
            _StreamCard(stream: stream),
            const Gap(8),
          ],
        ],
      ),
    );
  }
}

// ─── Total card ───────────────────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totalMonthly});

  final double totalMonthly;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          const Icon(Icons.trending_up, color: AppColors.income, size: 28),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Renda passiva mensal',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
                const Gap(4),
                Text(
                  brl.format(totalMonthly),
                  style: AppTextStyles.title.copyWith(color: AppColors.income),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stream card ──────────────────────────────────────────────────────────────

class _StreamCard extends StatelessWidget {
  const _StreamCard({required this.stream});

  final PassiveIncomeEntity stream;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final double monthly = monthlyEquivalent(stream.amount, stream.frequency);

    return Dismissible(
      key: Key(stream.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      onDismissed: (_) =>
          context.read<PassiveIncomeCubit>().delete(stream.uuid),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Icon(
              _sourceIcons[stream.source] ?? Icons.attach_money,
              color: AppColors.income,
              size: 22,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(stream.name, style: AppTextStyles.labelBold),
                  const Gap(2),
                  Text(
                    '${_sourceLabels[stream.source] ?? 'Outro'} · '
                    '${_freqLabels[stream.frequency] ?? stream.frequency}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(brl.format(stream.amount),
                    style: AppTextStyles.labelBold),
                if (stream.frequency != 'monthly') ...<Widget>[
                  const Gap(2),
                  Text(
                    '≈ ${brl.format(monthly)}/mês',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add stream bottom sheet ──────────────────────────────────────────────────

class _AddStreamSheet extends StatefulWidget {
  const _AddStreamSheet();

  @override
  State<_AddStreamSheet> createState() => _AddStreamSheetState();
}

class _AddStreamSheetState extends State<_AddStreamSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  String _source = 'dividend';
  String _frequency = 'monthly';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String name = _nameCtrl.text.trim();
    final double amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (name.isEmpty || amount <= 0) {
      return;
    }
    await context.read<PassiveIncomeCubit>().add(
          name: name,
          source: _source,
          amount: amount,
          frequency: _frequency,
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Nova Fonte de Renda', style: AppTextStyles.sectionTitle),
          const Gap(16),
          AppTextField(
            controller: _nameCtrl,
            hintText: 'Ex: Dividendos PETR4',
          ),
          const Gap(12),
          AppTextField(
            controller: _amountCtrl,
            hintText: 'Valor (R\$)',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const Gap(12),
          _DropdownRow<String>(
            label: 'Tipo',
            value: _source,
            items: _sourceLabels.entries
                .map(
                  (MapEntry<String, String> e) =>
                      DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                )
                .toList(),
            onChanged: (String? v) {
              if (v != null) {
                setState(() => _source = v);
              }
            },
          ),
          const Gap(12),
          _DropdownRow<String>(
            label: 'Frequência',
            value: _frequency,
            items: _freqLabels.entries
                .map(
                  (MapEntry<String, String> e) =>
                      DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                )
                .toList(),
            onChanged: (String? v) {
              if (v != null) {
                setState(() => _frequency = v);
              }
            },
          ),
          const Gap(20),
          PrimaryButton(
            onPressed: _submit,
            child: const Text('Adicionar'),
          ),
        ],
      ),
    ),
  );
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      SizedBox(
        width: 90,
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
      ),
      Expanded(
        child: DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    ],
  );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.labelBold.copyWith(color: AppColors.muted),
  );
}
