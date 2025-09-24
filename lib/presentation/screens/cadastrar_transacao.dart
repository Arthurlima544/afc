import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../blocs/transaction/transaction_cubit.dart';

class CadastrarTransacao extends StatefulWidget {
  const CadastrarTransacao({super.key});

  @override
  State<CadastrarTransacao> createState() => _CadastrarTransacaoState();
}

class _CadastrarTransacaoState extends State<CadastrarTransacao> {
  final FormKey<String> _titleKey = const TextFieldKey('title');
  DateTime? _value;
  String? typeValue;
  String? categoryValue;

  double money = 0;

  @override
  Widget build(BuildContext context) => DrawerOverlay(
    child: SizedBox(
      width: 480,
      child: Form(
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (BuildContext context, TransactionState state) => state.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(size: 20)),
            error: (String message) => Center(child: Text(message)),
            success: (TransactionEntity transaction) =>
                Center(child: Text(transaction.toString())),
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
                    });
                    print('Date picked $_value');
                  },
                ),
                const Gap(20),
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
                SizedBox(
                  width: 100,
                  child: TextField(
                    initialValue: money.toString(),
                    onChanged: (String money) {
                      setState(() {
                        this.money = double.tryParse(money) ?? 0;
                      });
                    },
                    features: const <InputFeature>[InputFeature.spinner()],
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
                    });
                  },
                  value: typeValue,
                  placeholder: const Text('Tipo'),
                  popup: SelectPopup(
                    items: SelectItemList(
                      children: <Widget>[
                        for (final Object i in <Object>['Fake Type'])
                          SelectItemButton<String>(
                            value: convertToString(i),
                            child: Text(convertToString(i)),
                          ),
                      ],
                    ),
                  ).call,
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
                      categoryValue = value;
                    });
                  },
                  value: categoryValue,
                  placeholder: const Text('Categoria'),
                  popup: SelectPopup(
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
                const Gap(20),

                PrimaryButton(
                  onPressed: () {
                    final String? titleOrNull = Form.of(
                      context,
                    ).getValue(_titleKey);

                    final CategoryEntity selectedCategory = categories
                        .firstWhere(
                          (CategoryEntity e) => e.name == categoryValue,
                        );

                    context.read<TransactionCubit>().saveTransaction(
                      TransactionEntity(
                        uuid: const Uuid().v1(),
                        amount: money,
                        categoryUUid: selectedCategory.uuid,
                        typeUuid: typeValue ?? '',
                        data: _value ?? DateTime.now(),
                        title: titleOrNull ?? '',
                      ),
                    );
                  },
                  trailing: const Icon(Icons.add),
                  child: const Text('Add'),
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
  } else {
    return '';
  }
}
