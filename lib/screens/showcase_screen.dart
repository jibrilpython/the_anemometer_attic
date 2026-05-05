import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_anemometer_attic/enum/my_enums.dart';
import 'package:the_anemometer_attic/models/project_model.dart';
import 'package:the_anemometer_attic/providers/image_provider.dart';
import 'package:the_anemometer_attic/providers/project_provider.dart';
import 'package:the_anemometer_attic/utils/const.dart';

/// A single airflow particle in the wind tunnel simulation.
class AirParticle {
  double x, y;
  double dx, dy;
  double size;
  double opacity;

  AirParticle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.size,
    this.opacity = 1.0,
  });
}

/// A draggable instrument node in the 2D wind tunnel.
class InstrumentNode {
  final InstrumentType type;
  final int count;
  final List<VentilationInstrumentModel> items;

  double x, y;
  double dx, dy;
  double radius;
  double vaneRotation;
  bool isGrabbed = false;

  InstrumentNode({
    required this.type,
    required this.count,
    required this.items,
    required this.x,
    required this.y,
    required double baseRadius,
  }) : dx = (math.Random().nextDouble() - 0.5) * 2,
       dy = (math.Random().nextDouble() - 0.5) * 2,
       radius = baseRadius,
       vaneRotation = math.Random().nextDouble() * math.pi * 2;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<InstrumentNode> _nodes = [];
  final List<AirParticle> _particles = [];
  bool _isInitialized = false;
  int _lastEntriesHash = -1;
  InstrumentNode? _focusedNode;
  final math.Random _rng = math.Random();
  double _windAngle = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  int _computeHash(List<VentilationInstrumentModel> entries) {
    int hash = entries.length;
    for (var e in entries) {
      hash ^=
          e.instrumentType.hashCode ^
          e.atmosphericIdentifier.hashCode ^
          e.yearOfManufacture.hashCode ^
          e.manufacturer.hashCode ^
          e.photoPath.hashCode ^
          e.conditionState.hashCode;
    }
    return hash;
  }

  void _initializeNodes(
    List<VentilationInstrumentModel> entries,
    Size screenSize,
  ) {
    if (screenSize.width == 0 || entries.isEmpty) return;

    final currentHash = _computeHash(entries);
    if (_isInitialized && _lastEntriesHash == currentHash) return;

    _isInitialized = true;
    _lastEntriesHash = currentHash;

    final counts = <InstrumentType, int>{};
    for (var e in entries) {
      counts[e.instrumentType] = (counts[e.instrumentType] ?? 0) + 1;
    }
    if (counts.isEmpty) return;

    final maxCount = counts.values.reduce(math.max);
    final prevFocus = _focusedNode?.type;

    _nodes = counts.keys.map((type) {
      final count = counts[type]!;
      final factor = (count / maxCount).clamp(0.35, 1.0);
      final radius = 56.w * factor;

      return InstrumentNode(
        type: type,
        count: count,
        items: entries.where((e) => e.instrumentType == type).toList(),
        x: (screenSize.width / 2) + (_rng.nextDouble() - 0.5) * 120,
        y: (screenSize.height / 3) + (_rng.nextDouble() - 0.5) * 120,
        baseRadius: radius,
      );
    }).toList();

    if (prevFocus != null) {
      try {
        _focusedNode = _nodes.firstWhere((o) => o.type == prevFocus);
      } catch (e) {
        _focusedNode = null;
      }
    } else {
      _focusedNode = null;
    }

    // Seed initial particles
    _particles.clear();
    for (int i = 0; i < 60; i++) {
      _particles.add(_spawnParticle(screenSize));
    }
  }

