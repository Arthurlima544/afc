import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;

import '../../domain/entity/bank_profile_entity.dart';
import '../../domain/entity/import_candidate_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/app_spacing.dart';
import '../blocs/import/import_cubit.dart';

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
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: BlocListener<ImportCubit, ImportState>(
        listener: (BuildContext context, ImportState state) {
          state.whenOrNull(
            done: (int _) => context.pop(),
          );
        },
        child: BlocBuilder<ImportCubit, ImportState>(
          builder: (BuildContext context, ImportState state) => state.when(
            initial: () => _PickerView(
              userId: widget.userId,
              bank: _bank,
              type: _type,
              onBankChanged: (BankProfile? b) =>
                  setState(() => _bank = b),
              onTypeChanged: (StatementType? t) =>
                  setState(() => _type = t),
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator(size: 32)),
            saving: () =>
                const Center(child: CircularProgressIndicator(size: 32)),
            error: (String msg) =>
                _ErrorView(message: msg),
            done: (int _) => const SizedBox.shrink(),
            reviewed: (
              List<ImportCandidateEntity> candidates,
              String uid,
            ) =>
                _ReviewView(candidates: candidates),
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
      Select<BankProfile>(
        itemBuilder: (BuildContext context, BankProfile item) =>
            Text(_bankLabel(item)),
        popupConstraints: const BoxConstraints(
          maxHeight: 200,
          maxWidth: 220,
        ),
        onChanged: onBankChanged,
        value: bank,
        placeholder: const Text('Selecione o banco'),
        popup: SelectPopup<BankProfile>(
          items: SelectItemList(
            children: <Widget>[
              for (final BankProfile b in BankProfile.values)
                SelectItemButton<BankProfile>(
                  value: b,
                  child: Text(_bankLabel(b)),
                ),
            ],
          ),
        ).call,
      ),
      const Gap(20),

      // Statement type selector
      const Text('Tipo de arquivo', style: AppTextStyles.labelBold),
      const Gap(8),
      Select<StatementType>(
        itemBuilder: (BuildContext context, StatementType item) =>
            Text(_typeLabel(item)),
        popupConstraints: const BoxConstraints(
          maxHeight: 200,
          maxWidth: 280,
        ),
        onChanged: onTypeChanged,
        value: type,
        placeholder: const Text('Selecione o tipo'),
        popup: SelectPopup<StatementType>(
          items: SelectItemList(
            children: <Widget>[
              for (final StatementType t in StatementType.values)
                SelectItemButton<StatementType>(
                  value: t,
                  child: Text(_typeLabel(t)),
                ),
            ],
          ),
        ).call,
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
        leading: const Icon(Icons.folder_open_outlined),
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

  int get _accepted =>
      candidates
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
          itemBuilder: (BuildContext context, int index) => _CandidateItem(
            candidate: candidates[index],
            index: index,
          ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Checkbox(
              state: isAccepted
                  ? CheckboxState.checked
                  : CheckboxState.unchecked,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Duplicata',
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.warningText,
                  ),
                ),
              ),
              const Gap(8),
            ],
            Text(
              'R\$ ${candidate.amount.toStringAsFixed(2)}',
              style: AppTextStyles.labelBold.copyWith(
                color: isExpense ? AppColors.expense : AppColors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
