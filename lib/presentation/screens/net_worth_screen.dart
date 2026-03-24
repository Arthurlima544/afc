import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/net_worth_snapshot_entity.dart';
import '../blocs/net_worth/net_worth_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';

// ─── Screen ────────────────────────────────────────────────────────────────────

class NetWorthScreen extends StatelessWidget {
  const NetWorthScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Patrimônio Líquido'),
      centerTitle: false,
      actions: <Widget>[
        AppIconButton(
          icon: const Icon(Icons.add_chart_outlined),
          tooltip: 'Registrar snapshot',
          onPressed: () => _showRecordSheet(context),
        ),
      ],
    ),
    body: BlocBuilder<NetWorthCubit, NetWorthState>(
      builder: (BuildContext context, NetWorthState state) => state.when(
        initial: () => const SizedBox(),
        loading: () => const SkeletonList(),
        error: (String msg) => ErrorState(
          message: msg,
          onRetry: () =>
              context.read<NetWorthCubit>().loadSnapshots(userId),
        ),
        listed: (List<NetWorthSnapshotEntity> snapshots) {
          if (snapshots.isEmpty) {
            return const EmptyState(
              message:
                  'Nenhum snapshot de patrimônio.\nToque em + para registrar.',
            );
          }
          return _NetWorthBody(snapshots: snapshots);
        },
      ),
    ),
  );

  void _showRecordSheet(BuildContext context) {
    unawaited(
      showFormSheet<void>(
        context,
        builder: (BuildContext ctx) => BlocProvider<NetWorthCubit>.value(
          value: context.read<NetWorthCubit>(),
          child: const _RecordSnapshotSheet(),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _NetWorthBody extends StatelessWidget {
  const _NetWorthBody({required this.snapshots});

  final List<NetWorthSnapshotEntity> snapshots;

  @override
  Widget build(BuildContext context) {
    final NetWorthSnapshotEntity latest = snapshots.last;
    final double delta = snapshots.length > 1
        ? latest.netWorth - snapshots[snapshots.length - 2].netWorth
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SummaryCard(latest: latest, delta: delta),
          const Gap(16),
          _NetWorthChart(snapshots: snapshots),
          const Gap(16),
          const _SectionLabel('Histórico de snapshots'),
          const Gap(8),
          for (final NetWorthSnapshotEntity s
              in snapshots.reversed.toList()) ...<Widget>[
            _SnapshotRow(snapshot: s),
            const Gap(6),
          ],
        ],
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.latest, required this.delta});

  final NetWorthSnapshotEntity latest;
  final double delta;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final bool positive = delta >= 0;
    final Color deltaColor =
        positive ? AppColors.income : AppColors.expense;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Patrimônio líquido',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          const Gap(4),
          Text(
            brl.format(latest.netWorth),
            style: AppTextStyles.title.copyWith(color: AppColors.income),
          ),
          const Gap(12),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatItem(
                  label: 'Ativos',
                  value: brl.format(latest.assets),
                  color: AppColors.income,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Passivos',
                  value: brl.format(latest.liabilities),
                  color: AppColors.expense,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Variação mensal',
                  value: '${positive ? '+' : ''}${brl.format(delta)}',
                  color: deltaColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
      ),
      const Gap(2),
      Text(
        value,
        style: AppTextStyles.labelBold.copyWith(color: color),
      ),
    ],
  );
}

// ─── Line chart ───────────────────────────────────────────────────────────────

class _NetWorthChart extends StatelessWidget {
  const _NetWorthChart({required this.snapshots});

  final List<NetWorthSnapshotEntity> snapshots;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < snapshots.length; i++)
        FlSpot(i.toDouble(), snapshots[i].netWorth),
    ];
    final double maxY =
        snapshots.map((NetWorthSnapshotEntity s) => s.netWorth).reduce(
              (double a, double b) => a > b ? a : b,
            ) *
            1.15;
    final double minY =
        snapshots.map((NetWorthSnapshotEntity s) => s.netWorth).reduce(
              (double a, double b) => a < b ? a : b,
            ) *
            0.85;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 4,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final int idx = value.toInt();
                    if (idx < 0 || idx >= snapshots.length) {
                      return const SizedBox();
                    }
                    final String date = snapshots[idx].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        date.substring(5, 7),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: <LineChartBarData>[
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.income,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.income.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Snapshot row ─────────────────────────────────────────────────────────────

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.snapshot});

  final NetWorthSnapshotEntity snapshot;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.income,
            size: 20,
          ),
          const Gap(10),
          Expanded(
            child: Text(
              snapshot.date.substring(0, 7),
              style: AppTextStyles.labelBold,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                brl.format(snapshot.netWorth),
                style: AppTextStyles.labelBold.copyWith(
                  color: snapshot.netWorth >= 0
                      ? AppColors.income
                      : AppColors.expense,
                ),
              ),
              Text(
                'Ativos: ${brl.format(snapshot.assets)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Record snapshot bottom sheet ─────────────────────────────────────────────

class _RecordSnapshotSheet extends StatefulWidget {
  const _RecordSnapshotSheet();

  @override
  State<_RecordSnapshotSheet> createState() => _RecordSnapshotSheetState();
}

class _RecordSnapshotSheetState extends State<_RecordSnapshotSheet> {
  final TextEditingController _assetsCtrl = TextEditingController();
  final TextEditingController _liabilitiesCtrl =
      TextEditingController(text: '0');

  @override
  void dispose() {
    _assetsCtrl.dispose();
    _liabilitiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final double assets =
        double.tryParse(_assetsCtrl.text.replaceAll(',', '.')) ?? 0;
    final double liabilities =
        double.tryParse(_liabilitiesCtrl.text.replaceAll(',', '.')) ?? 0;
    if (assets <= 0) {
      return;
    }
    await context.read<NetWorthCubit>().recordSnapshot(
          assets: assets,
          liabilities: liabilities,
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
          const Text(
            'Registrar Patrimônio',
            style: AppTextStyles.sectionTitle,
          ),
          const Gap(16),
          AppTextField(
            controller: _assetsCtrl,
            hintText: 'Total de ativos (R\$)',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const Gap(12),
          AppTextField(
            controller: _liabilitiesCtrl,
            hintText: 'Total de passivos / dívidas (R\$)',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const Gap(20),
          PrimaryButton(
            onPressed: _submit,
            child: const Text('Registrar'),
          ),
        ],
      ),
    ),
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