  AirParticle _spawnParticle(Size size) {
    final windDx = math.cos(_windAngle) * (0.5 + _rng.nextDouble() * 1.5);
    final windDy = math.sin(_windAngle) * (0.5 + _rng.nextDouble() * 1.5);
    return AirParticle(
      x: _rng.nextDouble() * size.width,
      y: 120.h + _rng.nextDouble() * (size.height - 200.h),
      dx: windDx,
      dy: windDy,
      size: 1.5 + _rng.nextDouble() * 2.5,
      opacity: 0.15 + _rng.nextDouble() * 0.25,
    );
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final Size size = MediaQuery.of(context).size;

    // Slowly drift wind direction
    _windAngle += 0.002;

    // Update air particles
    for (var p in _particles) {
      p.x += p.dx;
      p.y += p.dy;

      // Deflect particles around nodes
      for (var node in _nodes) {
        final distX = p.x - node.x;
        final distY = p.y - node.y;
        final distSq = distX * distX + distY * distY;
        final deflectR = node.radius + 20;
        if (distSq < deflectR * deflectR && distSq > 0) {
          final dist = math.sqrt(distSq);
          final nx = distX / dist;
          final ny = distY / dist;
          p.dx += nx * 0.3;
          p.dy += ny * 0.3;
          // Spin the vane when air flows past
          node.vaneRotation += 0.04;
        }
      }

      // Recycle off-screen particles
      if (p.x < -20 ||
          p.x > size.width + 20 ||
          p.y < 100.h ||
          p.y > size.height + 20) {
        final np = _spawnParticle(size);
        p.x = np.x;
        p.y = np.y;
        p.dx = np.dx;
        p.dy = np.dy;
        p.opacity = np.opacity;
      }
    }

    // Update instrument nodes
    if (_nodes.isEmpty) return;

    final double centerX = size.width / 2;
    final double centerY = _focusedNode == null
        ? size.height / 2
        : size.height * 0.25;
    const double friction = 0.93;
    const double gravityStrength = 0.015;
    const double bounce = 0.5;

    for (int i = 0; i < _nodes.length; i++) {
      final o = _nodes[i];

      // Passive vane rotation
      o.vaneRotation += 0.008;

      if (o.isGrabbed) {
        o.dx = 0;
        o.dy = 0;
      } else {
        o.dx += (centerX - o.x) * gravityStrength;
        o.dy += (centerY - o.y) * gravityStrength;
        o.dx *= friction;
        o.dy *= friction;
        o.x += o.dx;
        o.y += o.dy;

        if (o.x - o.radius < 0) {
          o.x = o.radius;
          o.dx = -o.dx * bounce;
        } else if (o.x + o.radius > size.width) {
          o.x = size.width - o.radius;
          o.dx = -o.dx * bounce;
        }
        if (o.y - o.radius < 120.h) {
          o.y = o.radius + 120.h;
          o.dy = -o.dy * bounce;
        } else if (o.y + o.radius > size.height) {
          o.y = size.height - o.radius;
          o.dy = -o.dy * bounce;
        }
      }

      // Pairwise repulsion
      for (int j = i + 1; j < _nodes.length; j++) {
        final o2 = _nodes[j];
        final double distX = o.x - o2.x;
        final double distY = o.y - o2.y;
        final double distSq = distX * distX + distY * distY;
        final double minRadius = o.radius + o2.radius + 12.w;

        if (distSq < minRadius * minRadius && distSq > 0) {
          final double distance = math.sqrt(distSq);
          final double overlap = minRadius - distance;
          final double nx = distX / distance;
          final double ny = distY / distance;

          final totalR = o.radius + o2.radius;
          final r1Ratio = o2.radius / totalR;
          final r2Ratio = o.radius / totalR;

          if (!o.isGrabbed) {
            o.x += nx * overlap * r1Ratio * 0.5;
            o.y += ny * overlap * r1Ratio * 0.5;
            o.dx += nx * overlap * 0.08;
            o.dy += ny * overlap * 0.08;
          }
          if (!o2.isGrabbed) {
            o2.x -= nx * overlap * r2Ratio * 0.5;
            o2.y -= ny * overlap * r2Ratio * 0.5;
            o2.dx -= nx * overlap * 0.08;
            o2.dy -= ny * overlap * 0.08;
          }
        }
      }
    }

    setState(() {});
  }

