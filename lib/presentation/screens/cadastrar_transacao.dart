import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../../domain/entity/template_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/app_spacing.dart';
import '../../utils/logger.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/template/template_cubit.dart';
import '../blocs/transaction/transaction_cubit.dart';

class CadastrarTransacao extends StatefulWidget {
  const CadastrarTransacao({super.key, this.initialTransaction});

  final TransactionEntity? initialTransaction;

  @override
  State<CadastrarTransacao> createState() => _CadastrarTransacaoState();
}

class _CadastrarTransacaoState extends State<CadastrarTransacao> {
  final FormKey<String> _titleKey = const TextFieldKey('title');
  DateTime? _value;
  String? typeValue;
  String? categoryValue;

  double money = 0;
  bool _saveAsTemplate = false;

  final TemplateCubit _templateCubit = TemplateCubit();

  String? _dateError;
  String? _typeError;
  String? _categoryError;

  @override
  void dispose() {
    _templateCubit.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final TransactionEntity tx = widget.initialTransaction!;
      money = tx.amount;
      _value = tx.data;
      typeValue = tx.typeUuid;
    }
  }

  bool _validate(List<CategoryEntity> categories) {
    bool valid = true;
    setState(() {
      _dateError = _value == null ? 'Selecione uma data' : null;
      _typeError = typeValue == null ? 'Selecione o tipo' : null;
      _categoryError = categoryValue == null ? 'Selecione uma categoria' : null;
    });
    if (_dateError != null || _typeError != null || _categoryError != null) {
      valid = false;
    }
    return valid;
  }

  @override
  Widget build(BuildContext context) => DrawerOverlay(
    child: SizedBox(
      width: 480,
      child: Form(
        child: BlocConsumer<TransactionCubit, TransactionState>(
          listener: (BuildContext context, TransactionState state) {
            state.whenOrNull(
              initial: (List<CategoryEntity> categories) {
                if (widget.initialTransaction != null &&
                    categoryValue == null) {
                  for (final CategoryEntity cat in categories) {
                    if (cat.uuid ==
                        widget.initialTransaction!.categoryUUid) {
                      setState(() {
                        categoryValue = cat.name;
                      });
                      break;
                    }
                  }
                }
              },
            );
          },
          builder: (BuildContext context, TransactionState state) =>
              state.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator(size: 20)),
                error: (String message) => Center(child: Text(message)),
                success: (TransactionEntity transaction) =>
                    Center(child: Text(transaction.toString())),
                listed: (_) => const SizedBox(),
                initial: (List<CategoryEntity> categories) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Spacer(),
                    DatePicker(
                      value: _value,
                      mode: PromptMode.dialog,
                      dialogTitle: const Text('Select Date'),
                      stateBuilder: (DateTime date) {
                        if (date.isAfter(DateTime.now())) {
                          return DateState.disabled;
                        }
                        return DateState.enabled;
                      },
                      onChanged: (DateTime? value) {
                        setState(() {
                          _value = value;
                          _dateError = null;
                        });
                        logger.d('Date picked $_value');
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
                    FormTableLayout(
                      rows: <FormField<String>>[
                        FormField<String>(
                          key: _titleKey,
                          label: const Text('Título'),
                          child: TextField(
                            initialValue: widget.initialTransaction?.title,
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        initialValue: money.toString(),
                        onChanged: (String money) {
                          setState(() {
                            this.money = double.tryParse(money) ?? 0;
                          });
                        },
                        features: const <InputFeature>[
                          InputFeature.spinner(),
                        ],
                        submitFormatters: <TextInputFormatter>[
                          TextInputFormatters.mathExpression(),
                        ],
                      ),
                    ),
                    const Gap(20),
                    Select<String>(
                      itemBuilder: (BuildContext context, String item) =>
                          Text(item),
                      popupConstraints: const BoxConstraints(
                        maxHeight: 300,
                        maxWidth: 200,
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          typeValue = value;
                          _typeError = null;
                        });
                      },
                      value: typeValue,
                      placeholder: const Text('Tipo'),
                      popup: SelectPopup<String>(
                        items: SelectItemList(
                          children: <Widget>[
                            for (final Object i in TypeEntity.values)
                              SelectItemButton<String>(
                                value: convertToString(i),
                                child: Text(convertToString(i)),
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
                    Select<String>(
                      itemBuilder: (BuildContext context, String item) =>
                          Text(item),
                      popupConstraints: const BoxConstraints(
                        maxHeight: 300,
                        maxWidth: 200,
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          categoryValue = value;
                          _categoryError = null;
                        });
                      },
                      value: categoryValue,
                      placeholder: const Text('Categoria'),
                      popup: SelectPopup<String>(
                        items: SelectItemList(
                          children: <Widget>[
                            for (final Object i in categories)
                              SelectItemButton<String>(
                                value: convertToString(i),
                                child: Text(convertToString(i)),
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

                    // Save as template toggle (only for new transactions)
                    if (widget.initialTransaction == null) ...<Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            state: _saveAsTemplate
                                ? CheckboxState.checked
                                : CheckboxState.unchecked,
                            onChanged: (_) => setState(
                              () => _saveAsTemplate = !_saveAsTemplate,
                            ),
                          ),
                          const Gap(8),
                          const Text(
                            'Salvar como modelo',
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                      const Gap(16),
                    ],

                    PrimaryButton(
                      onPressed: () {
                        if (!_validate(categories)) {
                          return;
                        }

                        final String? titleOrNull = Form.of(
                          context,
                        ).getValue(_titleKey);

                        final CategoryEntity selectedCategory =
                            categories.firstWhere(
                              (CategoryEntity e) => e.name == categoryValue,
                            );

                        context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState authState) {
                            final String userId = authState.user?.id ?? '';
                            if (widget.initialTransaction != null) {
                              context
                                  .read<TransactionCubit>()
                                  .updateTransaction(
                                    TransactionEntity(
                                      uuid: widget.initialTransaction!.uuid,
                                      amount: money,
                                      categoryUUid: selectedCategory.uuid,
                                      typeUuid: typeValue ?? '',
                                      data: _value ?? DateTime.now(),
                                      title: titleOrNull ??
                                          widget.initialTransaction!.title,
                                      userId: userId,
                                    ),
                                  );
                            } else {
                              final String title = titleOrNull ?? '';
                              context
                                  .read<TransactionCubit>()
                                  .saveTransaction(
                                    TransactionEntity(
                                      uuid: const Uuid().v1(),
                                      amount: money,
                                      categoryUUid: selectedCategory.uuid,
                                      typeUuid: typeValue ?? '',
                                      data: _value ?? DateTime.now(),
                                      title: title,
                                      userId: userId,
                                    ),
                                  );
                              if (_saveAsTemplate) {
                                _templateCubit.save(
                                  TemplateEntity(
                                    uuid: const Uuid().v1(),
                                    userId: userId,
                                    title: title.isEmpty
                                        ? selectedCategory.name
                                        : title,
                                    amount: money,
                                    categoryUUid: selectedCategory.uuid,
                                    typeUuid: typeValue ?? '',
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                      trailing: const Icon(Icons.add),
                      child: Text(
                        widget.initialTransaction != null ? 'Salvar' : 'Add',
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
        ),
      ),
    ),
  );
}

String convertToString(Object item) {
  if (item is CategoryEntity) {
    return item.name;
  } else if (item is String) {
    return item;
  } else if (item is TypeEntity) {
    return item.name;
  } else {
    return '';
  }
}
