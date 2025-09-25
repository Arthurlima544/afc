import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/calendar_entity.dart';
import '../../domain/entity/category_entity.dart';
import '../../domain/entity/limit_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../blocs/limit/limit_cubit.dart';

class CadastrarLimites extends StatefulWidget {
  const CadastrarLimites({super.key});

  @override
  State<CadastrarLimites> createState() => _CadastrarLimitesState();
}

class _CadastrarLimitesState extends State<CadastrarLimites> {
  String? monthValue;
  String? categoryValue;

  double money = 0;

  @override
  Widget build(BuildContext context) => DrawerOverlay(
    child: SizedBox(
      width: 480,
      child: Form(
        child: BlocBuilder<LimitCubit, LimitState>(
          builder: (BuildContext context, LimitState state) => state.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(size: 20)),
            error: (String message) => Center(child: Text(message)),
            success: (LimitEntity limit) =>
                Center(child: Text(limit.toString())),
            initial: (List<CategoryEntity> categories) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Spacer(),
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
                      monthValue = value;
                    });
                  },
                  value: monthValue,
                  placeholder: const Text('Mês'),
                  popup: SelectPopup(
                    items: SelectItemList(
                      children: <Widget>[
                        for (final Object i in CalendarEntity.values)
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
                    final CategoryEntity selectedCategory = categories
                        .firstWhere(
                          (CategoryEntity e) => e.name == categoryValue,
                        );

                    context.read<LimitCubit>().saveLimit(
                      LimitEntity(
                        uuid: const Uuid().v1(),
                        limitAmount: money,
                        categoryUUid: selectedCategory.uuid,
                        month: monthValue ?? '',
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
  } else if (item is TypeEntity) {
    return item.name;
  } else if (item is CalendarEntity) {
    return item.name;
  } else {
    return '';
  }
}
