import 'dart:async';

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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

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
    emit(const LimitState.loading());

    final String currentMonth =
        CalendarEntity.values[DateTime.now().month - 1].name;

    final List<QuerySnapshot<Map<String, dynamic>>> staticSnaps =
        await Future.wait(<Future<QuerySnapshot<Map<String, dynamic>>>>[
      _firestore
          .collection('limit')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: currentMonth)
          .get(),
      _firestore.collection('category').get(),
    ]);

    final List<LimitEntity> limits = staticSnaps[0].docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              LimitEntity.fromJson(doc.data()),
        )
        .toList();

    if (limits.isEmpty) {
      emit(const LimitState.loaded(<LimitProgressItem>[]));
      return;
    }

    final Map<String, CategoryEntity> categoryMap = <String, CategoryEntity>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in staticSnaps[1].docs)
        doc.data()['uuid'] as String: CategoryEntity.fromJson(doc.data()),
    };

    final int nowMonth = DateTime.now().month;
    final int nowYear = DateTime.now().year;

    await _subscription?.cancel();
    _subscription = _firestore
        .collection('transaction')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            final Map<String, double> spentByCategory = <String, double>{};

            for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                in snap.docs) {
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

            final List<LimitProgressItem> items = <LimitProgressItem>[
              for (final LimitEntity limit in limits)
                LimitProgressItem(
                  categoryName:
                      categoryMap[limit.categoryUUid]?.name ??
                      limit.categoryUUid,
                  iconType: categoryMap[limit.categoryUUid]?.iconType ?? 0,
                  spent: spentByCategory[limit.categoryUUid] ?? 0.0,
                  limitAmount: limit.limitAmount,
                ),
            ];

            emit(LimitState.loaded(items));
          },
          onError: (Object e) => emit(LimitState.error(e.toString())),
        );
  }

  Future<void> loadLimits(String userId) async {
    emit(const LimitState.loading());

    final QuerySnapshot<Map<String, dynamic>> catsSnap =
        await _firestore.collection('category').get();
    final Map<String, String> catNames = <String, String>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in catsSnap.docs)
        doc.data()['uuid'] as String: doc.data()['name'] as String? ?? '',
    };

    await _subscription?.cancel();
    _subscription = _firestore
        .collection('limit')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            final List<LimitListItem> items = snap.docs
                .map(
                  (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
                    final LimitEntity l = LimitEntity.fromJson(doc.data());
                    return LimitListItem(
                      limit: l,
                      categoryName: catNames[l.categoryUUid] ?? l.categoryUUid,
                    );
                  },
                )
                .toList();
            emit(LimitState.listed(items));
          },
          onError: (Object e) => emit(LimitState.error(e.toString())),
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> deleteLimit(String limitUuid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('limit')
          .where('uuid', isEqualTo: limitUuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
    } on Exception catch (e) {
      emit(LimitState.error(e.toString()));
    }
  }

  Future<void> updateLimit(LimitEntity limit) async {
    try {
      emit(const LimitState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('limit')
          .where('uuid', isEqualTo: limit.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.set(limit.toJson());
      }
      emit(LimitState.success(limit));
    } on Exception catch (e) {
      emit(LimitState.error(e.toString()));
    }
  }
}
