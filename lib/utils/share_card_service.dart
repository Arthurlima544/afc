import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Utility for capturing share cards and opening the native share sheet.
class ShareCardService {
  const ShareCardService._();

  /// Captures the widget identified by [key] as a 3× PNG and opens the native
  /// share sheet. The key must be attached to a [RepaintBoundary] that is
  /// currently part of the widget tree (even if inside an Offstage).
  static Future<void> captureAndShare(
    GlobalKey key,
    String filename,
  ) async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return;
    }
    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$filename');
    await file.writeAsBytes(pngBytes);
    await Share.shareXFiles(
      <XFile>[XFile(file.path, mimeType: 'image/png')],
    );
  }
}
