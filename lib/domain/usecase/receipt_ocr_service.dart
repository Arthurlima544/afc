import 'package:image_picker/image_picker.dart';

/// Result of an OCR scan attempt.
class OcrResult {
  const OcrResult({this.amount, this.merchant});

  final double? amount;
  final String? merchant;

  bool get isEmpty => amount == null && merchant == null;
}

/// Contract for scanning a receipt image and extracting structured data.
abstract class ReceiptOcrService {
  Future<OcrResult> scan(XFile image);
}
