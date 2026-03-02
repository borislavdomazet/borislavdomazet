import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Demo ekran koji prikazuje kako CPCL etiketa izgleda pre stampe.
///
/// Kopiraj ovaj fajl u Flutter projekat i koristi [CpclLabelPreview]
/// gde god zelis pregled etikete.
class CpclPreviewDemoPage extends StatelessWidget {
  const CpclPreviewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cpcl = _buildTestCpcl();

    return Scaffold(
      appBar: AppBar(title: const Text('CPCL preview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: CpclLabelPreview(
                cpcl: cpcl,
                backgroundColor: Colors.white,
                inkColor: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    cpcl,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTestCpcl() {
    return <String>[
      '! 0 200 200 471 1', // visina etikete
      'PW 455', // sirina etikete
      'LEFT',
      'SETMAG 1 1',
      'SETBOLD 1',
      'TEXT 4 0 200 20 -50%',
      // Naziv proizvoda
      'SETBOLD 1',
      'TEXT 1 0 20 100 Sargarepa kockice 200 g',
      // Opis
      'SETMAG 1 1',
      'SETBOLD 0',
      'TEXT 0 0 20 130 popust pred istek roka trajanja',
      // Stara cena (strike-through)
      'TEXT 0 0 20 150 199.99',
      'LINE 20 175 150 175 2',
      // Nova cena (centralno)
      'SETBOLD 1',
      'TEXT 0 0 160 165 100.00',
      // Rok trajanja (levo)
      'SETBOLD 1',
      'TEXT 0 0 20 250 rok trajanja 22.05.2025.',
      // EAN broj tekstualno (centar, iznad barkoda)
      'TEXT 0 0 152 220 8606108753293',
      // EAN13 barkod na dnu
      'BARCODE EAN13 2 2 60 60 390 8606108753293',
      'FORM',
      'PRINT',
    ].join('\n');
  }
}

class CpclLabelPreview extends StatelessWidget {
  const CpclLabelPreview({
    required this.cpcl,
    this.backgroundColor = Colors.white,
    this.inkColor = Colors.black,
    super.key,
  });

  final String cpcl;
  final Color backgroundColor;
  final Color inkColor;

  @override
  Widget build(BuildContext context) {
    final CpclDocument document = CpclParser.parse(cpcl);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: document.width.toDouble(),
            height: document.height.toDouble(),
            child: CustomPaint(
              painter: _CpclPainter(
                document: document,
                backgroundColor: backgroundColor,
                inkColor: inkColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CpclParser {
  static CpclDocument parse(String cpcl) {
    int width = 455;
    int height = 471;
    int magX = 1;
    int magY = 1;
    int bold = 0;

    final List<CpclCommand> commands = <CpclCommand>[];

    final List<String> lines = cpcl.split(RegExp(r'\r?\n'));
    for (final String rawLine in lines) {
      final String line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final List<String> parts = line.split(RegExp(r'\s+'));
      final String command = parts.first.toUpperCase();

      switch (command) {
        case '!':
          if (parts.length >= 5) {
            height = _toInt(parts[4], fallback: height);
          }
          break;
        case 'PW':
          if (parts.length >= 2) {
            width = _toInt(parts[1], fallback: width);
          }
          break;
        case 'SETMAG':
          if (parts.length >= 3) {
            magX = math.max(1, _toInt(parts[1], fallback: magX));
            magY = math.max(1, _toInt(parts[2], fallback: magY));
          }
          break;
        case 'SETBOLD':
          if (parts.length >= 2) {
            bold = _toInt(parts[1], fallback: bold);
          }
          break;
        case 'TEXT':
          if (parts.length >= 6) {
            commands.add(
              CpclText(
                font: _toInt(parts[1], fallback: 0),
                rotation: _toInt(parts[2], fallback: 0),
                x: _toInt(parts[3], fallback: 0).toDouble(),
                y: _toInt(parts[4], fallback: 0).toDouble(),
                value: parts.sublist(5).join(' '),
                bold: bold > 0,
                magX: magX,
                magY: magY,
              ),
            );
          }
          break;
        case 'LINE':
          if (parts.length >= 6) {
            commands.add(
              CpclLine(
                x1: _toInt(parts[1], fallback: 0).toDouble(),
                y1: _toInt(parts[2], fallback: 0).toDouble(),
                x2: _toInt(parts[3], fallback: 0).toDouble(),
                y2: _toInt(parts[4], fallback: 0).toDouble(),
                thickness: _toInt(parts[5], fallback: 1).toDouble(),
              ),
            );
          }
          break;
        case 'BARCODE':
          // Format koji koristimo ovde:
          // BARCODE EAN13 <moduleWidth> <ratio> <height> <x> <y> <data>
          if (parts.length >= 8) {
            commands.add(
              CpclBarcode(
                symbology: parts[1].toUpperCase(),
                moduleWidth: _toInt(parts[2], fallback: 2),
                ratio: _toInt(parts[3], fallback: 2),
                height: _toInt(parts[4], fallback: 60),
                x: _toInt(parts[5], fallback: 0).toDouble(),
                y: _toInt(parts[6], fallback: 0).toDouble(),
                data: parts.sublist(7).join(' '),
              ),
            );
          }
          break;
        default:
          // LEFT, FORM, PRINT i ostalo ignorisemo u preview-u.
          break;
      }
    }

    return CpclDocument(width: width, height: height, commands: commands);
  }

  static int _toInt(String raw, {required int fallback}) {
    return int.tryParse(raw) ?? fallback;
  }
}

class CpclDocument {
  const CpclDocument({
    required this.width,
    required this.height,
    required this.commands,
  });

  final int width;
  final int height;
  final List<CpclCommand> commands;
}

abstract class CpclCommand {
  const CpclCommand();
}

class CpclText extends CpclCommand {
  const CpclText({
    required this.font,
    required this.rotation,
    required this.x,
    required this.y,
    required this.value,
    required this.bold,
    required this.magX,
    required this.magY,
  });

  final int font;
  final int rotation;
  final double x;
  final double y;
  final String value;
  final bool bold;
  final int magX;
  final int magY;
}

class CpclLine extends CpclCommand {
  const CpclLine({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.thickness,
  });

  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double thickness;
}

class CpclBarcode extends CpclCommand {
  const CpclBarcode({
    required this.symbology,
    required this.moduleWidth,
    required this.ratio,
    required this.height,
    required this.x,
    required this.y,
    required this.data,
  });

  final String symbology;
  final int moduleWidth;
  final int ratio;
  final int height;
  final double x;
  final double y;
  final String data;
}

class _CpclPainter extends CustomPainter {
  const _CpclPainter({
    required this.document,
    required this.backgroundColor,
    required this.inkColor,
  });

  final CpclDocument document;
  final Color backgroundColor;
  final Color inkColor;

  static const Map<int, double> _fontSizeByCpclFont = <int, double>{
    0: 16,
    1: 22,
    2: 26,
    3: 30,
    4: 34,
    5: 40,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / document.width;
    final double sy = size.height / document.height;

    canvas.save();
    canvas.scale(sx, sy);

    final Rect paper = Rect.fromLTWH(
      0,
      0,
      document.width.toDouble(),
      document.height.toDouble(),
    );

    canvas.drawRect(
      paper,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    for (final CpclCommand command in document.commands) {
      if (command is CpclText) {
        _drawText(canvas, command);
      } else if (command is CpclLine) {
        _drawLine(canvas, command);
      } else if (command is CpclBarcode) {
        _drawBarcode(canvas, command);
      }
    }

    canvas.drawRect(
      paper,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  void _drawText(Canvas canvas, CpclText command) {
    final double base = _fontSizeByCpclFont[command.font] ?? 16;
    final double fontSize = base * command.magY;

    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: command.value,
        style: TextStyle(
          color: inkColor,
          fontSize: fontSize,
          fontWeight: command.bold ? FontWeight.w700 : FontWeight.w400,
          height: 1.0,
        ),
      ),
    )..layout(maxWidth: math.max(0.0, document.width - command.x));

    final int r = command.rotation % 4;
    if (r == 0) {
      _paintScaledText(canvas, painter, command.x, command.y, command.magX);
      return;
    }

    // Osnovna podrska za rotaciju teksta po cetvrtini kruga.
    canvas.save();
    canvas.translate(command.x, command.y);
    canvas.rotate((math.pi / 2) * r);
    switch (r) {
      case 1:
        _paintScaledText(canvas, painter, 0, -painter.height, command.magX);
        break;
      case 2:
        _paintScaledText(
          canvas,
          painter,
          -painter.width,
          -painter.height,
          command.magX,
        );
        break;
      case 3:
        _paintScaledText(canvas, painter, -painter.width, 0, command.magX);
        break;
    }
    canvas.restore();
  }

  void _paintScaledText(
    Canvas canvas,
    TextPainter painter,
    double x,
    double y,
    int magX,
  ) {
    final double scaleX = math.max(1, magX).toDouble();
    if (scaleX == 1) {
      painter.paint(canvas, Offset(x, y));
      return;
    }
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scaleX, 1);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawLine(Canvas canvas, CpclLine command) {
    canvas.drawLine(
      Offset(command.x1, command.y1),
      Offset(command.x2, command.y2),
      Paint()
        ..color = inkColor
        ..strokeWidth = math.max(1, command.thickness)
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawBarcode(Canvas canvas, CpclBarcode command) {
    if (command.symbology != 'EAN13') {
      _drawUnsupportedBarcode(canvas, command);
      return;
    }
    _drawEan13(canvas, command);
  }

  void _drawUnsupportedBarcode(Canvas canvas, CpclBarcode command) {
    final Rect rect = Rect.fromLTWH(
      command.x,
      command.y,
      160,
      command.height.toDouble(),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = inkColor
        ..style = PaintingStyle.stroke,
    );
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: '${command.symbology} ${command.data}',
        style: TextStyle(color: inkColor, fontSize: 10),
      ),
    )..layout(maxWidth: rect.width);
    painter.paint(canvas, Offset(rect.left + 4, rect.top + 4));
  }

  void _drawEan13(Canvas canvas, CpclBarcode command) {
    final String rawDigits = command.data.replaceAll(RegExp(r'[^0-9]'), '');
    final String? digits = _normalizeEan13(rawDigits);
    if (digits == null) {
      _drawUnsupportedBarcode(canvas, command);
      return;
    }

    final String pattern = _ean13Pattern(digits);
    final double module = math.max(1.0, command.moduleWidth.toDouble());
    final double barHeight = command.height.toDouble();

    final Paint barPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < pattern.length; i++) {
      if (pattern[i] == '1') {
        final double x = command.x + (i * module);
        canvas.drawRect(
          Rect.fromLTWH(x, command.y, module, barHeight),
          barPaint,
        );
      }
    }

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: digits,
        style: TextStyle(
          color: inkColor,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    )..layout();
    textPainter.paint(canvas, Offset(command.x, command.y + barHeight + 4));
  }

  String? _normalizeEan13(String digits) {
    if (digits.length == 13) {
      return digits;
    }
    if (digits.length == 12) {
      final int checksum = _ean13Checksum(digits);
      return '$digits$checksum';
    }
    return null;
  }

  int _ean13Checksum(String firstTwelveDigits) {
    int sum = 0;
    for (int i = 0; i < firstTwelveDigits.length; i++) {
      final int d = int.parse(firstTwelveDigits[i]);
      if (i.isEven) {
        sum += d;
      } else {
        sum += d * 3;
      }
    }
    return (10 - (sum % 10)) % 10;
  }

  String _ean13Pattern(String digits) {
    const Map<String, String> l = <String, String>{
      '0': '0001101',
      '1': '0011001',
      '2': '0010011',
      '3': '0111101',
      '4': '0100011',
      '5': '0110001',
      '6': '0101111',
      '7': '0111011',
      '8': '0110111',
      '9': '0001011',
    };
    const Map<String, String> g = <String, String>{
      '0': '0100111',
      '1': '0110011',
      '2': '0011011',
      '3': '0100001',
      '4': '0011101',
      '5': '0111001',
      '6': '0000101',
      '7': '0010001',
      '8': '0001001',
      '9': '0010111',
    };
    const Map<String, String> r = <String, String>{
      '0': '1110010',
      '1': '1100110',
      '2': '1101100',
      '3': '1000010',
      '4': '1011100',
      '5': '1001110',
      '6': '1010000',
      '7': '1000100',
      '8': '1001000',
      '9': '1110100',
    };
    const Map<String, String> parity = <String, String>{
      '0': 'LLLLLL',
      '1': 'LLGLGG',
      '2': 'LLGGLG',
      '3': 'LLGGGL',
      '4': 'LGLLGG',
      '5': 'LGGLLG',
      '6': 'LGGGLL',
      '7': 'LGLGLG',
      '8': 'LGLGGL',
      '9': 'LGGLGL',
    };

    final String first = digits.substring(0, 1);
    final String left = digits.substring(1, 7);
    final String right = digits.substring(7, 13);
    final String p = parity[first] ?? 'LLLLLL';

    final StringBuffer buffer = StringBuffer('101');
    for (int i = 0; i < left.length; i++) {
      final String d = left[i];
      buffer.write(p[i] == 'L' ? l[d] : g[d]);
    }
    buffer.write('01010');
    for (int i = 0; i < right.length; i++) {
      buffer.write(r[right[i]]);
    }
    buffer.write('101');
    return buffer.toString();
  }

  @override
  bool shouldRepaint(covariant _CpclPainter oldDelegate) {
    return oldDelegate.document != document ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.inkColor != inkColor;
  }
}
