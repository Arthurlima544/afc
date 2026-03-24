import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/bank_profile_entity.dart';
import '../../domain/entity/import_candidate_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../blocs/import/import_cubit.dart';
import '../widgets/design_system.dart';

class ImportarExtrato extends StatefulWidget {
  const ImportarExtrato({required this.userId, super.key});

  final String userId;

  @override
  State<ImportarExtrato> createState() => _ImportarExtratoState();
}

class _ImportarExtratoState extends State<ImportarExtrato> {
  BankProfile? _bank;
  StatementType? _type;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Importar Extrato'),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocListener<ImportCubit, ImportState>(
        listener: (BuildContext context, ImportState state) {
          state.whenOrNull(done: (int _) => context.pop());
        },
        child: BlocBuilder<ImportCubit, ImportState>(
          builder: (BuildContext context, ImportState state) => state.when(
            initial: () => _PickerView(
              userId: widget.userId,
              bank: _bank,
              type: _type,
              onBankChanged: (BankProfile? b) => setState(() => _bank = b),
              onTypeChanged: (StatementType? t) => setState(() => _type = t),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            saving: () => const Center(child: CircularProgressIndicator()),
            error: (String msg) => _ErrorView(message: msg),
            done: (int _) => const SizedBox.shrink(),
            reviewed: (List<ImportCandidateEntity> candidates, String uid) =>
                _ReviewView(candidates: candidates),
          ),
        ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Initial view — bank/type selection + file picker
// ---------------------------------------------------------------------------

class _PickerView extends StatelessWidget {
  const _PickerView({
    required this.userId,
    required this.bank,
    required this.type,
    required this.onBankChanged,
    required this.onTypeChanged,
  });

  final String userId;
  final BankProfile? bank;
  final StatementType? type;
  final ValueChanged<BankProfile?> onBankChanged;
  final ValueChanged<StatementType?> onTypeChanged;

  bool get _ready => bank != null && type != null;

  String _bankLabel(BankProfile b) {
    switch (b) {
      case BankProfile.nubank:
        return 'Nubank';
    }
  }

  String _typeLabel(StatementType t) {
    switch (t) {
      case StatementType.extrato:
        return 'Extrato (histórico de conta)';
      case StatementType.fatura:
        return 'Fatura (cartão de crédito)';
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      const Text('Importar Extrato', style: AppTextStyles.heading),
      const Gap(4),
      const Text(
        'Selecione seu banco e tipo de arquivo antes de continuar.',
        style: AppTextStyles.body,
      ),
      const Gap(24),

      // Bank selector
      const Text('Banco', style: AppTextStyles.labelBold),
      const Gap(8),
      DropdownButtonFormField<BankProfile>(
        initialValue: bank,
        hint: const Text('Selecione o banco'),
        decoration: const InputDecoration(),
        onChanged: onBankChanged,
        items: BankProfile.values
            .map(
              (BankProfile b) => DropdownMenuItem<BankProfile>(
                value: b,
                child: Text(_bankLabel(b)),
              ),
            )
            .toList(),
      ),
      const Gap(20),

      // Statement type selector
      const Text('Tipo de arquivo', style: AppTextStyles.labelBold),
      const Gap(8),
      DropdownButtonFormField<StatementType>(
        initialValue: type,
        hint: const Text('Selecione o tipo'),
        decoration: const InputDecoration(),
        onChanged: onTypeChanged,
        items: StatementType.values
            .map(
              (StatementType t) => DropdownMenuItem<StatementType>(
                value: t,
                child: Text(_typeLabel(t)),
              ),
            )
            .toList(),
      ),
      const Gap(32),

      PrimaryButton(
        onPressed: _ready
            ? () => context.read<ImportCubit>().pickFile(
                userId,
                bankProfile: bank,
                statementType: type,
              )
            : null,
        child: const Text('Escolher arquivo'),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Review view — list of parsed candidates
// ---------------------------------------------------------------------------

class _ReviewView extends StatelessWidget {
  const _ReviewView({required this.candidates});

  final List<ImportCandidateEntity> candidates;

  int get _accepted => candidates
      .where((ImportCandidateEntity c) => c.status == ImportStatus.accepted)
      .length;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Row(
        children: <Widget>[
          const Expanded(
            child: Text('Revisar importação', style: AppTextStyles.heading),
          ),
          Text('${candidates.length} linhas', style: AppTextStyles.caption),
        ],
      ),
      const Gap(4),
      Text(
        '$_accepted selecionadas · '
        '${candidates.where((ImportCandidateEntity c) => c.isDuplicate).length} duplicatas',
        style: AppTextStyles.label,
      ),
      const Gap(8),
      Row(
        children: <Widget>[
          OutlineButton(
            onPressed: () => context.read<ImportCubit>().acceptAll(),
            child: const Text('Aceitar todas'),
          ),
          const Gap(8),
          PrimaryButton(
            onPressed: _accepted > 0
                ? () => context.read<ImportCubit>().saveAccepted()
                : null,
            child: Text('Importar $_accepted'),
          ),
        ],
      ),
      const Gap(12),
      Expanded(
        child: ListView.separated(
          itemCount: candidates.length,
          separatorBuilder: (BuildContext context, int _) => const Gap(8),
          itemBuilder: (BuildContext context, int index) =>
              _CandidateItem(candidate: candidates[index], index: index),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Candidate row
// ---------------------------------------------------------------------------

class _CandidateItem extends StatelessWidget {
  const _CandidateItem({required this.candidate, required this.index});

  final ImportCandidateEntity candidate;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool isAccepted = candidate.status == ImportStatus.accepted;
    final bool isRejected = candidate.status == ImportStatus.rejected;
    final bool isExpense = candidate.typeUuid == TypeEntity.expense.name;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: isAccepted,
            onChanged: candidate.isDuplicate
                ? null
                : (_) {
                    if (isAccepted) {
                      context.read<ImportCubit>().reject(index);
                    } else {
                      context.read<ImportCubit>().accept(index);
                    }
                  },
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  candidate.title,
                  style: isRejected
                      ? AppTextStyles.label.copyWith(
                          color: const Color(0xFF9CA3AF),
                          decoration: TextDecoration.lineThrough,
                        )
                      : AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(candidate.date),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (candidate.isDuplicate) ...<Widget>[
            const _Badge(
              label: 'Duplicata',
              color: AppColors.warningText,
              background: AppColors.warningBackground,
            ),
            const Gap(6),
          ],
          if (!candidate.isDuplicate && candidate.categoryConfidence > 0) ...<Widget>[
            _ConfidenceBadge(confidence: candidate.categoryConfidence),
            const Gap(6),
          ],
          Text(
            'R\$ ${candidate.amount.toStringAsFixed(2)}',
            style: AppTextStyles.labelBold.copyWith(
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confidence badge
// ---------------------------------------------------------------------------

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color background;
    final String label;

    if (confidence >= 0.8) {
      color = AppColors.income;
      background = AppColors.income.withValues(alpha: 0.12);
      label = 'Auto';
    } else if (confidence >= 0.5) {
      color = AppColors.warningText;
      background = AppColors.warningBackground;
      label = 'Revisar';
    } else {
      color = AppColors.expense;
      background = AppColors.expense.withValues(alpha: 0.12);
      label = 'Manual';
    }

    return _Badge(label: label, color: color, background: background);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: AppTextStyles.captionBold.copyWith(color: color),
    ),
  );
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.error_outline, size: 48),
        const Gap(12),
        Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
        const Gap(16),
        OutlineButton(
          onPressed: () => context.read<ImportCubit>().reset(),
          child: const Text('Tentar novamente'),
        ),
      ],
    ),
  );
}
