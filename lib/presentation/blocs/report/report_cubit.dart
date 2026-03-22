import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/transaction_entity.dart';

part 'report_state.dart';
part 'report_cubit.freezed.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const ReportState.initial());

  final FirebaseFirestore _firestore;

  Future<void> loadReport(String userId, int year, int month) async {
    emit(const ReportState.loading());
    try {
      // Fetch all transactions for this user
      final QuerySnapshot<Map<String, dynamic>> txSnap = await _firestore
          .collection('transaction')
          .where('userId', isEqualTo: userId)
          .get();

      final List<TransactionEntity> allTxs = txSnap.docs.map(
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
          final dynamic rawDate = data['data'];
          if (rawDate is Timestamp) {
            data['data'] = rawDate.toDate().toIso8601String();
          }
          return TransactionEntity.fromJson(data);
        },
      ).toList();

      // Fetch categories for names
      final QuerySnapshot<Map<String, dynamic>> catSnap =
          await _firestore.collection('category').get();
      final Map<String, String> categoryNames = <String, String>{
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in catSnap.docs)
          (doc.data()['uuid'] as String? ?? ''): (doc.data()['name'] as String? ?? ''),
      };

      // Previous month
      final int prevYear = month == 1 ? year - 1 : year;
      final int prevMonth = month == 1 ? 12 : month - 1;

      // Compute report for selected month
      final List<TransactionEntity> monthTxs = allTxs
          .where((TransactionEntity tx) =>
              tx.data.year == year && tx.data.month == month)
          .toList();

      final List<TransactionEntity> prevTxs = allTxs
          .where((TransactionEntity tx) =>
              tx.data.year == prevYear && tx.data.month == prevMonth)
          .toList();

      emit(
        ReportState.success(
          ReportData(
            year: year,
            month: month,
            totalIncome: _sumByType(monthTxs, 'income'),
            totalExpenses: _sumByType(monthTxs, 'expense'),
            expensesByCategory: _groupByCategory(
              monthTxs.where((TransactionEntity tx) => tx.typeUuid == 'expense').toList(),
            ),
            categoryNames: categoryNames,
            prevMonthIncome: _sumByType(prevTxs, 'income'),
            prevMonthExpenses: _sumByType(prevTxs, 'expense'),
            prevExpensesByCategory: _groupByCategory(
              prevTxs.where((TransactionEntity tx) => tx.typeUuid == 'expense').toList(),
            ),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(ReportState.error(e.toString()));
    }
  }

  double _sumByType(List<TransactionEntity> txs, String type) =>
      txs
          .where((TransactionEntity tx) => tx.typeUuid == type)
          .fold(0.0, (double acc, TransactionEntity tx) => acc + tx.amount);

  Map<String, double> _groupByCategory(List<TransactionEntity> txs) {
    final Map<String, double> result = <String, double>{};
    for (final TransactionEntity tx in txs) {
      result[tx.categoryUUid] = (result[tx.categoryUUid] ?? 0.0) + tx.amount;
    }
    return result;
  }
}
