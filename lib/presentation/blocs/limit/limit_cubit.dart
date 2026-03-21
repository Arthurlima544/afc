import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/calendar_entity.dart';
import '../../../domain/entity/category_entity.dart';
import '../../../domain/entity/limit_entity.dart';
import '../../../domain/entity/type_entity.dart';
import '../../../utils/logger.dart';

part 'limit_state.dart';
part 'limit_cubit.freezed.dart';

class LimitCubit extends Cubit<LimitState> {
  LimitCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const LimitState.initial(<CategoryEntity>[]));

  final FirebaseFirestore _firestore;

  Future<void> getCategories() async {
    final QuerySnapshot<Map<String, dynamic>> res =
        await _firestore.collection('category').get();

    final List<CategoryEntity> categories = res.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              CategoryEntity.fromJson(doc.data()),
        )
        .toList();
    emit(LimitState.initial(categories));
  }

  Future<void> saveLimit(LimitEntity limit) async {
    try {
      emit(const LimitState.loading());
      await _firestore
          .collection('limit')
          .add(limit.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                logger.d('DocumentSnapshot added with ID: ${doc.id}'),
          );
      emit(LimitState.success(limit));
    } on Exception catch (e) {
      emit(LimitState.error(e.toString()));
    }
  }

  Future<void> loadLimitsWithProgress(String userId) async {
    try {
      emit(const LimitState.loading());

      final String currentMonth =
          CalendarEntity.values[DateTime.now().month - 1].name;

      // Load limits for this user in the current month
      final QuerySnapshot<Map<String, dynamic>> limitsSnap =
          await _firestore
              .collection('limit')
              .where('userId', isEqualTo: userId)
              .where('month', isEqualTo: currentMonth)
              .get();

      final List<LimitEntity> limits = limitsSnap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                LimitEntity.fromJson(doc.data()),
          )
          .toList();

      if (limits.isEmpty) {
        emit(const LimitState.loaded(<LimitProgressItem>[]));
        return;
      }

      // Load all categories (for names and icons)
      final QuerySnapshot<Map<String, dynamic>> catsSnap =
          await _firestore.collection('category').get();
      final Map<String, CategoryEntity> categoryMap =
          <String, CategoryEntity>{
            for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                in catsSnap.docs)
              doc.data()['uuid'] as String:
                  CategoryEntity.fromJson(doc.data()),
          };

      // Load all transactions for user and compute spending per category
      // for the current month (expense type only)
      final QuerySnapshot<Map<String, dynamic>> txSnap =
          await _firestore
              .collection('transaction')
              .where('userId', isEqualTo: userId)
              .get();

      final int nowMonth = DateTime.now().month;
      final int nowYear = DateTime.now().year;
      final Map<String, double> spentByCategory = <String, double>{};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in txSnap.docs) {
        final Map<String, dynamic> data = doc.data();
        if (data['typeUuid'] != TypeEntity.expense.name) {
          continue;
        }

        final dynamic rawDate = data['data'];
        final DateTime date;
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is DateTime) {
          date = rawDate;
        } else if (rawDate is String) {
          date = DateTime.parse(rawDate);
        } else {
          continue;
        }

        if (date.month != nowMonth || date.year != nowYear) {
          continue;
        }

        final String catId = data['categoryUUid'] as String? ?? '';
        final double amount = (data['amount'] as num).toDouble();
        spentByCategory[catId] = (spentByCategory[catId] ?? 0.0) + amount;
      }

      // Build progress items
      final List<LimitProgressItem> items = <LimitProgressItem>[
        for (final LimitEntity limit in limits)
          LimitProgressItem(
            categoryName:
                categoryMap[limit.categoryUUid]?.name ?? limit.categoryUUid,
            iconType: categoryMap[limit.categoryUUid]?.iconType ?? 0,
            spent: spentByCategory[limit.categoryUUid] ?? 0.0,
            limitAmount: limit.limitAmount,
          ),
      ];

      emit(LimitState.loaded(items));
    } on Exception catch (e) {
      emit(LimitState.error(e.toString()));
    }
  }
}
