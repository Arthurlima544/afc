import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entity/category_entity.dart';
import '../blocs/category/category_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';
import 'cadastrar_categoria.dart';

class ListaCategorias extends StatelessWidget {
  const ListaCategorias({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => context.read<CategoryCubit>().loadCategories(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  AppIconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Gap(8),
                  const Expanded(
                    child: Text('Categorias', style: AppTextStyles.heading),
                  ),
                  AppIconButton(
                    onPressed: () => context.push('/cadastro-categoria'),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            const Gap(16),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (BuildContext context, CategoryState state) => state.when(
                initial: (_) => const SizedBox(),
                loading: () => const SkeletonList(),
                error: (String msg) => ErrorState(
                  message: msg,
                  onRetry: () => context.read<CategoryCubit>().loadCategories(),
                ),
                success: (_) => const SizedBox(),
                listed: (List<CategoryEntity> cats) => cats.isEmpty
                    ? const EmptyState(
                        message:
                            'Nenhuma categoria ainda.\nToque em + para criar.',
                        icon: Icons.category_outlined,
                      )
                    : Column(
                        children: <Widget>[
                          for (final CategoryEntity cat in cats)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CategoriaItem(cat: cat),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

class _CategoriaItem extends StatelessWidget {
  const _CategoriaItem({required this.cat});

  final CategoryEntity cat;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: <Widget>[
        AppIconButton.circle(
          icon: Icon(
            _iconFromType(cat.iconType),
            size: 24,
            color: AppColors.onPrimary,
          ),
        ),
        const Gap(12),
        Expanded(child: Text(cat.name, style: AppTextStyles.title)),
        PopupMenuButton<_CatAction>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (_CatAction action) {
            if (action == _CatAction.edit) {
              showFormSheet<void>(
                context,
                builder: (BuildContext ctx) => BlocProvider<CategoryCubit>(
                  create: (_) => CategoryCubit(),
                  child: CadastrarCategoria(initialCategory: cat),
                ),
              );
            } else {
              context.read<CategoryCubit>().deleteCategory(cat.uuid);
            }
          },
          itemBuilder: (_) => const <PopupMenuEntry<_CatAction>>[
            PopupMenuItem<_CatAction>(
              value: _CatAction.edit,
              child: Text('Editar'),
            ),
            PopupMenuItem<_CatAction>(
              value: _CatAction.delete,
              child: Text('Excluir'),
            ),
          ],
        ),
      ],
    ),
  );
}

enum _CatAction { edit, delete }

const List<IconData> _categoryIcons = <IconData>[
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

IconData _iconFromType(int iconType) =>
    (iconType >= 0 && iconType < _categoryIcons.length)
    ? _categoryIcons[iconType]
    : Icons.category;
