import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;
    _scanned = true;
    Navigator.pop(context, barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0D35),
        title: const Text('Scan Product Barcode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: _controller.toggleTorch,
            tooltip: 'Toggle flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scan overlay
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Bottom label
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xCC1A0D35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded,
                      color: AppTheme.primary, size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    'Point camera at the product barcode',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barcode will be detected automatically',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan frame overlay painter ────────────────────────────────────────────────

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerSize = 28.0;
    const frameW = 260.0;
    const frameH = 160.0;

    final left = (size.width - frameW) / 2;
    final top = (size.height - frameH) / 2 - 40;
    final right = left + frameW;
    final bottom = top + frameH;

    // Dim overlay
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), dimPaint);
    canvas.drawRect(Rect.fromLTWH(0, bottom, size.width, size.height - bottom), dimPaint);
    canvas.drawRect(Rect.fromLTWH(0, top, left, frameH), dimPaint);
    canvas.drawRect(Rect.fromLTWH(right, top, size.width - right, frameH), dimPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawPath(Path()
      ..moveTo(left, top + cornerSize)
      ..lineTo(left, top)
      ..lineTo(left + cornerSize, top), cornerPaint);
    // Top-right
    canvas.drawPath(Path()
      ..moveTo(right - cornerSize, top)
      ..lineTo(right, top)
      ..lineTo(right, top + cornerSize), cornerPaint);
    // Bottom-left
    canvas.drawPath(Path()
      ..moveTo(left, bottom - cornerSize)
      ..lineTo(left, bottom)
      ..lineTo(left + cornerSize, bottom), cornerPaint);
    // Bottom-right
    canvas.drawPath(Path()
      ..moveTo(right - cornerSize, bottom)
      ..lineTo(right, bottom)
      ..lineTo(right, bottom - cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
