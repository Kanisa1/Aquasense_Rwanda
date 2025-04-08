import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:aqua_sense/utils/app_theme.dart';

class DummyMap extends StatefulWidget {
  final List<MapMarker> markers;
  final Function(int) onMarkerTap;
  final double initialZoom;

  const DummyMap({
    Key? key,
    required this.markers,
    required this.onMarkerTap,
    this.initialZoom = 1.0,
  }) : super(key: key);

  @override
  State<DummyMap> createState() => _DummyMapState();
}

class _DummyMapState extends State<DummyMap> {
  double _zoom = 1.0;
  Offset _offset = Offset.zero;
  Offset? _startingFocalPoint;
  Offset? _previousOffset;
  double? _previousZoom;

  @override
  void initState() {
    super.initState();
    _zoom = widget.initialZoom;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _startingFocalPoint = details.focalPoint;
    _previousOffset = _offset;
    _previousZoom = _zoom;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_startingFocalPoint == null || _previousOffset == null || _previousZoom == null) {
      return;
    }

    setState(() {
      // Update zoom
      _zoom = (_previousZoom! * details.scale).clamp(0.5, 2.0);

      // Update offset for panning
      final Offset delta = details.focalPoint - _startingFocalPoint!;
      _offset = _previousOffset! + delta / _zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: Stack(
        children: [
          // Map background
          Container(
            color: const Color(0xFFE0F2F1), // Light teal color for map
          ),
          
          // Map grid
          CustomPaint(
            painter: MapGridPainter(zoom: _zoom, offset: _offset),
            size: Size.infinite,
          ),
          
          // Map features
          CustomPaint(
            painter: MapFeaturesPainter(zoom: _zoom, offset: _offset),
            size: Size.infinite,
          ),
          
          // Map markers
          ...widget.markers.map((marker) {
            final position = _calculateMarkerPosition(marker.position);
            return Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onTap: () => widget.onMarkerTap(marker.id),
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        marker.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          
          // Zoom controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _zoom = (_zoom + 0.2).clamp(0.5, 2.0);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        _zoom = (_zoom - 0.2).clamp(0.5, 2.0);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Map legend
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Water Reservoir',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF90CAF9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Water Body',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA5D6A7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Park/Field',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Offset _calculateMarkerPosition(Offset normalizedPosition) {
    final size = MediaQuery.of(context).size;
    final x = (normalizedPosition.dx * size.width * _zoom) + _offset.dx;
    final y = (normalizedPosition.dy * size.height * _zoom) + _offset.dy;
    return Offset(x, y);
  }
}

class MapGridPainter extends CustomPainter {
  final double zoom;
  final Offset offset;

  MapGridPainter({required this.zoom, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final gridSize = 40.0 * zoom;
    final startX = (offset.dx % gridSize);
    final startY = (offset.dy % gridSize);

    // Draw vertical lines
    for (double x = startX; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = startY; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(MapGridPainter oldDelegate) {
    return oldDelegate.zoom != zoom || oldDelegate.offset != offset;
  }
}

class MapFeaturesPainter extends CustomPainter {
  final double zoom;
  final Offset offset;
  final List<MapFeature> features = [
    MapFeature(
      type: FeatureType.road,
      points: [
        Offset(0.2, 0.3),
        Offset(0.8, 0.3),
      ],
    ),
    MapFeature(
      type: FeatureType.road,
      points: [
        Offset(0.5, 0.1),
        Offset(0.5, 0.9),
      ],
    ),
    MapFeature(
      type: FeatureType.water,
      points: [
        Offset(0.1, 0.7),
        Offset(0.3, 0.8),
        Offset(0.2, 0.9),
        Offset(0.1, 0.8),
      ],
    ),
    MapFeature(
      type: FeatureType.park,
      points: [
        Offset(0.7, 0.6),
        Offset(0.9, 0.6),
        Offset(0.9, 0.8),
        Offset(0.7, 0.8),
      ],
    ),
    // Add more features for a richer map
    MapFeature(
      type: FeatureType.road,
      points: [
        Offset(0.2, 0.5),
        Offset(0.8, 0.5),
      ],
    ),
    MapFeature(
      type: FeatureType.road,
      points: [
        Offset(0.2, 0.7),
        Offset(0.8, 0.7),
      ],
    ),
    MapFeature(
      type: FeatureType.water,
      points: [
        Offset(0.6, 0.1),
        Offset(0.8, 0.2),
        Offset(0.7, 0.3),
        Offset(0.6, 0.2),
      ],
    ),
    MapFeature(
      type: FeatureType.park,
      points: [
        Offset(0.1, 0.1),
        Offset(0.3, 0.1),
        Offset(0.3, 0.3),
        Offset(0.1, 0.3),
      ],
    ),
  ];

  MapFeaturesPainter({required this.zoom, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    for (final feature in features) {
      switch (feature.type) {
        case FeatureType.road:
          _drawRoad(canvas, size, feature);
          break;
        case FeatureType.water:
          _drawWater(canvas, size, feature);
          break;
        case FeatureType.park:
          _drawPark(canvas, size, feature);
          break;
      }
    }
  }

  void _drawRoad(Canvas canvas, Size size, MapFeature feature) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.0 * zoom
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startPoint = _calculatePoint(feature.points[0], size);
    path.moveTo(startPoint.dx, startPoint.dy);

    for (int i = 1; i < feature.points.length; i++) {
      final point = _calculatePoint(feature.points[i], size);
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawWater(Canvas canvas, Size size, MapFeature feature) {
    final paint = Paint()
      ..color = const Color(0xFF90CAF9)
      ..style = PaintingStyle.fill;

    final path = Path();
    final startPoint = _calculatePoint(feature.points[0], size);
    path.moveTo(startPoint.dx, startPoint.dy);

    for (int i = 1; i < feature.points.length; i++) {
      final point = _calculatePoint(feature.points[i], size);
      path.lineTo(point.dx, point.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPark(Canvas canvas, Size size, MapFeature feature) {
    final paint = Paint()
      ..color = const Color(0xFFA5D6A7)
      ..style = PaintingStyle.fill;

    final path = Path();
    final startPoint = _calculatePoint(feature.points[0], size);
    path.moveTo(startPoint.dx, startPoint.dy);

    for (int i = 1; i < feature.points.length; i++) {
      final point = _calculatePoint(feature.points[i], size);
      path.lineTo(point.dx, point.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  Offset _calculatePoint(Offset normalizedPoint, Size size) {
    return Offset(
      (normalizedPoint.dx * size.width * zoom) + offset.dx,
      (normalizedPoint.dy * size.height * zoom) + offset.dy,
    );
  }

  @override
  bool shouldRepaint(MapFeaturesPainter oldDelegate) {
    return oldDelegate.zoom != zoom || oldDelegate.offset != offset;
  }
}

enum FeatureType { road, water, park }

class MapFeature {
  final FeatureType type;
  final List<Offset> points;

  MapFeature({
    required this.type,
    required this.points,
  });
}

class MapMarker {
  final int id;
  final String title;
  final Offset position;

  MapMarker({
    required this.id,
    required this.title,
    required this.position,
  });
}

