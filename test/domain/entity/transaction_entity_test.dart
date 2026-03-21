import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionEntity', () {
    final DateTime tDate = DateTime(2024, 1, 15, 10, 30);

    final TransactionEntity tTransaction = TransactionEntity(
      uuid: 'tx-1',
      amount: 150.50,
      categoryUUid: 'cat-1',
      typeUuid: 'income',
      data: tDate,
      title: 'Salary',
      userId: 'user-1',
    );

    group('fromJson', () {
      test('creates entity from valid JSON map', () {
        // Arrange
        final Map<String, Object?> json = tTransaction.toJson();

        // Act
        final TransactionEntity result = TransactionEntity.fromJson(json);

        // Assert
        expect(result.uuid, 'tx-1');
        expect(result.amount, 150.50);
        expect(result.categoryUUid, 'cat-1');
        expect(result.typeUuid, 'income');
        expect(result.title, 'Salary');
        expect(result.userId, 'user-1');
      });
    });

    group('toJson', () {
      test('serializes all fields to JSON map', () {
        // Arrange — tTransaction

        // Act
        final Map<String, Object?> json = tTransaction.toJson();

        // Assert
        expect(json['uuid'], 'tx-1');
        expect(json['amount'], 150.50);
        expect(json['categoryUUid'], 'cat-1');
        expect(json['typeUuid'], 'income');
        expect(json['title'], 'Salary');
        expect(json['userId'], 'user-1');
        expect(json.containsKey('data'), isTrue);
      });

      test('roundtrip fromJson(toJson()) preserves all fields', () {
        // Arrange
        final Map<String, Object?> json = tTransaction.toJson();

        // Act
        final TransactionEntity result = TransactionEntity.fromJson(json);

        // Assert
        expect(result, tTransaction);
      });
    });

    group('equality', () {
      test('two entities with same fields are equal', () {
        // Arrange
        final TransactionEntity a = TransactionEntity(
          uuid: 'tx-1',
          amount: 100.0,
          categoryUUid: 'cat-1',
          typeUuid: 'expense',
          data: tDate,
          title: 'Rent',
          userId: 'user-1',
        );
        final TransactionEntity b = TransactionEntity(
          uuid: 'tx-1',
          amount: 100.0,
          categoryUUid: 'cat-1',
          typeUuid: 'expense',
          data: tDate,
          title: 'Rent',
          userId: 'user-1',
        );

        // Act & Assert
        expect(a, equals(b));
      });

      test('entities with different amount are not equal', () {
        // Arrange
        final TransactionEntity a = tTransaction;
        final TransactionEntity b = tTransaction.copyWith(amount: 200.0);

        // Act & Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copyWith updates only the specified field', () {
        // Arrange — tTransaction

        // Act
        final TransactionEntity updated = tTransaction.copyWith(title: 'Bonus');

        // Assert
        expect(updated.title, 'Bonus');
        expect(updated.uuid, tTransaction.uuid);
        expect(updated.amount, tTransaction.amount);
        expect(updated.userId, tTransaction.userId);
      });
    });
  });
}
