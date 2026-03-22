import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/calendar_entity.dart';
import '../../domain/entity/category_entity.dart';
import '../../domain/entity/limit_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/app_spacing.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/limit/limit_cubit.dart';

class CadastrarLimites extends StatefulWidget {
  const CadastrarLimites({super.key, this.initialLimit});

  final LimitEntity? initialLimit;

  @override
  State<CadastrarLimites> createState() => _CadastrarLimitesState();
}

class _CadastrarLimitesState extends State<CadastrarLimites> {
  String? monthValue;
  String? categoryValue;

  double money = 0;

  String? _monthError;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    if (widget.initialLimit != null) {
      final LimitEntity limit = widget.initialLimit!;
      money = limit.limitAmount;
      monthValue = limit.month;
    }
  }

  bool _validate() {
    setState(() {
      _monthError = monthValue == null ? 'Selecione o mês' : null;
      _categoryError = categoryValue == null ? 'Selecione uma categoria' : null;
    });
    return _monthError == null && _categoryError == null;
  }

  @override
  Widget build(BuildContext context) => DrawerOverlay(
    child: SizedBox(
      width: 480,
      child: Form(
        child: BlocConsumer<LimitCubit, LimitState>(
          listener: (BuildContext context, LimitState state) {
            state.whenOrNull(
              initial: (List<CategoryEntity> categories) {
                if (widget.initialLimit != null && categoryValue == null) {
                  for (final CategoryEntity cat in categories) {
                    if (cat.uuid == widget.initialLimit!.categoryUUid) {
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
          builder: (BuildContext context, LimitState state) => state.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(size: 20)),
            error: (String message) => Center(child: Text(message)),
            loaded: (_) => const SizedBox(),
            listed: (_) => const SizedBox(),
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
                      _monthError = null;
                    });
                  },
                  value: monthValue,
                  placeholder: const Text('Mês'),
                  popup: SelectPopup<String>(
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
                if (_monthError != null) ...<Widget>[
                  const Gap(4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _monthError!,
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

                PrimaryButton(
                  onPressed: () {
                    if (!_validate()) {
                      return;
                    }

                    final CategoryEntity selectedCategory = categories
                        .firstWhere(
                          (CategoryEntity e) => e.name == categoryValue,
                        );

                    context.read<AuthBloc>().state.whenOrNull(
                      signedIn: (ClerkAuthState authState) {
                        final String userId = authState.user?.id ?? '';
                        if (widget.initialLimit != null) {
                          context.read<LimitCubit>().updateLimit(
                            LimitEntity(
                              uuid: widget.initialLimit!.uuid,
                              limitAmount: money,
                              categoryUUid: selectedCategory.uuid,
                              month: monthValue ?? '',
                              userId: userId,
                            ),
                          );
                        } else {
                          context.read<LimitCubit>().saveLimit(
                            LimitEntity(
                              uuid: const Uuid().v1(),
                              limitAmount: money,
                              categoryUUid: selectedCategory.uuid,
                              month: monthValue ?? '',
                              userId: userId,
                            ),
                          );
                        }
                      },
                    );
                  },
                  trailing: const Icon(Icons.add),
                  child: Text(
                    widget.initialLimit != null ? 'Salvar' : 'Add',
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
  } else if (item is CalendarEntity) {
    return item.name;
  } else {
    return '';
  }
}
