import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../../domain/entity/frequency_entity.dart';
import '../../domain/entity/recurring_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/app_spacing.dart';
import '../../utils/logger.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/recurring/recurring_cubit.dart';
import '../blocs/transaction/transaction_cubit.dart';

class CadastrarRecorrente extends StatefulWidget {
  const CadastrarRecorrente({super.key});

  @override
  State<CadastrarRecorrente> createState() => _CadastrarRecorrenteState();
}

class _CadastrarRecorrenteState extends State<CadastrarRecorrente> {
  final FormKey<String> _titleKey = const TextFieldKey('title');

  double _amount = 0;
  String? _typeValue;
  String? _categoryValue;
  String _frequency = FrequencyEntity.monthly.name;
  DateTime? _startDate;

  String? _typeError;
  String? _categoryError;
  String? _dateError;

  bool _validate() {
    setState(() {
      _typeError = _typeValue == null ? 'Selecione o tipo' : null;
      _categoryError = _categoryValue == null ? 'Selecione uma categoria' : null;
      _dateError = _startDate == null ? 'Selecione a data de início' : null;
    });
    return _typeError == null && _categoryError == null && _dateError == null;
  }

  @override
  Widget build(BuildContext context) => DrawerOverlay(
    child: SizedBox(
      width: 480,
      child: Form(
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (BuildContext context, TransactionState state) =>
              state.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator(size: 20)),
                error: (String msg) => Center(child: Text(msg)),
                success: (_) => const SizedBox(),
                listed: (_) => const SizedBox(),
                initial: (List<CategoryEntity> categories) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Spacer(),

                    // Title
                    FormTableLayout(
                      rows: <FormField<String>>[
                        FormField<String>(
                          key: _titleKey,
                          label: const Text('Título'),
                          child: const TextField(),
                        ),
                      ],
                    ),
                    const Gap(20),

                    // Amount
                    SizedBox(
                      width: 120,
                      child: TextField(
                        initialValue: _amount.toString(),
                        onChanged: (String v) =>
                            setState(() => _amount = double.tryParse(v) ?? 0),
                        features: const <InputFeature>[InputFeature.spinner()],
                        submitFormatters: <TextInputFormatter>[
                          TextInputFormatters.mathExpression(),
                        ],
                      ),
                    ),
                    const Gap(20),

                    // Type
                    Select<String>(
                      itemBuilder: (BuildContext context, String item) =>
                          Text(item),
                      popupConstraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 200,
                      ),
                      onChanged: (String? v) =>
                          setState(() { _typeValue = v; _typeError = null; }),
                      value: _typeValue,
                      placeholder: const Text('Tipo'),
                      popup: SelectPopup<String>(
                        items: SelectItemList(
                          children: <Widget>[
                            for (final TypeEntity t in TypeEntity.values)
                              SelectItemButton<String>(
                                value: t.name,
                                child: Text(t.name),
                              ),
                          ],
                        ),
                      ).call,
                    ),
                    if (_typeError != null) ...<Widget>[
                      const Gap(4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _typeError!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.expense,
                          ),
                        ),
                      ),
                    ],
                    const Gap(20),

                    // Category
                    Select<String>(
                      itemBuilder: (BuildContext context, String item) =>
                          Text(item),
                      popupConstraints: const BoxConstraints(
                        maxHeight: 300,
                        maxWidth: 200,
                      ),
                      onChanged: (String? v) =>
                          setState(() { _categoryValue = v; _categoryError = null; }),
                      value: _categoryValue,
                      placeholder: const Text('Categoria'),
                      popup: SelectPopup<String>(
                        items: SelectItemList(
                          children: <Widget>[
                            for (final CategoryEntity cat in categories)
                              SelectItemButton<String>(
                                value: cat.name,
                                child: Text(cat.name),
                              ),
                          ],
                        ),
                      ).call,
                    ),
                    if (_categoryError != null) ...<Widget>[
                      const Gap(4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _categoryError!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.expense,
                          ),
                        ),
                      ),
                    ],
                    const Gap(20),

                    // Frequency
                    Select<String>(
                      itemBuilder: (BuildContext context, String item) =>
                          Text(_frequencyLabel(item)),
                      popupConstraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 200,
                      ),
                      onChanged: (String? v) =>
                          setState(() => _frequency = v ?? _frequency),
                      value: _frequency,
                      placeholder: const Text('Frequência'),
                      popup: SelectPopup<String>(
                        items: SelectItemList(
                          children: <Widget>[
                            for (final FrequencyEntity f
                                in FrequencyEntity.values)
                              SelectItemButton<String>(
                                value: f.name,
                                child: Text(_frequencyLabel(f.name)),
                              ),
                          ],
                        ),
                      ).call,
                    ),
                    const Gap(20),

                    // Start date
                    DatePicker(
                      value: _startDate,
                      mode: PromptMode.dialog,
                      dialogTitle: const Text('Data de início'),
                      onChanged: (DateTime? v) {
                        setState(() { _startDate = v; _dateError = null; });
                        logger.d('Start date: $_startDate');
                      },
                    ),
                    if (_dateError != null) ...<Widget>[
                      const Gap(4),
                      Text(
                        _dateError!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                    const Gap(20),

                    // Save
                    PrimaryButton(
                      onPressed: () {
                        if (!_validate()) {
                          return;
                        }

                        final String? title =
                            Form.of(context).getValue(_titleKey);
                        final CategoryEntity selectedCategory =
                            categories.firstWhere(
                              (CategoryEntity c) => c.name == _categoryValue,
                            );

                        context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState auth) {
                            final String userId = auth.user?.id ?? '';
                            final String txUuid = const Uuid().v1();
                            final TransactionEntity template = TransactionEntity(
                              uuid: txUuid,
                              amount: _amount,
                              categoryUUid: selectedCategory.uuid,
                              typeUuid: _typeValue!,
                              data: _startDate!,
                              title: title ?? '',
                              userId: userId,
                            );
                            context.read<RecurringCubit>().create(
                              RecurringEntity(
                                uuid: const Uuid().v1(),
                                userId: userId,
                                templateTransaction: template,
                                frequency: _frequency,
                                nextDue: _startDate!,
                                active: true,
                              ),
                            );
                          },
                        );
                      },
                      trailing: const Icon(Icons.add),
                      child: const Text('Salvar'),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
        ),
      ),
    ),
  );

  String _frequencyLabel(String freq) {
    switch (freq) {
      case 'daily':
        return 'Diário';
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensal';
      default:
        return freq;
    }
  }
}
