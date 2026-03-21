import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../blocs/category/category_cubit.dart';

List<IconData> iconList = <IconData>[
  Icons.share_outlined,
  Icons.play_arrow_rounded,
  Icons.local_taxi,
  Icons.star_border,
  Icons.camera_alt_outlined,
  Icons.calendar_month,
  Icons.file_upload_outlined,
  Icons.coffee,
  Icons.savings,
  Icons.access_time_rounded,
  Icons.heart_broken,
  Icons.compare_arrows_rounded,
];

class CadastrarCategoria extends StatefulWidget {
  const CadastrarCategoria({super.key, this.initialCategory});

  final CategoryEntity? initialCategory;

  @override
  State<CadastrarCategoria> createState() => _CadastrarCategoriaState();
}

class _CadastrarCategoriaState extends State<CadastrarCategoria> {
  final FormKey<String> _categoryKey = const TextFieldKey('category');

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 480,
    child: Form(
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (BuildContext context, CategoryState state) => state.when(
          initial: (int index) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FormTableLayout(
                rows: <FormField<String>>[
                  FormField<String>(
                    key: _categoryKey,
                    label: const Text('Categoria'),
                    child: TextField(
                      initialValue: widget.initialCategory?.name,
                      hintText: 'Adicione uma Categoria',
                    ),
                  ),
                ],
              ).withPadding(top: 40, left: 20, right: 20, bottom: 20),
              const Text('Selecione um ícone'),
              Row(
                children: <Widget>[
                  for (int i = 0; i < 6; i++)
                    IconButton(
                      onPressed: () {
                        context
                            .read<CategoryCubit>()
                            .changeSelectedCategory(i);
                      },
                      variance: index == i
                          ? const ButtonStyle.primary()
                          : const ButtonStyle.outline(),

                      shape: ButtonShape.circle,

                      icon: Icon(iconList[i]),
                    ),
                ],
              ).gap(20).withPadding(left: 10, right: 10),
              Row(
                children: <Widget>[
                  for (int i = 6; i < 12; i++)
                    IconButton(
                      onPressed: () {
                        context
                            .read<CategoryCubit>()
                            .changeSelectedCategory(i);
                      },
                      variance: index == i
                          ? const ButtonStyle.primary()
                          : const ButtonStyle.outline(),
                      shape: ButtonShape.circle,
                      icon: Icon(iconList[i]),
                    ),
                ],
              ).gap(20).withPadding(left: 10, right: 10),

              PrimaryButton(
                onPressed: () {
                  final String? categoryOrNull = Form.of(
                    context,
                  ).getValue(_categoryKey);
                  if (categoryOrNull != null) {
                    if (widget.initialCategory != null) {
                      context.read<CategoryCubit>().updateCategory(
                        CategoryEntity(
                          uuid: widget.initialCategory!.uuid,
                          name: categoryOrNull,
                          iconType: index,
                        ),
                      );
                    } else {
                      context.read<CategoryCubit>().saveCategory(
                        CategoryEntity(
                          uuid: const Uuid().v1(),
                          name: categoryOrNull,
                          iconType: index,
                        ),
                      );
                    }
                  }
                },
                trailing: const Icon(Icons.add),
                child: Text(
                  widget.initialCategory != null ? 'Salvar' : 'Add',
                ),
              ),
            ],
          ).gap(20),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (String error) => Center(child: Text(error)),
          success: (CategoryEntity category) => Center(
            child: Text(
              '${category.uuid} ${category.name} ${category.iconType}',
            ),
          ),
          listed: (_) => const SizedBox(),
        ),
      ),
    ),
  );
}

bool isEnabled(int currentIndex, int? enabledIndex, CategoryState state) {
  if (enabledIndex != null) {
    return currentIndex == enabledIndex;
  }
  return false;
}
