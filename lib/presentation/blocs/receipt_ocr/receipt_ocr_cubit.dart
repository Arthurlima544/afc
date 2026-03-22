import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/usecase/gemini_receipt_ocr_service.dart';
import '../../../domain/usecase/receipt_ocr_service.dart';
import '../../../utils/logger.dart';

part 'receipt_ocr_state.dart';
part 'receipt_ocr_cubit.freezed.dart';

class ReceiptOcrCubit extends Cubit<ReceiptOcrState> {
  ReceiptOcrCubit({ReceiptOcrService? service})
    : _service = service ?? GeminiReceiptOcrService(),
      super(const ReceiptOcrState.idle());

  final ReceiptOcrService _service;
  final ImagePicker _picker = ImagePicker();

  /// Opens camera or gallery, then runs OCR on the selected image.
  Future<void> pickAndScan({bool fromCamera = true}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );

    if (image == null) {
      return; // user cancelled
    }

    await _scan(image);
  }

  /// Scans an already-picked image (used in tests).
  Future<void> scan(XFile image) => _scan(image);

  Future<void> _scan(XFile image) async {
    emit(const ReceiptOcrState.loading());
    try {
      final OcrResult result = await _service.scan(image);
      logger.d('OCR success — amount: ${result.amount}, merchant: ${result.merchant}');
      emit(ReceiptOcrState.success(
        amount: result.amount,
        merchant: result.merchant,
      ));
    } on Exception catch (e) {
      logger.e('OCR failed: $e');
      emit(ReceiptOcrState.error(e.toString()));
    }
  }

  void reset() => emit(const ReceiptOcrState.idle());
}
