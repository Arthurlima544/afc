import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entity/bill_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/bill/bill_cubit.dart';
import '../blocs/category/category_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_conta.dart';

class ListaContas extends StatelessWidget {
  const ListaContas({super.key});

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
                  child: Text('Contas a Pagar', style: AppTextStyles.heading),
                ),
                AppIconButton(
                  onPressed: () async {
                    final BillCubit bills = context.read<BillCubit>();
                    final String userId =
                        context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                        '';
                    await showFormSheet<void>(
                      context,
                      builder: (BuildContext ctx) => MultiBlocProvider(
                        providers: <BlocProvider<dynamic>>[
                          BlocProvider<BillCubit>(create: (_) => BillCubit()),
                          BlocProvider<CategoryCubit>(
                            create: (_) => CategoryCubit()..loadCategories(),
                          ),
                        ],
                        child: const CadastrarConta(),
                      ),
                    );
                    unawaited(bills.loadBills(userId));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          const Gap(16),
          BlocConsumer<BillCubit, BillState>(
            listener: (BuildContext context, BillState state) {
              state.whenOrNull(
                error: (String msg) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    ),
              );
            },
            builder: (BuildContext context, BillState state) => state.when(
              initial: () => const SizedBox(),
              loading: () => const SkeletonList(itemHeight: 90),
              error: (String msg) =>
                  EmptyState(message: msg, icon: Icons.error_outline),
              success: (_) => const SkeletonList(itemHeight: 90),
              listed: (List<BillEntity> bills) => bills.isEmpty
                  ? const EmptyState(
                      message:
                          'Nenhuma conta ainda.\nToque em + para cadastrar.',
                      icon: Icons.receipt_long_outlined,
                    )
                  : Column(
                      children: <Widget>[
                        for (final BillEntity bill in bills)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BillItem(bill: bill),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    ),
  ),
  );
}

class _BillItem extends StatelessWidget {
  const _BillItem({required this.bill});

  final BillEntity bill;

  _BillStatus _getStatus() {
    if (bill.isPaid) {
      return _BillStatus.paid;
    }
    final DateTime now = DateTime.now();
    final int today = now.day;
    if (bill.dueDay < today) {
      return _BillStatus.overdue;
    }
    if (bill.dueDay <= today + 7) {
      return _BillStatus.upcoming;
    }
    return _BillStatus.normal;
  }

  @override
  Widget build(BuildContext context) {
    final _BillStatus status = _getStatus();
    final Color borderColor = status == _BillStatus.paid
        ? AppColors.income
        : status == _BillStatus.overdue
        ? AppColors.expense
        : status == _BillStatus.upcoming
        ? AppColors.warning
        : const Color(0xFF3A3A3A);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(bill.name, style: AppTextStyles.title)),
                if (status == _BillStatus.paid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Pago',
                      style: TextStyle(
                        fontSize: AppTextStyle.sizeXs,
                        color: AppColors.income,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (status == _BillStatus.upcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Em breve',
                      style: TextStyle(
                        fontSize: AppTextStyle.sizeXs,
                        color: AppColors.warningText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (status == _BillStatus.overdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Venceu este mês',
                      style: TextStyle(
                        fontSize: AppTextStyle.sizeXs,
                        color: AppColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'R\$ ${bill.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyBold,
                ),
                Text(
                  'Vence dia ${bill.dueDay}',
                  style: AppTextStyles.label.copyWith(
                    color: status == _BillStatus.overdue
                        ? AppColors.expense
                        : status == _BillStatus.upcoming
                        ? AppColors.warning
                        : null,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AppIconButton(
                  onPressed: () =>
                      context.read<BillCubit>().togglePaid(bill),
                  icon: Icon(
                    bill.isPaid
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 20,
                    color: bill.isPaid ? AppColors.income : null,
                  ),
                ),
                Row(
                  children: <Widget>[
                    AppIconButton(
                      onPressed: () async {
                        final BillCubit bills = context.read<BillCubit>();
                        final String userId =
                            context.read<AuthBloc>().state.whenOrNull(
                              signedIn: (ClerkAuthState s) => s.user?.id,
                            ) ??
                            '';
                        await showFormSheet<void>(
                          context,
                          builder: (BuildContext ctx) => MultiBlocProvider(
                            providers: <BlocProvider<dynamic>>[
                              BlocProvider<BillCubit>(
                                create: (_) => BillCubit(),
                              ),
                              BlocProvider<CategoryCubit>(
                                create: (_) => CategoryCubit()..loadCategories(),
                              ),
                            ],
                            child: CadastrarConta(initialBill: bill),
                          ),
                        );
                        unawaited(bills.loadBills(userId));
                      },
                      icon: const Icon(Icons.edit, size: 18),
                    ),
                    const Gap(8),
                    AppIconButton(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
          signedIn: (ClerkAuthState s) => s.user?.id,
        ) ??
        '';
    final bool? confirmed = await showAppDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppAlertDialog(
        title: const Text('Excluir conta'),
        content: Text('Deseja excluir "${bill.name}"?'),
        actions: <Widget>[
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          const Gap(8),
          PrimaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      await context.read<BillCubit>().delete(bill.uuid, userId);
    }
  }
}

enum _BillStatus { normal, upcoming, overdue, paid }
