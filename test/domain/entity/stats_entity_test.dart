import 'package:afc/domain/entity/calendar_entity.dart';
import 'package:afc/domain/entity/stats_entity.dart';
import 'package:afc/domain/entity/type_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatsEntity', () {
    const StatsEntity tStats = StatsEntity(
      type: TypeEntity.income,
      total: 2500.0,
      date: CalendarEntity.january,
    );

    group('fromJson', () {
      test('creates entity from valid JSON map', () {
        // Arrange
        final Map<String, Object?> json = tStats.toJson();

        // Act
        final StatsEntity result = StatsEntity.fromJson(json);

        // Assert
        expect(result.type, TypeEntity.income);
        expect(result.total, 2500.0);
        expect(result.date, CalendarEntity.january);
      });
    });

    group('toJson', () {
      test('roundtrip fromJson(toJson()) preserves all fields', () {
        // Arrange
        final Map<String, Object?> json = tStats.toJson();

        // Act
        final StatsEntity result = StatsEntity.fromJson(json);

        // Assert
        expect(result, tStats);
      });

      test('serializes TypeEntity enum correctly', () {
        // Arrange — tStats

        // Act
        final Map<String, Object?> json = tStats.toJson();

        // Assert
        expect(json['type'], isNotNull);
      });
    });

    group('equality', () {
      test('two entities with same fields are equal', () {
        // Arrange
        const StatsEntity a = StatsEntity(
          type: TypeEntity.expense,
          total: 300.0,
          date: CalendarEntity.march,
        );
        const StatsEntity b = StatsEntity(
          type: TypeEntity.expense,
          total: 300.0,
          date: CalendarEntity.march,
        );

        // Act & Assert
        expect(a, equals(b));
      });

      test('entities with different type are not equal', () {
        // Arrange
        const StatsEntity expense = StatsEntity(
          type: TypeEntity.expense,
          total: 100.0,
          date: CalendarEntity.june,
        );
        const StatsEntity income = StatsEntity(
          type: TypeEntity.income,
          total: 100.0,
          date: CalendarEntity.june,
        );

        // Act & Assert
        expect(expense, isNot(equals(income)));
      });
    });
  });

  group('CalendarEntity', () {
    test('has 12 months', () {
      // Arrange & Act
      const List<CalendarEntity> months = CalendarEntity.values;

      // Assert
      expect(months.length, 12);
    });

    test('january is the first month', () {
      // Arrange & Act & Assert
      expect(CalendarEntity.values.first, CalendarEntity.january);
    });

    test('december is the last month', () {
      // Arrange & Act & Assert
      expect(CalendarEntity.values.last, CalendarEntity.december);
    });
  });

  group('TypeEntity', () {
    test('has income and expense variants', () {
      // Arrange & Act
      const List<TypeEntity> types = TypeEntity.values;

      // Assert
      expect(types, containsAll(<TypeEntity>[TypeEntity.income, TypeEntity.expense]));
    });
  });
}