  void _focusNode(InstrumentNode node) {
    if (_focusedNode == node) {
      _focusedNode = null;
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.selectionClick();
    _focusedNode = node;
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final Size size = MediaQuery.of(context).size;

    _initializeNodes(entries, size);

    return Scaffold(
      backgroundColor: kBackground,
      body: entries.isEmpty
          ? _buildEmptyState()
          : Stack(
              fit: StackFit.expand,
              children: [
                // 1. Air particle field
                Positioned.fill(
                  child: CustomPaint(
                    painter: AirflowPainter(particles: _particles),
                    child: const SizedBox.expand(),
                  ),
                ),

                // 2. Instrument nodes with vane wheels
                ..._nodes.map((node) {
                  final isFocused = _focusedNode == node;
                  return Positioned(
                    left: node.x - node.radius,
                    top: node.y - node.radius,
                    width: node.radius * 2,
                    height: node.radius * 2,
                    child: GestureDetector(
                      onPanDown: (_) => node.isGrabbed = true,
                      onPanUpdate: (d) {
                        node.x += d.delta.dx;
                        node.y += d.delta.dy;
                      },
                      onPanEnd: (d) {
                        node.isGrabbed = false;
                        node.dx = d.velocity.pixelsPerSecond.dx / 60;
                        node.dy = d.velocity.pixelsPerSecond.dy / 60;
                      },
                      onPanCancel: () => node.isGrabbed = false,
                      onTap: () => _focusNode(node),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFocused ? kAccent : kPanelBg,
                          border: Border.all(
                            color: isFocused ? kAccent : kOutline,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (isFocused)
                              BoxShadow(
                                color: kAccent.withAlpha(40),
                                blurRadius: 30,
                              ),
                            kShadowSubtle,
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Spinning vane in background
                            CustomPaint(
                              size: Size(node.radius * 1.6, node.radius * 1.6),
                              painter: _VaneOverlayPainter(
                                rotation: node.vaneRotation,
                                color: (isFocused
                                    ? Colors.white.withAlpha(40)
                                    : kAccent.withAlpha(20)),
                                bladeCount: _bladeCountForType(node.type),
                              ),
                            ),
                            // Label
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  node.count.toString(),
                                  style: GoogleFonts.spaceGrotesk(
                                    color: isFocused
                                        ? Colors.white
                                        : kPrimaryText,
                                    fontSize: node.radius * 0.55,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (node.radius > 36.w)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    child: Text(
                                      node.type.label,
                                      style: GoogleFonts.inter(
                                        color: isFocused
                                            ? Colors.white.withAlpha(200)
                                            : kSecondaryText,
                                        fontSize: node.radius * 0.18,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // 3. Scrim when focused
                if (_focusedNode != null)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _focusedNode = null);
                      },
                      child: Container(color: Colors.black.withAlpha(50)),
                    ),
                  ),

                // 4. Focused gallery carousel
                if (_focusedNode != null) _buildFocusSlider(),

                // 5. Header overlay
                Positioned(
                  top: 54.h,
                  left: 20.w,
                  right: 20.w,
                  child: IgnorePointer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Mine Map',
                          style: GoogleFonts.spaceGrotesk(
                            color: kPrimaryText,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Drag nodes to simulate airflow. Tap to explore.',
                          style: GoogleFonts.inter(
                            color: kSecondaryText,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
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

  int _bladeCountForType(InstrumentType type) {
    switch (type) {
      case InstrumentType.fanAnemometer:
        return 6;
      case InstrumentType.biramAnemometer:
        return 4;
      case InstrumentType.windSpeedMeter:
        return 3;
      default:
        return 4;
    }
  }

  Widget _buildFocusSlider() {
    final imageProv = ref.watch(imageProvider);
    final items = _focusedNode!.items;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.40 + 80.h,
      child: Container(
        padding: EdgeInsets.only(top: 20.h),
        decoration: BoxDecoration(
          color: kPanelBg.withAlpha(240),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(kRadiusSmall),
            topRight: Radius.circular(kRadiusSmall),
          ),
          border: const Border(top: BorderSide(color: kOutline, width: 1)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(kRadiusSmall),
            topRight: Radius.circular(kRadiusSmall),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _focusedNode!.type.label,
                        style: GoogleFonts.spaceGrotesk(
                          color: kPrimaryText,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _focusedNode = null);
                        },
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: kBackground,
                            borderRadius: BorderRadius.circular(kRadiusSmall),
                            border: Border.all(color: kOutline, width: 1),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18.sp,
                            color: kPrimaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final globalIndex = ref
                          .read(projectProvider)
                          .entries
                          .indexWhere((e) => e.id == item.id);

                      if (globalIndex == -1) return const SizedBox.shrink();

                      final updatedItem = ref.read(projectProvider).entries[globalIndex];
                      final imagePath = imageProv.getImagePath(updatedItem.photoPath);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pushNamed(
                            context,
                            '/info_screen',
                            arguments: {'index': globalIndex},
                          );
                        },
                        child: Container(
                          width: 180.w,
                          margin: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: kPanelBg,
                            borderRadius: BorderRadius.circular(kRadiusSmall),
                            border: Border.all(color: kOutline, width: 1),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child:
                                    (imagePath != null &&
                                        updatedItem.photoPath.isNotEmpty &&
                                        File(imagePath).existsSync())
                                    ? Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: kBackground,
                                        child: Icon(
                                          Icons.air,
                                          color: kSecondaryText.withAlpha(50),
                                          size: 40.sp,
                                        ),
                                      ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.atmosphericIdentifier.isNotEmpty
                                            ? item.atmosphericIdentifier
                                            : 'Unassigned',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: kAccent,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        item.manufacturer.isNotEmpty
                                            ? item.manufacturer
                                            : 'Unknown Maker',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: kPrimaryText,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.air, color: kSecondaryText.withAlpha(100), size: 64.sp),
          SizedBox(height: 24.h),
          Text(
            'NO INSTRUMENTS IN THIS ATTIC YET.',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints flowing air particles across the screen.
class AirflowPainter extends CustomPainter {
  final List<AirParticle> particles;
  AirflowPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = kAccent.withAlpha((p.opacity * 255).toInt().clamp(0, 255))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);

      // Tiny trail
      final trailPaint = Paint()
        ..color = kAccent.withAlpha((p.opacity * 80).toInt().clamp(0, 255))
        ..strokeWidth = p.size * 0.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(p.x, p.y),
        Offset(p.x - p.dx * 6, p.y - p.dy * 6),
        trailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AirflowPainter oldDelegate) => true;
}

/// Paints a rotating vane overlay behind the node label.
class _VaneOverlayPainter extends CustomPainter {
  final double rotation;
  final Color color;
  final int bladeCount;

  _VaneOverlayPainter({
    required this.rotation,
    required this.color,
    required this.bladeCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bladeLength = radius * 0.9;
    final bladeWidth = radius * 0.2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (int i = 0; i < bladeCount; i++) {
      final angle = (2 * math.pi * i) / bladeCount;
      canvas.save();
      canvas.rotate(angle);

      final path = Path()
        ..moveTo(0, -radius * 0.15)
        ..quadraticBezierTo(
          bladeWidth,
          -bladeLength * 0.5,
          bladeWidth * 0.5,
          -bladeLength,
        )
        ..lineTo(0, -bladeLength * 0.85)
        ..lineTo(-bladeWidth * 0.15, -bladeLength * 0.4)
        ..close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VaneOverlayPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
