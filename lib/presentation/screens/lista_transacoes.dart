import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/sub_account_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../domain/usecase/transaction_grouper.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/sub_account/sub_account_cubit.dart';
import '../blocs/transaction/transaction_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_transacao.dart';

enum _ViewMode { byDate, byGroup }

class ListaTransacoes extends StatefulWidget {
  const ListaTransacoes({super.key});

  @override
  State<ListaTransacoes> createState() => _ListaTransacoesState();
}

class _ListaTransacoesState extends State<ListaTransacoes> {
  _ViewMode _viewMode = _ViewMode.byDate;
  String? _filterSubAccountUuid;

  // Search & filter state
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  DateTime? _filterFrom;
  DateTime? _filterTo;
  String? _filterType; // null = all, 'income', 'expense'

  late final SubAccountCubit _subAccountCubit;

  bool get _hasActiveFilter =>
      _searchQuery.isNotEmpty ||
      _filterFrom != null ||
      _filterTo != null ||
      _filterType != null ||
      _filterSubAccountUuid != null;

  @override
  void initState() {
    super.initState();
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';
    _subAccountCubit = SubAccountCubit()..loadAccounts(userId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _subAccountCubit.close();
    super.dispose();
  }

  List<TransactionEntity> _applyFilters(List<TransactionEntity> txs) =>
      txs.where((TransactionEntity tx) {
      if (_filterSubAccountUuid != null &&
          tx.subAccountUuid != _filterSubAccountUuid) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !tx.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterFrom != null && tx.data.isBefore(_filterFrom!)) {
        return false;
      }
      if (_filterTo != null &&
          tx.data.isAfter(
            _filterTo!.add(const Duration(days: 1)),
          )) {
        return false;
      }
      if (_filterType != null && tx.typeUuid != _filterType) {
        return false;
      }
      return true;
    }).toList();

