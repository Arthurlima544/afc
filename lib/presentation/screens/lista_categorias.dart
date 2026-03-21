import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;

import '../../domain/entity/category_entity.dart';
import '../blocs/category/category_cubit.dart';

class ListaCategorias extends StatelessWidget {
  const ListaCategorias({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                variance: const ButtonStyle.outline(),
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const Gap(8),
              const Expanded(
                child: Text(
                  'Categorias',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                variance: const ButtonStyle.outline(),
                onPressed: () => context.push('/cadastro-categoria'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Gap(16),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (BuildContext context, CategoryState state) =>
                state.when(
                  initial: (_) => const SizedBox(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: Text.new,
                  success: (_) => const SizedBox(),
                  listed: (List<CategoryEntity> cats) => cats.isEmpty
                      ? const Center(child: Text('Sem categorias'))
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
  );
}

class _CategoriaItem extends StatelessWidget {
  const _CategoriaItem({required this.cat});

  final CategoryEntity cat;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          IconButton(
            variance: const ButtonStyle.primary(),
            enabled: true,
            shape: ButtonShape.circle,
            icon: Icon(
              _iconFromType(cat.iconType),
              size: 24,
              color: Colors.white,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              cat.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            variance: const ButtonStyle.outline(),
            onPressed: () =>
                context.push('/editar-categoria', extra: cat),
            icon: const Icon(Icons.edit, size: 18),
          ),
          IconButton(
            variance: const ButtonStyle.outline(),
            onPressed: () =>
                context.read<CategoryCubit>().deleteCategory(cat.uuid),
            icon: const Icon(Icons.delete, size: 18),
          ),
        ],
      ),
    ),
  );
}

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
