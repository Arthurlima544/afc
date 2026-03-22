import 'dart:io';

import 'package:afc/domain/usecase/receipt_ocr_service.dart';
import 'package:afc/presentation/blocs/receipt_ocr/receipt_ocr_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockReceiptOcrService extends Mock implements ReceiptOcrService {}

class FakeXFile extends Fake implements XFile {
  FakeXFile(this.path);

  @override
  final String path;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

XFile _fakeImage() {
  // Create a real temp file so the cubit can pass it to the service
  final File tmp = File('${Directory.systemTemp.path}/test_receipt.jpg')
    ..createSync()
    ..writeAsBytesSync(<int>[0xFF, 0xD8, 0xFF]); // minimal JPEG header
  return XFile(tmp.path);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockReceiptOcrService mockService;

  setUpAll(() => registerFallbackValue(FakeXFile('fallback.jpg')));

  setUp(() => mockService = MockReceiptOcrService());

  test('initial state is ReceiptOcrState.idle()', () {
    final ReceiptOcrCubit cubit = ReceiptOcrCubit(service: mockService);
    expect(cubit.state, const ReceiptOcrState.idle());
    cubit.close();
  });

  group('scan', () {
    blocTest<ReceiptOcrCubit, ReceiptOcrState>(
      'emits [loading, success] when service returns amount and merchant',
      setUp: () {
        when(() => mockService.scan(any())).thenAnswer(
          (_) async => const OcrResult(amount: 49.90, merchant: 'Mercado Extra'),
        );
      },
      build: () => ReceiptOcrCubit(service: mockService),
      act: (ReceiptOcrCubit cubit) => cubit.scan(_fakeImage()),
      expect: () => <ReceiptOcrState>[
        const ReceiptOcrState.loading(),
        const ReceiptOcrState.success(
          amount: 49.90,
          merchant: 'Mercado Extra',
        ),
      ],
    );

    blocTest<ReceiptOcrCubit, ReceiptOcrState>(
      'emits [loading, success] with nulls when service cannot extract data',
      setUp: () {
        when(() => mockService.scan(any())).thenAnswer(
          (_) async => const OcrResult(),
        );
      },
      build: () => ReceiptOcrCubit(service: mockService),
      act: (ReceiptOcrCubit cubit) => cubit.scan(_fakeImage()),
      expect: () => <ReceiptOcrState>[
        const ReceiptOcrState.loading(),
        const ReceiptOcrState.success(amount: null, merchant: null),
      ],
    );

    blocTest<ReceiptOcrCubit, ReceiptOcrState>(
      'emits [loading, error] when service throws',
      setUp: () {
        when(() => mockService.scan(any()))
            .thenThrow(Exception('network error'));
      },
      build: () => ReceiptOcrCubit(service: mockService),
      act: (ReceiptOcrCubit cubit) => cubit.scan(_fakeImage()),
      verify: (ReceiptOcrCubit cubit) {
        expect(
          cubit.state.whenOrNull(error: (String m) => m),
          contains('network error'),
        );
      },
    );
  });

  group('reset', () {
    blocTest<ReceiptOcrCubit, ReceiptOcrState>(
      'reset emits idle from any state',
      setUp: () {
        when(() => mockService.scan(any())).thenAnswer(
          (_) async => const OcrResult(amount: 10.0, merchant: 'Test'),
        );
      },
      build: () => ReceiptOcrCubit(service: mockService),
      act: (ReceiptOcrCubit cubit) async {
        await cubit.scan(_fakeImage());
        cubit.reset();
      },
      expect: () => <ReceiptOcrState>[
        const ReceiptOcrState.loading(),
        const ReceiptOcrState.success(amount: 10.0, merchant: 'Test'),
        const ReceiptOcrState.idle(),
      ],
    );
  });
}
