import 'package:afc/domain/entity/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryEntity', () {
    const CategoryEntity tCategory = CategoryEntity(
      uuid: 'user-123',
      name: 'Food',
      iconType: 1,
    );

    const Map<String, Object> tCategoryJson = <String, Object>{
      'uuid': 'user-123',
      'name': 'Food',
      'iconType': 1,
    };

    group('fromJson', () {
      test('creates entity from valid JSON map', () {
        // Arrange
        final Map<String, Object?> json = Map<String, Object?>.from(tCategoryJson);

        // Act
        final CategoryEntity result = CategoryEntity.fromJson(json);

        // Assert
        expect(result.uuid, 'user-123');
        expect(result.name, 'Food');
        expect(result.iconType, 1);
      });
    });

    group('toJson', () {
      test('serializes entity to JSON map', () {
        // Arrange — tCategory defined above

        // Act
        final Map<String, Object?> result = tCategory.toJson();

        // Assert
        expect(result['uuid'], 'user-123');
        expect(result['name'], 'Food');
        expect(result['iconType'], 1);
      });

      test('roundtrip fromJson(toJson()) preserves all fields', () {
        // Arrange
        final Map<String, Object?> json = tCategory.toJson();

        // Act
        final CategoryEntity result = CategoryEntity.fromJson(json);

        // Assert
        expect(result, tCategory);
      });
    });

    group('equality', () {
      test('two entities with same fields are equal', () {
        // Arrange
        const CategoryEntity a = CategoryEntity(uuid: 'u', name: 'N', iconType: 2);
        const CategoryEntity b = CategoryEntity(uuid: 'u', name: 'N', iconType: 2);

        // Act & Assert
        expect(a, equals(b));
      });

      test('entities with different fields are not equal', () {
        // Arrange
        const CategoryEntity a = CategoryEntity(uuid: 'u1', name: 'Food', iconType: 1);
        const CategoryEntity b = CategoryEntity(uuid: 'u2', name: 'Food', iconType: 1);

        // Act & Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copyWith updates only specified fields', () {
        // Arrange — tCategory

        // Act
        final CategoryEntity updated = tCategory.copyWith(name: 'Transport');

        // Assert
        expect(updated.name, 'Transport');
        expect(updated.uuid, tCategory.uuid);
        expect(updated.iconType, tCategory.iconType);
      });
    });
  });
}
