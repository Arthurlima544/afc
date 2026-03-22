import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/logger.dart';
import 'receipt_ocr_service.dart';

const String _prompt =
    'You are a receipt OCR assistant. '
    'Extract the total amount and merchant/store name from this receipt image. '
    'Respond with valid JSON only, no markdown fences: '
    '{"amount": <number or null>, "merchant": "<string or null>"}';

class GeminiReceiptOcrService implements ReceiptOcrService {
  GeminiReceiptOcrService({String? apiKey})
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey ??
            const String.fromEnvironment('GEMINI_API_KEY'),
      );

  final GenerativeModel _model;

  @override
  Future<OcrResult> scan(XFile image) async {
    final Uint8List bytes = await File(image.path).readAsBytes();
    final String mimeType = image.mimeType ?? _mimeFromPath(image.path);

    final GenerateContentResponse response = await _model.generateContent(<Content>[
      Content.multi(<Part>[
        TextPart(_prompt),
        DataPart(mimeType, bytes),
      ]),
    ]);

    final String? text = response.text?.trim();
    logger.d('Gemini OCR response: $text');

    if (text == null || text.isEmpty) {
      return const OcrResult();
    }

    try {
      // Strip optional markdown fences in case the model adds them anyway
      final String cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> json =
          jsonDecode(cleaned) as Map<String, dynamic>;

      final double? amount = switch (json['amount']) {
        final num n => n.toDouble(),
        _ => null,
      };
      final String? merchant = switch (json['merchant']) {
        final String s when s.isNotEmpty => s,
        _ => null,
      };

      return OcrResult(amount: amount, merchant: merchant);
    } on Exception catch (e) {
      logger.e('OCR JSON parse error: $e — raw: $text');
      return const OcrResult();
    }
  }

  String _mimeFromPath(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
