import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
    on<HomeEvent>((HomeEvent event, Emitter<HomeState> emit) {
      event.when(
        loadHome: (String userUuid) async {
          await _loadStats(userUuid);
          await _loadLastTransactions(userUuid);
        },
      );
    });
  }

  final FirebaseFirestore _firestore;

  Future<void> _loadStats(String userUuid) async {
    final QuerySnapshot<Map<String, dynamic>> s = await _firestore
        .collection('category')
        .where('uuid', isEqualTo: userUuid)
        .get();

    final List<Map<String, dynamic>> transactions = s.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data())
        .toList();

    for (final Map<String, dynamic> t in transactions) {
      final dynamic month = t['month'];
      final dynamic type = t['type'];
      final double amount = (t['amount'] as num).toDouble();

      logger.d('Month: $month, Type: $type, Amount: $amount');
    }
  }

  Future<void> _loadLastTransactions(String userUuid) async {}
}
