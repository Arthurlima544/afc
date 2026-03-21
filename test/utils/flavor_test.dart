import 'package:afc/utils/flavors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flavor', () {
    group('isDevelopment / isProduction', () {
      test('isDevelopment returns true and isProduction returns false for dev',
          () {
        // Arrange
        Flavor.flavorType = FlavorTypes.dev;

        // Act & Assert
        expect(Flavor.isDevelopment(), isTrue);
        expect(Flavor.isProduction(), isFalse);
      });

      test('isProduction returns true and isDevelopment returns false for prod',
          () {
        // Arrange
        Flavor.flavorType = FlavorTypes.prod;

        // Act & Assert
        expect(Flavor.isProduction(), isTrue);
        expect(Flavor.isDevelopment(), isFalse);
      });
    });

    group('flavorMessage', () {
      test('returns "Dev" for dev flavor', () {
        // Arrange
        Flavor.flavorType = FlavorTypes.dev;

        // Act
        final String message = Flavor.flavorMessage;

        // Assert
        expect(message, 'Dev');
      });

      test('returns "Production" for prod flavor', () {
        // Arrange
        Flavor.flavorType = FlavorTypes.prod;

        // Act
        final String message = Flavor.flavorMessage;

        // Assert
        expect(message, 'Production');
      });
    });

    group('apiBaseUrl', () {
      test('returns dev URL for dev flavor', () {
        // Arrange
        Flavor.flavorType = FlavorTypes.dev;

        // Act
        final String url = Flavor.apiBaseUrl;

        // Assert
        expect(url, 'apiUrlBaseDev');
      });

      test('returns prod URL for prod flavor', () {
        // Arrange
        Flavor.flavorType = FlavorTypes.prod;

        // Act
        final String url = Flavor.apiBaseUrl;

        // Assert
        expect(url, 'apiUrlBaseProd');
      });
    });
  });
}
