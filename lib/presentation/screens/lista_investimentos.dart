import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entity/investment_entity.dart';
import '../blocs/investment/investment_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_investimento.dart';

String _typeLabelPt(String type) {
  switch (type) {
    case 'stock':
      return 'Ação';
    case 'fixed':
      return 'Renda Fixa';
    case 'crypto':
      return 'Cripto';
    default:
      return 'Outro';
  }
}

String _formatCurrency(double value) {
  final bool isNeg = value < 0;
  final double abs = value.abs();
  final String formatted =
      'R\$ ${abs.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1.')}';
  return isNeg ? '-$formatted' : formatted;
}

class ListaInvestimentos extends StatelessWidget {
  const ListaInvestimentos({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
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
                  child: Text('Investimentos', style: AppTextStyles.heading),
                ),
                AppIconButton(
                  onPressed: () => showFormSheet<void>(
                    context,
                    builder: (BuildContext ctx) => BlocProvider<InvestmentCubit>(
                      create: (_) => InvestmentCubit(),
                      child: const CadastrarInvestimento(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          const Gap(16),
          BlocBuilder<InvestmentCubit, InvestmentState>(
            builder: (BuildContext context, InvestmentState state) => state.when(
              initial: () => const SizedBox(),
              loading: () => const SkeletonList(),
              error: (String msg) =>
                  EmptyState(message: msg, icon: Icons.error_outline),
              success: (_) => const SizedBox(),
              listed: (List<InvestmentEntity> investments) {
                if (investments.isEmpty) {
                  return const EmptyState(
                    message:
                        'Nenhum investimento ainda.\nToque em + para adicionar.',
                    icon: Icons.trending_up_outlined,
                  );
                }

                final double totalInvested = investments.fold(
                  0.0,
                  (double sum, InvestmentEntity inv) =>
                      sum + inv.quantity * inv.avgCost,
                );
                final double currentValue = investments.fold(
                  0.0,
                  (double sum, InvestmentEntity inv) =>
                      sum + inv.quantity * inv.currentPrice,
                );
                final double gainLoss = currentValue - totalInvested;
                final double gainLossPct = totalInvested > 0
                    ? gainLoss / totalInvested * 100
                    : 0;
                final Color gainColor = gainLoss >= 0
                    ? AppColors.income
                    : AppColors.expense;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _SummaryCard(
                            label: 'Investido',
                            value: _formatCurrency(totalInvested),
                            valueColor: null,
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Valor atual',
                            value: _formatCurrency(currentValue),
                            valueColor: null,
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Retorno',
                            value:
                                '${gainLossPct >= 0 ? '+' : ''}${gainLossPct.toStringAsFixed(2)}%',
                            valueColor: gainColor,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    for (final InvestmentEntity inv in investments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InvestmentItem(investment: inv),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
);
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.caption),
        const Gap(4),
        Text(value, style: AppTextStyles.labelBold.copyWith(color: valueColor)),
      ],
    ),
  );
}

class _InvestmentItem extends StatelessWidget {
  const _InvestmentItem({required this.investment});

  final InvestmentEntity investment;

  @override
  Widget build(BuildContext context) {
    final double totalInvested = investment.quantity * investment.avgCost;
    final double currentValue = investment.quantity * investment.currentPrice;
    final double gainLoss = currentValue - totalInvested;
    final double gainLossPct = totalInvested > 0
        ? gainLoss / totalInvested * 100
        : 0;
    final Color gainColor = gainLoss >= 0
        ? AppColors.income
        : AppColors.expense;
    final String nameLabel =
        investment.ticker != null && investment.ticker!.isNotEmpty
        ? '${investment.name} (${investment.ticker})'
        : investment.name;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(nameLabel, style: AppTextStyles.title),
                    const Gap(2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _typeLabelPt(investment.type),
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                onPressed: () => _showPriceDialog(context),
                icon: const Icon(Icons.price_change_outlined, size: 18),
              ),
              const Gap(4),
              AppIconButton(
                onPressed: () => showFormSheet<void>(
                  context,
                  builder: (BuildContext ctx) => BlocProvider<InvestmentCubit>(
                    create: (_) => InvestmentCubit(),
                    child: CadastrarInvestimento(initialInvestment: investment),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
              ),
              AppIconButton(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete, size: 18),
              ),
            ],
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${investment.quantity.toStringAsFixed(2)} × ${_formatCurrency(investment.avgCost)}',
                style: AppTextStyles.label,
              ),
              Text(
                'Inv: ${_formatCurrency(totalInvested)}',
                style: AppTextStyles.label,
              ),
            ],
          ),
          const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Atual: ${_formatCurrency(investment.currentPrice)}/un',
                style: AppTextStyles.label,
              ),
              Text(
                'Val: ${_formatCurrency(currentValue)}',
                style: AppTextStyles.label,
              ),
            ],
          ),
          const Gap(8),
          Row(
            children: <Widget>[
              Text(
                '${gainLoss >= 0 ? '+' : ''}${_formatCurrency(gainLoss)}',
                style: AppTextStyles.bodyBold.copyWith(color: gainColor),
              ),
              const Gap(8),
              Text(
                '(${gainLossPct >= 0 ? '+' : ''}${gainLossPct.toStringAsFixed(2)}%)',
                style: AppTextStyles.label.copyWith(color: gainColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showPriceDialog(BuildContext context) async {
    final String? result = await showInputDialog(
      context: context,
      title: 'Atualizar preço',
      hintText: 'Novo preço (ex: 35.50)',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    if (result == null) {
      return;
    }
    final double? price = double.tryParse(result.replaceAll(',', '.'));
    if (price != null && price >= 0) {
      // ignore: use_build_context_synchronously
      await context.read<InvestmentCubit>().updatePrice(investment.uuid, price);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showAppDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppAlertDialog(
        title: const Text('Remover investimento'),
        content: Text('Deseja remover "${investment.name}"?'),
        actions: <Widget>[
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          const Gap(8),
          DestructiveButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      await context.read<InvestmentCubit>().delete(
        investment.uuid,
        investment.userId,
      );
    }
  }
}
