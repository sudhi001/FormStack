import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// Geotrace input - trace a path/line on a map.
/// Allows users to add multiple coordinate points forming a path.
/// Result: list of maps with lat/lng entries.
// ignore: must_be_immutable
class GeotraceInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final bool isPolygon;

  GeotraceInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title, this.isPolygon = false});

  final List<Map<String, double>> _points = [];
  bool _isInitialized = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_isInitialized) {
      if (formStep.result is List) {
        for (var p in formStep.result as List) {
          if (p is Map) {
            _points.add({
              'lat': (p['lat'] as num?)?.toDouble() ?? 0,
              'lng': (p['lng'] as num?)?.toDouble() ?? 0,
            });
          }
        }
      }
      _isInitialized = true;
    }

    return Container(
      constraints:
          const BoxConstraints(minWidth: 300, maxWidth: 500, maxHeight: 450),
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Map placeholder with points visualization
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPolygon ? Icons.pentagon_outlined : Icons.timeline,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPolygon
                              ? "${_points.length} points (polygon)"
                              : "${_points.length} points (path)",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Draw points as dots
                  if (_points.isNotEmpty)
                    CustomPaint(
                      size: Size.infinite,
                      painter: _PointsPainter(_points, isPolygon: isPolygon),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Points list
            if (_points.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _points.length,
                  itemBuilder: (context, index) {
                    final p = _points[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text('${index + 1}',
                            style: const TextStyle(fontSize: 10)),
                      ),
                      title: Text(
                          'Lat: ${p['lat']!.toStringAsFixed(4)}, Lng: ${p['lng']!.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodySmall),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          setState(() {
                            _points.removeAt(index);
                            formStep.result = List.from(_points);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            // Add point button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: formStep.disabled
                        ? null
                        : () => _addPointDialog(context, setState),
                    icon: const Icon(Icons.add_location_alt, size: 18),
                    label: const Text("Add Point"),
                  ),
                ),
                if (_points.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _points.clear();
                        formStep.result = null;
                      });
                    },
                    child: const Text("Clear"),
                  ),
                ],
              ],
            ),
          ],
        );
      }),
    );
  }

  void _addPointDialog(BuildContext context, StateSetter setState) {
    final latController = TextEditingController();
    final lngController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Coordinate"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Latitude"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lngController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Longitude"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              if (lat != null && lng != null) {
                setState(() {
                  _points.add({'lat': lat, 'lng': lng});
                  formStep.result = List.from(_points);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    if (isPolygon) return _points.length >= 3;
    return _points.length >= 2;
  }

  @override
  String validationError() => isPolygon
      ? "At least 3 points required for a shape."
      : "At least 2 points required for a path.";

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _points.isEmpty ? null : List.from(_points);

  @override
  void clearFocus() {}
}

class _PointsPainter extends CustomPainter {
  final List<Map<String, double>> points;
  final bool isPolygon;

  _PointsPainter(this.points, {this.isPolygon = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Normalize points to fit in canvas
    final padding = 30.0;
    final lats = points.map((p) => p['lat']!).toList();
    final lngs = points.map((p) => p['lng']!).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    final latRange = maxLat - minLat == 0 ? 1.0 : maxLat - minLat;
    final lngRange = maxLng - minLng == 0 ? 1.0 : maxLng - minLng;

    Offset toOffset(Map<String, double> p) {
      final x = padding +
          ((p['lng']! - minLng) / lngRange) * (size.width - 2 * padding);
      final y = padding +
          ((maxLat - p['lat']!) / latRange) * (size.height - 2 * padding);
      return Offset(x, y);
    }

    // Draw lines
    final path = Path();
    path.moveTo(toOffset(points[0]).dx, toOffset(points[0]).dy);
    for (int i = 1; i < points.length; i++) {
      final o = toOffset(points[i]);
      path.lineTo(o.dx, o.dy);
    }
    if (isPolygon && points.length >= 3) {
      path.close();
    }
    canvas.drawPath(path, paint);

    // Draw dots
    for (final p in points) {
      canvas.drawCircle(toOffset(p), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
