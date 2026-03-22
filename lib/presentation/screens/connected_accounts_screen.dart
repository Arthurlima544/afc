import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;

import '../../domain/entity/connected_account_entity.dart';
import '../../utils/app_spacing.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/open_finance/open_finance_cubit.dart';

class ConnectedAccountsScreen extends StatelessWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';

    return BlocConsumer<OpenFinanceCubit, OpenFinanceState>(
      listener: (BuildContext ctx, OpenFinanceState state) async {
        await state.whenOrNull(
          tokenReady: (String connectToken) async {
            final String? itemId =
                await ctx.push<String?>('/connect-bank', extra: connectToken);
            if (itemId != null && ctx.mounted) {
              await ctx.read<OpenFinanceCubit>().saveConnectedAccount(
                    itemId,
                    userId,
                  );
            }
          },
          error: (String message) async {
            showToast(
              context: ctx,
              builder: (BuildContext toastCtx, ToastOverlay overlay) =>
                  SurfaceCard(
                child: Basic(
                  title: const Text('Erro'),
                  subtitle: Text(message),
                  trailing: PrimaryButton(
                    onPressed: overlay.close,
                    child: const Text('OK'),
                  ),
                ),
              ),
            );
          },
        );
      },
      builder: (BuildContext context, OpenFinanceState state) => SafeArea(
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
                      'Contas Conectadas',
                      style: AppTextStyles.heading,
                    ),
                  ),
                  IconButton(
                    variance: const ButtonStyle.outline(),
                    onPressed: () =>
                        context.read<OpenFinanceCubit>().createConnectToken(
                              userId,
                            ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const Gap(16),
              state.when(
                initial: SizedBox.new,
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                tokenReady: (_) =>
                    const Center(child: CircularProgressIndicator()),
                error: Text.new,
                listed: (List<ConnectedAccountEntity> accounts) =>
                    accounts.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Nenhuma conta conectada. Toque em + para conectar seu banco.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Column(
                            children: <Widget>[
                              for (final ConnectedAccountEntity account
                                  in accounts)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _AccountCard(
                                    account: account,
                                    userId: userId,
                                  ),
                                ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.userId,
  });

  final ConnectedAccountEntity account;
  final String userId;

  String _formatSyncTime(DateTime? lastSynced) {
    if (lastSynced == null) {
      return 'Nunca sincronizado';
    }
    final Duration diff = DateTime.now().difference(lastSynced);
    if (diff.inMinutes < 1) {
      return 'Sincronizado agora';
    }
    if (diff.inHours < 1) {
      return 'Sincronizado ${diff.inMinutes} min atrás';
    }
    if (diff.inDays < 1) {
      return 'Sincronizado ${diff.inHours}h atrás';
    }
    return 'Sincronizado em ${DateFormat('dd/MM/yyyy').format(lastSynced)}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.income;
      case 'consent_expired':
        return AppColors.warning;
      default:
        return AppColors.expense;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'consent_expired':
        return 'Consentimento expirado';
      case 'syncing':
        return 'Sincronizando';
      default:
        return 'Erro';
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      account.institutionName,
                      style: AppTextStyles.title,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(account.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(account.status),
                      style: AppTextStyles.captionBold.copyWith(
                        color: _statusColor(account.status),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(4),
              Text(
                _formatSyncTime(account.lastSyncedAt),
                style: AppTextStyles.caption,
              ),
              const Gap(8),
              Row(
                children: <Widget>[
                  if (account.status == 'consent_expired')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PrimaryButton(
                        onPressed: () =>
                            context.read<OpenFinanceCubit>().createConnectToken(
                                  userId,
                                  itemId: account.pluggyItemId,
                                ),
                        child: const Text('Reconectar'),
                      ),
                    ),
                  DestructiveButton(
                    onPressed: () => context
                        .read<OpenFinanceCubit>()
                        .disconnectAccount(account.uuid, userId),
                    child: const Text('Desconectar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
