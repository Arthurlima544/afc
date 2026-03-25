import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/benefit_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/benefit/benefit_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_beneficio.dart';

class BenefitWalletScreen extends StatelessWidget {
  const BenefitWalletScreen({super.key});

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
            unawaited(context.read<BenefitCubit>().loadBenefits(userId));
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
                      child: Text(
                        'Carteiras de Benefícios',
                        style: AppTextStyles.heading,
                      ),
                    ),
                    AppIconButton(
                      onPressed: () async {
                        final BenefitCubit cubit =
                            context.read<BenefitCubit>();
                        await showFormSheet<void>(
                          context,
                          builder: (BuildContext ctx) =>
                              BlocProvider<BenefitCubit>(
                            create: (_) => BenefitCubit(),
                            child: const CadastrarBeneficio(),
                          ),
                        );
                        unawaited(cubit.loadBenefits(userId));
                      },
                      icon: const Icon(AppIcons.add, size: 20),
                    ),
                  ],
                ),
                const Gap(16),
                BlocBuilder<BenefitCubit, BenefitState>(
                  builder: (BuildContext context, BenefitState state) =>
                      state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => const SkeletonList(),
                    listed: (List<BenefitEntity> benefits) {
                      if (benefits.isEmpty) {
                        return EmptyState(
                          message: 'Nenhum benefício cadastrado',
                          icon: AppIcons.balance,
                          subtitle:
                              'Adicione seus benefícios CLT para acompanhar o saldo.',
                          actionLabel: 'Adicionar benefício',
                          onAction: () async {
                            final BenefitCubit cubit =
                                context.read<BenefitCubit>();
                            await showFormSheet<void>(
                              context,
                              builder: (BuildContext ctx) =>
                                  BlocProvider<BenefitCubit>(
                                create: (_) => BenefitCubit(),
                                child: const CadastrarBeneficio(),
                              ),
                            );
                            unawaited(cubit.loadBenefits(userId));
                          },
                        );
                      }
                      return Column(
                        children: <Widget>[
                          for (final BenefitEntity benefit
                              in benefits) ...<Widget>[
                            _BenefitCard(
                              benefit: benefit,
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
                      onRetry: () =>
                          context.read<BenefitCubit>().loadBenefits(userId),
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
// Benefit card
// ---------------------------------------------------------------------------

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefit, required this.userId});

  final BenefitEntity benefit;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final double progress = benefit.monthlyCredit > 0
        ? (benefit.balance / benefit.monthlyCredit).clamp(0.0, 1.0)
        : 0.0;

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
                  color: Color(benefit.color),
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(benefit.name, style: AppTextStyles.bodyBold),
                    Text(
                      _typeLabel(benefit.type),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                onPressed: () => _showDeductDialog(context),
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                tooltip: 'Deduzir',
              ),
              AppIconButton(
                onPressed: () async {
                  final BenefitCubit cubit = context.read<BenefitCubit>();
                  await showFormSheet<void>(
                    context,
                    builder: (BuildContext ctx) => BlocProvider<BenefitCubit>(
                      create: (_) => BenefitCubit(),
                      child: CadastrarBeneficio(initialBenefit: benefit),
                    ),
                  );
                  unawaited(cubit.loadBenefits(userId));
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Saldo disponível', style: AppTextStyles.caption),
              Text(
                fmt.format(benefit.balance),
                style: AppTextStyles.bodyBold.copyWith(
                  color: Color(benefit.color),
                ),
              ),
            ],
          ),
          const Gap(6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(Color(benefit.color)),
            ),
          ),
          const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${(progress * 100).toStringAsFixed(0)}% do crédito mensal',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
              Text(
                fmt.format(benefit.monthlyCredit),
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeductDialog(BuildContext context) {
    unawaited(
      showAppDialog<void>(
        context: context,
        builder: (BuildContext ctx) => BlocProvider<BenefitCubit>.value(
          value: context.read<BenefitCubit>(),
          child: AppAlertDialog(
            title: const Text('Deduzir saldo'),
            content: _DeductContent(benefit: benefit),
            actions: const <Widget>[],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final BenefitCubit cubit = context.read<BenefitCubit>();
    unawaited(
      showAppDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AppAlertDialog(
          title: const Text('Excluir benefício'),
          content: Text(
            'Deseja excluir "${benefit.name}"? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            SecondaryButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            DestructiveButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                unawaited(cubit.delete(benefit.uuid, userId));
                unawaited(cubit.loadBenefits(userId));
              },
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }

  static String _typeLabel(BenefitType type) => switch (type) {
    BenefitType.va => 'Vale Alimentação',
    BenefitType.vt => 'Vale Transporte',
    BenefitType.vr => 'Vale Refeição',
    BenefitType.other => 'Outro',
  };
}

// ---------------------------------------------------------------------------
// Deduct dialog content (stateful — owns its controller)
// ---------------------------------------------------------------------------

class _DeductContent extends StatefulWidget {
  const _DeductContent({required this.benefit});

  final BenefitEntity benefit;

  @override
  State<_DeductContent> createState() => _DeductContentState();
}

class _DeductContentState extends State<_DeductContent> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      AppTextField(
        controller: _controller,
        hintText: 'Valor a deduzir',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ],
        onChanged: (_) => setState(() => _error = null),
      ),
      if (_error != null) ...<Widget>[
        const Gap(4),
        Text(
          _error!,
          style: AppTextStyles.caption.copyWith(color: AppColors.expense),
        ),
      ],
      const Gap(16),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SecondaryButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const Gap(8),
          PrimaryButton(
            onPressed: () {
              final double? amount = double.tryParse(
                _controller.text.replaceAll(',', '.'),
              );
              if (amount == null || amount <= 0) {
                setState(() => _error = 'Informe um valor válido');
                return;
              }
              Navigator.of(context).pop();
              context.read<BenefitCubit>().deduct(widget.benefit, amount);
            },
            child: const Text('Deduzir'),
          ),
        ],
      ),
    ],
  );
}
