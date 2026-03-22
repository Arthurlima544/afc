import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/category_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/review_queue/review_queue_cubit.dart';
import '../widgets/design_system.dart';

class ReviewQueueScreen extends StatelessWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';

    return SafeArea(
      child: SingleChildScrollView(
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
                  child: Text(
                    'Revisar Transações Importadas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            BlocBuilder<ReviewQueueCubit, ReviewQueueState>(
              builder: (BuildContext context, ReviewQueueState state) =>
                  state.when(
                    initial: SizedBox.new,
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: Text.new,
                    listed: (List<ReviewItem> items) => items.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Nenhuma transação pendente de revisão.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Column(
                            children: <Widget>[
                              for (final ReviewItem item in items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ReviewItemCard(
                                    item: item,
                                    userId: userId,
                                  ),
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
}

class _ReviewItemCard extends StatelessWidget {
  const _ReviewItemCard({
    required this.item,
    required this.userId,
  });

  final ReviewItem item;
  final String userId;

  void _showCategoryPicker(BuildContext context) {
    final ReviewQueueCubit cubit = context.read<ReviewQueueCubit>();
    final List<CategoryEntity> categories = cubit.categories;

    showAppDialog<void>(
      context: context,
      builder: (BuildContext dialogCtx) => AppAlertDialog(
        title: const Text('Selecionar Categoria'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: categories
                .map(
                  (CategoryEntity cat) => GestureDetector(
                    onTap: () {
                      cubit.updateItemCategory(
                        item.rawTransaction.uuid,
                        cat.uuid,
                        cat.name,
                      );
                      Navigator.of(dialogCtx).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        cat.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: const <Widget>[],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDebit = item.rawTransaction.type == 'debit';
    final Color amountColor = isDebit
        ? const Color(0xFFEF4444)
        : const Color(0xFF22C55E);
    final String amountText =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(
          isDebit
              ? -item.rawTransaction.amount
              : item.rawTransaction.amount,
        );

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.rawTransaction.description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(4),
            Row(
              children: <Widget>[
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 14,
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Text(
                  DateFormat('dd/MM/yyyy').format(
                    item.rawTransaction.date,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const Gap(8),
            GestureDetector(
              onTap: () => _showCategoryPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.selectedCategoryName ?? 'Selecionar categoria',
                  style: TextStyle(
                    fontSize: 13,
                    color: item.selectedCategoryName != null
                        ? null
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Row(
              children: <Widget>[
                PrimaryButton(
                  onPressed: () =>
                      context.read<ReviewQueueCubit>().confirmTransaction(
                        item,
                        userId,
                      ),
                  child: const Text('Confirmar'),
                ),
                const Gap(8),
                DestructiveButton(
                  onPressed: () =>
                      context.read<ReviewQueueCubit>().ignoreTransaction(
                        item.rawTransaction.uuid,
                      ),
                  child: const Text('Ignorar'),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
