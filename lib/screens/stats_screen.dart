import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_anemometer_attic/enum/my_enums.dart';
import 'package:the_anemometer_attic/models/project_model.dart';
import 'package:the_anemometer_attic/providers/project_provider.dart';
import 'package:the_anemometer_attic/utils/const.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    final entries = projectProv.entries;

    if (projectProv.isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator(color: kAccent)),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
          ),
        ),
        centerTitle: false,
      ),
      body: entries.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroDashboard(entries),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: _buildEraCluster(entries)),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildOperationalStat(entries)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTypeDistribution(entries),
                  SizedBox(height: 16.h),
                  _buildOriginsPanel(context, entries),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats_rounded, color: kSecondaryText.withAlpha(100), size: 80.sp),
          SizedBox(height: 24.h),
          Text(
            'Data requires instruments',
            style: GoogleFonts.spaceGrotesk(
              color: kPrimaryText,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Begin archiving to populate this dashboard.',
            style: GoogleFonts.inter(color: kSecondaryText, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroDashboard(List<VentilationInstrumentModel> entries) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowSubtle],
        border: Border.all(color: kOutline, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: kAccentSurface,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  border: Border.all(color: kAccent.withAlpha(50)),
                ),
                child: Text(
                  'TOTAL SPECIMENS',
                  style: GoogleFonts.jetBrainsMono(
                    color: kAccent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.all_inbox_rounded, color: kAccent, size: 24.sp),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            entries.length.toString().padLeft(2, '0'),
            style: GoogleFonts.spaceGrotesk(
              color: kPrimaryText,
              fontSize: 72.sp,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -3.0,
            ),
          ),
          SizedBox(height: 12.h),
          _buildDominantMaker(entries),
        ],
      ),
    );
  }

  Widget _buildDominantMaker(List<VentilationInstrumentModel> entries) {
    final counts = <String, int>{};
    for (var e in entries) {
      if (e.manufacturer.trim().isNotEmpty) {
        counts[e.manufacturer] = (counts[e.manufacturer] ?? 0) + 1;
      }
    }
    final topMaker = counts.isEmpty
        ? 'Unknown'
        : counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Row(
      children: [
        Text(
          'Primary Origin:',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            topMaker,
            style: GoogleFonts.inter(
              color: kPrimaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEraCluster(List<VentilationInstrumentModel> entries) {
    int minYear = 9999;
    int maxYear = 0;
    for (var e in entries) {
      if (e.yearOfManufacture.length >= 4) {
        final y = int.tryParse(e.yearOfManufacture.substring(0, 4));
        if (y != null) {
          if (y < minYear) minYear = y;
          if (y > maxYear) maxYear = y;
        }
      }
    }
    final hasYears = maxYear > 0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: [
          BoxShadow(
            color: kAccent.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline Spread',
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha(200),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            hasYears ? '${minYear}s' : 'N/A',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          Text(
            hasYears ? 'to ${maxYear}s' : '',
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha(200),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalStat(List<VentilationInstrumentModel> entries) {
    final operational = entries.where((e) => e.conditionState == ConditionState.operational).length;
    final pct = entries.isEmpty ? 0 : (operational / entries.length * 100).toInt();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline, width: 1.5),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational',
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pct',
                style: GoogleFonts.spaceGrotesk(
                  color: kPrimaryText,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: -1.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h, left: 4.w),
                child: Text(
                  '%',
                  style: GoogleFonts.inter(
                    color: kAccent,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Ready for field use',
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDistribution(List<VentilationInstrumentModel> entries) {
    final counts = <InstrumentType, int>{};
    for (var e in entries) {
      counts[e.instrumentType] = (counts[e.instrumentType] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline, width: 1.5),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classification Matrix',
            style: GoogleFonts.spaceGrotesk(
              color: kPrimaryText,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 140.w,
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _ModernDonutPainter(counts: counts, total: entries.length),
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: counts.entries.take(4).map((e) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: getInstrumentTypeColor(e.key),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                e.key.label,
                                style: GoogleFonts.inter(
                                  color: kPrimaryText,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e.value}',
                              style: GoogleFonts.jetBrainsMono(
                                color: kSecondaryText,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginsPanel(BuildContext context, List<VentilationInstrumentModel> entries) {
    final Map<String, int> origins = {};
    for (var e in entries) {
      if (e.countryOfManufacture.trim().isNotEmpty) {
        origins[e.countryOfManufacture] = (origins[e.countryOfManufacture] ?? 0) + 1;
      }
    }
    if (origins.isEmpty) return const SizedBox.shrink();

    final sorted = origins.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline, width: 1.5),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Presence',
            style: GoogleFonts.spaceGrotesk(
              color: kPrimaryText,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: sorted.map((e) {
              return Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 64.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  border: Border.all(color: kOutline, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        e.key,
                        style: GoogleFonts.inter(
                          color: kPrimaryText,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${e.value}',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ModernDonutPainter extends CustomPainter {
  final Map<InstrumentType, int> counts;
  final int total;

  _ModernDonutPainter({required this.counts, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = -math.pi / 2;

    for (var entry in counts.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = getInstrumentTypeColor(entry.key)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24.w
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 12.w),
        startAngle,
        sweepAngle, // fully closed donut chart, no gaps
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ModernDonutPainter oldDelegate) => true;
}
