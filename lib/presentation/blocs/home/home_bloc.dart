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
        loadHome: (String userUuid) => _subscribeToTransactions(userUuid, emit),
      );
    });
  }

  final FirebaseFirestore _firestore;

  Future<void> _subscribeToTransactions(
    String userUuid,
    Emitter<HomeState> emit,
  ) async {
    emit(
      HomeState.initial().copyWith(
        statsState: const StatsState.loading(),
        transactionState: const LastTransactionState.loading(),
      ),
    );

    await emit.forEach<QuerySnapshot<Map<String, dynamic>>>(
      _firestore
          .collection('transaction')
          .where('userId', isEqualTo: userUuid)
          .snapshots(),
      onData: (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final List<TransactionEntity> allTxs = _parseDocs(snapshot.docs);
        final List<TransactionEntity> sorted = allTxs
          ..sort(
            (TransactionEntity a, TransactionEntity b) =>
                b.data.compareTo(a.data),
          );
        return state.copyWith(
          statsState: StatsState.success(_computeStats(allTxs)),
          transactionState:
              LastTransactionState.success(sorted.take(5).toList()),
        );
      },
      onError: (Object error, StackTrace _) {
        logger.e('HomeBloc stream error: $error');
        return state.copyWith(
          statsState: StatsState.error(error.toString()),
          transactionState: LastTransactionState.error(error.toString()),
        );
      },
    );
  }

  List<TransactionEntity> _parseDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) =>
      docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
        final dynamic rawDate = data['data'];
        if (rawDate is Timestamp) {
          data['data'] = rawDate.toDate().toIso8601String();
        } else if (rawDate is DateTime) {
          data['data'] = rawDate.toIso8601String();
        }
        return TransactionEntity.fromJson(data);
      }).toList();

  List<StatsEntity> _computeStats(List<TransactionEntity> txs) {
    final Map<String, Map<CalendarEntity, double>> grouped =
        <String, Map<CalendarEntity, double>>{};

    for (final TransactionEntity tx in txs) {
      final CalendarEntity month = CalendarEntity.values[tx.data.month - 1];
      grouped[tx.typeUuid] ??= <CalendarEntity, double>{};
      grouped[tx.typeUuid]![month] =
          (grouped[tx.typeUuid]![month] ?? 0.0) + tx.amount;
    }

    final List<StatsEntity> stats = <StatsEntity>[];
    for (final MapEntry<String, Map<CalendarEntity, double>> typeEntry
        in grouped.entries) {
      final TypeEntity? type = TypeEntity.values
          .where((TypeEntity t) => t.name == typeEntry.key)
          .firstOrNull;
      if (type == null) {
        logger.d('HomeBloc — unknown typeUuid: ${typeEntry.key}');
        continue;
      }
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
    return stats;
  }
}
