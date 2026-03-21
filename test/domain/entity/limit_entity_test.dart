import 'package:afc/domain/entity/limit_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LimitEntity', () {
    const LimitEntity tLimit = LimitEntity(
      uuid: 'limit-1',
      categoryUUid: 'cat-1',
      month: 'january',
      limitAmount: 500.0,
      userId: 'user-1',
    );

    group('fromJson', () {
      test('creates entity from valid JSON map', () {
        // Arrange
        final Map<String, Object?> json = tLimit.toJson();

        // Act
        final LimitEntity result = LimitEntity.fromJson(json);

        // Assert
        expect(result.uuid, 'limit-1');
        expect(result.categoryUUid, 'cat-1');
        expect(result.month, 'january');
        expect(result.limitAmount, 500.0);
        expect(result.userId, 'user-1');
      });
    });

    group('toJson', () {
      test('serializes all fields to JSON map', () {
        // Arrange — tLimit

        // Act
        final Map<String, Object?> json = tLimit.toJson();

        // Assert
        expect(json['uuid'], 'limit-1');
        expect(json['categoryUUid'], 'cat-1');
        expect(json['month'], 'january');
        expect(json['limitAmount'], 500.0);
        expect(json['userId'], 'user-1');
      });

      test('roundtrip fromJson(toJson()) preserves all fields', () {
        // Arrange
        final Map<String, Object?> json = tLimit.toJson();

        // Act
        final LimitEntity result = LimitEntity.fromJson(json);

        // Assert
        expect(result, tLimit);
      });
    });

    group('equality', () {
      test('two entities with same fields are equal', () {
        // Arrange
        const LimitEntity a = LimitEntity(
          uuid: 'l-1',
          categoryUUid: 'c-1',
          month: 'march',
          limitAmount: 300.0,
          userId: 'u-1',
        );
        const LimitEntity b = LimitEntity(
          uuid: 'l-1',
          categoryUUid: 'c-1',
          month: 'march',
          limitAmount: 300.0,
          userId: 'u-1',
        );

        // Act & Assert
        expect(a, equals(b));
      });

      test('entities with different limitAmount are not equal', () {
        // Arrange
        const LimitEntity a = tLimit;
        final LimitEntity b = tLimit.copyWith(limitAmount: 1000.0);

        // Act & Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copyWith updates only the specified field', () {
        // Arrange — tLimit

        // Act
        final LimitEntity updated = tLimit.copyWith(limitAmount: 750.0);

        // Assert
        expect(updated.limitAmount, 750.0);
        expect(updated.uuid, tLimit.uuid);
        expect(updated.month, tLimit.month);
        expect(updated.userId, tLimit.userId);
      });
    });
  });
}
