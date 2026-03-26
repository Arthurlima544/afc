import 'package:flutter/widgets.dart';

// Fixed dimensions for share cards (logical px). At pixelRatio 3.0 this
// renders as 1080 × 1080 (square) or 1080 × 1440 (tall) pixels — both
// formats that look great on WhatsApp / Instagram.
const double kShareCardSize = 360;
const double kShareCardTall = 480;

/// Dark-themed branded wrapper used by every AFC share card.
///
/// Provides:
/// - Fixed [width] × [height] canvas (default 360 × 360).
/// - Background: near-black with a subtle [accentColor] gradient in the
///   top-left corner — each card type uses its own accent.
/// - Bottom footer row: AFC logo pill + "Gerado com AFC • afc.app" text.
/// - [MediaQuery] reset so text scale never distorts the card layout.
class ShareCardWrapper extends StatelessWidget {
  const ShareCardWrapper({
    required this.child,
    required this.accentColor,
    this.width = kShareCardSize,
    this.height = kShareCardSize,
    super.key,
  });

  final Widget child;
  final Color accentColor;
  final double width;
  final double height;

  // Fixed palette — always dark, independent of app theme.
  static const Color _bg = Color(0xFF0F0F0F);
  static const Color _primary = Color(0xFF0D9488);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _muted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: const MediaQueryData(),
    child: SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.fromRGBO(
                accentColor.r.toInt(),
                accentColor.g.toInt(),
                accentColor.b.toInt(),
                0.20,
              ),
              _bg,
              _bg,
            ],
            stops: const <double>[0.0, 0.38, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: child),
              const SizedBox(height: 10),
              // ── Footer ──────────────────────────────────────────────────
              Row(
                children: <Widget>[
                  // AFC logo pill
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text(
                        'AFC',
                        style: TextStyle(
                          color: _white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Gerado com AFC • afc.app',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
