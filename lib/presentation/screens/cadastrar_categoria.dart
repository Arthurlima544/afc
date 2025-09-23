import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../blocs/cubit/category_cubit.dart';

List<IconData> iconList = <IconData>[
  Icons.share_outlined,
  Icons.play_arrow_rounded,
  Icons.local_taxi,
  Icons.star_border,
  Icons.camera_alt_outlined,
  Icons.calendar_month,
  Icons.file_upload_outlined,
  Icons.star_border,
  Icons.savings,
  Icons.access_time_rounded,
  Icons.heart_broken,
  Icons.compare_arrows_rounded,
];

class CadastrarCategoria extends StatefulWidget {
  const CadastrarCategoria({super.key});

  @override
  State<CadastrarCategoria> createState() => _CadastrarCategoriaState();
}

class _CadastrarCategoriaState extends State<CadastrarCategoria> {
  final FormKey<String> _categoryKey = const TextFieldKey('category');

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 480,
    child: Form(
      child: BlocBuilder<CategoryCubit, int>(
        builder: (BuildContext context, int state) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FormTableLayout(
              rows: <FormField<String>>[
                FormField<String>(
                  key: _categoryKey,
                  label: const Text('Categoria'),
                  child: const TextField(hintText: 'Adicione uma Categoria'),
                ),
              ],
            ).withPadding(top: 40, left: 20, right: 20, bottom: 20),
            const Text('Selecione um ícone'),
            Row(
              children: <Widget>[
                for (int i = 0; i < 6; i++)
                  IconButton(
                    onPressed: () {
                      print('Sou gay');
                      context.read<CategoryCubit>().changeSelectedCategory(i);
                    },
                    variance: state == i
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
                      context.read<CategoryCubit>().changeSelectedCategory(i);
                    },
                    variance: state == i
                        ? const ButtonStyle.primary()
                        : const ButtonStyle.outline(),
                    shape: ButtonShape.circle,
                    icon: Icon(iconList[i]),
                  ),
              ],
            ).gap(20).withPadding(left: 10, right: 10),
          ],
        ).gap(20),
      ),
    ),
  );
}

bool isEnabled(int currentIndex, int? enabledIndex) {
  if (enabledIndex != null) {
    return currentIndex == enabledIndex;
  }
  return false;
}
