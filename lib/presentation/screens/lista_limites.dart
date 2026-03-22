import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/limit/limit_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_limites.dart';

class ListaLimites extends StatelessWidget {
  const ListaLimites({super.key});

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
        unawaited(context.read<LimitCubit>().loadLimits(userId));
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
                  child: Text('Limites', style: AppTextStyles.heading),
                ),
                AppIconButton(
                  onPressed: () => showFormSheet<void>(
                    context,
                    builder: (BuildContext ctx) => BlocProvider<LimitCubit>(
                      create: (_) => LimitCubit(),
                      child: const CadastrarLimites(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Gap(16),
            BlocBuilder<LimitCubit, LimitState>(
              builder: (BuildContext context, LimitState state) => state.when(
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
                    context.read<LimitCubit>().loadLimits(userId);
                  },
                ),
                loaded: (_) => const SizedBox(),
                success: (_) => const SizedBox(),
                listed: (List<LimitListItem> items) => items.isEmpty
                    ? const EmptyState(
                        message:
                            'Nenhum limite ainda.\nToque em + para definir.',
                        icon: Icons.tune_outlined,
                      )
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
    ),
  );
}

class _LimiteItem extends StatelessWidget {
  const _LimiteItem({required this.item});

  final LimitListItem item;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.categoryName, style: AppTextStyles.title),
              const Gap(4),
              Text(
                '${item.limit.month} · R\$ ${item.limit.limitAmount.toStringAsFixed(2)}',
                style: AppTextStyles.label,
              ),
            ],
          ),
        ),
        AppIconButton(
          onPressed: () => showFormSheet<void>(
            context,
            builder: (BuildContext ctx) => BlocProvider<LimitCubit>(
              create: (_) => LimitCubit(),
              child: CadastrarLimites(initialLimit: item.limit),
            ),
          ),
          icon: const Icon(Icons.edit, size: 18),
        ),
        AppIconButton(
          onPressed: () =>
              context.read<LimitCubit>().deleteLimit(item.limit.uuid),
          icon: const Icon(Icons.delete, size: 18),
        ),
      ],
    ),
  );
}
