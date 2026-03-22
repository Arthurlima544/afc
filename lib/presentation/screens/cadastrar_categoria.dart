import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/category_entity.dart';
import '../blocs/category/category_cubit.dart';
import '../widgets/design_system.dart';

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
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _nameController.text = widget.initialCategory!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
    body: SafeArea(
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (BuildContext context, CategoryState state) => state.when(
          initial: (int index) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.initialCategory != null
                    ? 'Editar Categoria'
                    : 'Nova Categoria',
                style: AppTextStyles.heading,
              ),
              const Gap(24),

              AppTextField(
                controller: _nameController,
                hintText: 'Nome da categoria',
                onChanged: (_) => setState(() => _nameError = null),
              ),
              if (_nameError != null) ...<Widget>[
                const Gap(4),
                Text(
                  _nameError!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.expense,
                  ),
                ),
              ],
              const Gap(20),

              const Text('Selecione um ícone', style: AppTextStyles.labelBold),
              const Gap(12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (int i = 0; i < iconList.length; i++)
                    index == i
                        ? AppIconButton.circle(
                            onPressed: () => context
                                .read<CategoryCubit>()
                                .changeSelectedCategory(i),
                            icon: Icon(iconList[i], color: AppColors.onPrimary),
                          )
                        : AppIconButton(
                            onPressed: () => context
                                .read<CategoryCubit>()
                                .changeSelectedCategory(i),
                            icon: Icon(iconList[i]),
                          ),
                ],
              ),
              const Gap(24),

              PrimaryButton(
                onPressed: () {
                  final String name = _nameController.text.trim();
                  if (name.isEmpty) {
                    setState(() => _nameError = 'Informe o nome da categoria');
                    return;
                  }
                  if (widget.initialCategory != null) {
                    context.read<CategoryCubit>().updateCategory(
                      CategoryEntity(
                        uuid: widget.initialCategory!.uuid,
                        name: name,
                        iconType: index,
                      ),
                    );
                  } else {
                    context.read<CategoryCubit>().saveCategory(
                      CategoryEntity(
                        uuid: const Uuid().v1(),
                        name: name,
                        iconType: index,
                      ),
                    );
                  }
                },
                child: Text(
                  widget.initialCategory != null ? 'Salvar' : 'Adicionar',
                ),
              ),
            ],
          ),
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
  ),
  );
}