  void _clearAllFilters() {
    setState(() {
      _searchCtrl.clear();
      _searchQuery = '';
      _filterFrom = null;
      _filterTo = null;
      _filterType = null;
      _filterSubAccountUuid = null;
    });
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _filterFrom != null && _filterTo != null
          ? DateTimeRange(start: _filterFrom!, end: _filterTo!)
          : null,
      locale: const Locale('pt', 'BR'),
    );
    if (range != null) {
      setState(() {
        _filterFrom = range.start;
        _filterTo = range.end;
      });
    }
  }

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
        await Future.wait<void>(<Future<void>>[
          context.read<TransactionCubit>().loadTransactions(userId),
          Future<void>.delayed(const Duration(milliseconds: 600)),
        ]);
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
                  child: Text('Transações', style: AppTextStyles.heading),
                ),
                AppIconButton(
                  onPressed: () => context.push('/lista-recorrentes'),
                  icon: const Icon(Icons.repeat_outlined),
                  tooltip: 'Recorrências',
                ),
                const Gap(8),
                AppIconButton(
                  onPressed: () => context.push('/relatorio'),
                  icon: const Icon(Icons.analytics_outlined),
                ),
                const Gap(8),
                AppIconButton(
                  onPressed: () => context.push('/importar-extrato'),
                  icon: const Icon(Icons.upload_file_outlined),
                ),
                const Gap(8),
                AppIconButton(
                  onPressed: () => showFormSheet<void>(
                    context,
                    builder: (BuildContext ctx) =>
                        BlocProvider<TransactionCubit>(
                          create: (_) => TransactionCubit()..getCategories(),
                          child: const CadastrarTransacao(),
                        ),
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Gap(12),
            // Search bar
            AppTextField(
              controller: _searchCtrl,
              hintText: 'Buscar por título…',
              onChanged: (String v) => setState(() => _searchQuery = v),
            ),
            const Gap(10),
            // Filter chips row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  // View-mode
                  _ToggleChip(
                    label: 'Por data',
                    selected: _viewMode == _ViewMode.byDate,
                    onTap: () => setState(() => _viewMode = _ViewMode.byDate),
                  ),
                  const Gap(8),
                  _ToggleChip(
                    label: 'Por grupo',
                    selected: _viewMode == _ViewMode.byGroup,
                    onTap: () =>
                        setState(() => _viewMode = _ViewMode.byGroup),
                  ),
                  const Gap(8),
                  // Type filter
                  _ToggleChip(
                    label: 'Receitas',
                    selected: _filterType == 'income',
                    onTap: () => setState(
                      () => _filterType =
                          _filterType == 'income' ? null : 'income',
                    ),
                  ),
                  const Gap(8),
                  _ToggleChip(
                    label: 'Despesas',
                    selected: _filterType == 'expense',
                    onTap: () => setState(
                      () => _filterType =
                          _filterType == 'expense' ? null : 'expense',
                    ),
                  ),
                  const Gap(8),
                  // Date range
                  if (_filterFrom == null)
                    _ToggleChip(
                      label: 'Período',
                      selected: false,
                      onTap: _pickDateRange,
                      icon: Icons.date_range_outlined,
                    )
                  else
                    _ToggleChip(
                      label:
                          '${DateFormat('dd/MM').format(_filterFrom!)}–'
                          '${DateFormat('dd/MM').format(_filterTo!)}',
                      selected: true,
                      onTap: _pickDateRange,
                      trailing: Icons.close,
                      onTrailingTap: () => setState(() {
                        _filterFrom = null;
                        _filterTo = null;
                      }),
                    ),
                  if (_hasActiveFilter) ...<Widget>[
                    const Gap(8),
                    _ToggleChip(
                      label: 'Limpar',
                      selected: false,
                      onTap: _clearAllFilters,
                      icon: Icons.filter_alt_off_outlined,
                    ),
                  ],
                ],
              ),
            ),
            const Gap(8),
            // Sub-account filter chips (only when ≥ 1 sub-account exists)
            BlocBuilder<SubAccountCubit, SubAccountState>(
              bloc: _subAccountCubit,
              builder: (BuildContext context, SubAccountState saState) {
                final List<SubAccountEntity> accounts =
                    saState.whenOrNull(
                      listed: (List<SubAccountEntity> a, _) => a,
                    ) ??
                    <SubAccountEntity>[];
                if (accounts.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Gap(8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _ToggleChip(
                            label: 'Todas',
                            selected: _filterSubAccountUuid == null,
                            onTap: () =>
                                setState(() => _filterSubAccountUuid = null),
                          ),
                          const Gap(8),
                          for (final SubAccountEntity acc in accounts) ...<
                              Widget>[
                            _ToggleChip(
                              label: acc.name,
                              selected: _filterSubAccountUuid == acc.uuid,
                              onTap: () => setState(
                                () => _filterSubAccountUuid = acc.uuid,
                              ),
                            ),
                            const Gap(8),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Gap(16),
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (BuildContext context, TransactionState state) =>
                  state.when(
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
                        context
                            .read<TransactionCubit>()
                            .loadTransactions(userId);
                      },
                    ),
                    success: (_) => const SizedBox(),
                    listed: (List<TransactionEntity> txs) {
                      final List<TransactionEntity> filtered =
                          _applyFilters(txs);
                      if (filtered.isEmpty) {
                        return const EmptyState(
                          message:
                              'Nenhuma transação ainda.\nToque em + para adicionar.',
                          icon: Icons.receipt_long_outlined,
                        );
                      }
                      return _viewMode == _ViewMode.byDate
                          ? _DateList(txs: filtered)
                          : _GroupList(txs: filtered);
                    },
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// By-date view (original flat list)
// ---------------------------------------------------------------------------

class _DateList extends StatelessWidget {
  const _DateList({required this.txs});

  final List<TransactionEntity> txs;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (final TransactionEntity tx in txs)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TransacaoItem(tx: tx),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// By-group view
// ---------------------------------------------------------------------------

class _GroupList extends StatelessWidget {
  const _GroupList({required this.txs});

  final List<TransactionEntity> txs;

  @override
  Widget build(BuildContext context) {
    final List<TransactionGroup> groups = TransactionGrouper.group(txs);
    return Column(
      children: <Widget>[
        for (final TransactionGroup group in groups) ...<Widget>[
          _GroupHeader(group: group),
          const Gap(6),
          for (final TransactionEntity tx in group.transactions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TransacaoItem(tx: tx),
            ),
          const Gap(12),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final TransactionGroup group;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: Text(group.label, style: AppTextStyles.sectionTitle),
      ),
      Text(
        '${group.transactions.length} · '
        '${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(group.total)}',
        style: AppTextStyles.caption,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Toggle chip
// ---------------------------------------------------------------------------

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailing,
    this.onTrailingTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.muted.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: 14,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            const Gap(4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.primary : null,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
          if (trailing != null) ...<Widget>[
            const Gap(4),
            GestureDetector(
              onTap: onTrailingTap,
              child: Icon(
                trailing,
                size: 14,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Transaction row
// ---------------------------------------------------------------------------

class _TransacaoItem extends StatelessWidget {
  const _TransacaoItem({required this.tx});

  final TransactionEntity tx;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = tx.typeUuid == TypeEntity.income.name;
    final double displayAmount = isIncome ? tx.amount : -tx.amount;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(tx.title, style: AppTextStyles.title),
                const Gap(4),
                Text(
                  '${_formatCurrency(displayAmount)} · '
                  '${DateFormat('dd/MM/yyyy').format(tx.data)}',
                  style: AppTextStyles.label.copyWith(
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_TxAction>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (_TxAction action) {
              if (action == _TxAction.edit) {
                showFormSheet<void>(
                  context,
                  builder: (BuildContext ctx) =>
                      BlocProvider<TransactionCubit>(
                        create: (_) => TransactionCubit()..getCategories(),
                        child: CadastrarTransacao(initialTransaction: tx),
                      ),
                );
              } else {
                context
                    .read<TransactionCubit>()
                    .deleteTransaction(tx.uuid);
              }
            },
            itemBuilder: (_) => const <PopupMenuEntry<_TxAction>>[
              PopupMenuItem<_TxAction>(
                value: _TxAction.edit,
                child: Text('Editar'),
              ),
              PopupMenuItem<_TxAction>(
                value: _TxAction.delete,
                child: Text('Excluir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(amount);

enum _TxAction { edit, delete }
