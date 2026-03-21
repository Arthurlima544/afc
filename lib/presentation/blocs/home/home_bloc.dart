import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/calendar_entity.dart';
import '../../../domain/entity/stats_entity.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../../domain/entity/type_entity.dart';
import '../../../utils/logger.dart';
import 'stats_state.dart';
import 'transaction_state.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(HomeState.initial()) {
    on<HomeEvent>((HomeEvent event, Emitter<HomeState> emit) async {
      await event.when(
        loadHome: (String userUuid) async {
          await _loadStats(userUuid, emit);
          await _loadLastTransactions(userUuid, emit);
        },
      );
    });
  }

  final FirebaseFirestore _firestore;

  Future<void> _loadStats(
    String userUuid,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(state.copyWith(statsState: const StatsState.loading()));

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('transaction')
              .where('userId', isEqualTo: userUuid)
              .get();

      // Group amounts by (typeUuid, month)
      final Map<String, Map<CalendarEntity, double>> grouped =
          <String, Map<CalendarEntity, double>>{};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final String typeUuid = data['typeUuid'] as String? ?? '';
        final double amount = (data['amount'] as num).toDouble();

        final dynamic rawDate = data['data'];
        final DateTime date;
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is DateTime) {
          date = rawDate;
        } else if (rawDate is String) {
          date = DateTime.parse(rawDate);
        } else {
          date = DateTime.now();
        }

        final CalendarEntity month = CalendarEntity.values[date.month - 1];
        grouped[typeUuid] ??= <CalendarEntity, double>{};
        grouped[typeUuid]![month] =
            (grouped[typeUuid]![month] ?? 0.0) + amount;
      }

      final List<StatsEntity> stats = <StatsEntity>[];
      for (final MapEntry<String, Map<CalendarEntity, double>> typeEntry
          in grouped.entries) {
        final TypeEntity? typeOrNull = TypeEntity.values.where(
          (TypeEntity t) => t.name == typeEntry.key,
        ).firstOrNull;
        if (typeOrNull == null) {
          logger.d('Unknown typeUuid: ${typeEntry.key}');
          continue;
        }
        final TypeEntity type = typeOrNull;
        for (final MapEntry<CalendarEntity, double> monthEntry
            in typeEntry.value.entries) {
          stats.add(
            StatsEntity(
              type: type,
              total: monthEntry.value,
              date: monthEntry.key,
            ),
          );
        }
      }

      emit(state.copyWith(statsState: StatsState.success(stats)));
    } on Exception catch (e) {
      emit(state.copyWith(statsState: StatsState.error(e.toString())));
    }
  }

  Future<void> _loadLastTransactions(
    String userUuid,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(
        state.copyWith(transactionState: const LastTransactionState.loading()),
      );

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('transaction')
              .where('userId', isEqualTo: userUuid)
              .get();

      final List<TransactionEntity> transactions = snapshot.docs.map(
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(doc.data());
          final dynamic rawDate = data['data'];
          if (rawDate is Timestamp) {
            data['data'] = rawDate.toDate().toIso8601String();
          } else if (rawDate is DateTime) {
            data['data'] = rawDate.toIso8601String();
          }
          return TransactionEntity.fromJson(data);
        },
      ).toList()
        ..sort(
          (TransactionEntity a, TransactionEntity b) =>
              b.data.compareTo(a.data),
        );

      emit(
        state.copyWith(
          transactionState: LastTransactionState.success(
            transactions.take(5).toList(),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          transactionState: LastTransactionState.error(e.toString()),
        ),
      );
    }
  }
}
