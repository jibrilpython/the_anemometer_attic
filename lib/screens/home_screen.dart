import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_anemometer_attic/enum/my_enums.dart';
import 'package:the_anemometer_attic/models/project_model.dart';
import 'package:the_anemometer_attic/providers/image_provider.dart';
import 'package:the_anemometer_attic/providers/project_provider.dart';
import 'package:the_anemometer_attic/providers/search_provider.dart';
import 'package:the_anemometer_attic/providers/input_provider.dart';
import 'package:the_anemometer_attic/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  InstrumentType? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final filteredByType = _selectedFilter == null
        ? allEntries
        : allEntries.where((e) => e.instrumentType == _selectedFilter).toList();
    final entries = searchProv.filteredList(filteredByType);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 150.h,
            stretch: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.fadeTitle],
              background: _buildHeader(allEntries.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 14.h),
                  _buildFilterChips(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          entries.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 140.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = entries[index];
                      final mainIndex = ref
                          .read(projectProvider)
                          .entries
                          .indexOf(entry);
                      return _buildInstrumentCard(context, entry, mainIndex);
                    }, childCount: entries.length),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 16.h),
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ventilation instrument log',
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'The Attic',
                    style: GoogleFonts.spaceGrotesk(
                      color: kPrimaryText,
                      fontSize: 44.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ref.read(inputProvider).clearAll();
                  ref.read(imageProvider).clearImage();
                  Navigator.pushNamed(context, '/add_screen');
                },
                child: Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(kRadiusSmall),
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: Colors.white, size: 22.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text(
                'Specimens:',
                style: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                count.toString().padLeft(3, '0'),
                style: GoogleFonts.jetBrainsMono(
                  color: kPrimaryText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(child: Container(height: 1, color: kOutline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSmall),
        border: Border.all(
          color: isFocused ? kAccent : kOutline,
          width: isFocused ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(
            Icons.search,
            color: isFocused ? kAccent : kSecondaryText,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) =>
                  ref.read(searchProvider.notifier).setSearchQuery(v),
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search by manufacturer, ID, or provenance...',
                hintStyle: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearSearchQuery();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Icon(Icons.close, color: kSecondaryText, size: 18.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 34.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildChip('All', null),
          ...InstrumentType.values.map((t) => _buildChip(t.label, t)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, InstrumentType? type) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: isSelected ? kAccent : kOutline, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : kSecondaryText,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentCard(
    BuildContext context,
    VentilationInstrumentModel entry,
    int index,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final isOperational = entry.conditionState == ConditionState.operational;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSmall),
          border: Border.all(color: kOutline, width: 1),
        ),
        child: Row(
          children: [
            // Image / Vane icon area
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(kRadiusSmall - 2),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  (entry.photoPath.isNotEmpty &&
                      imagePath != null &&
                      File(imagePath).existsSync())
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : Center(
                      child: CustomPaint(
                        size: Size(36.w, 36.w),
                        painter: VaneWheelPainter(
                          bladeCount: _bladeCountForType(entry.instrumentType),
                          color: isOperational ? kAccent : kAccentAmber,
                          rotationAngle: isOperational ? 0.3 : 0.0,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 14.w),
            // Info area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.atmosphericIdentifier.isNotEmpty
                        ? entry.atmosphericIdentifier
                        : 'NO ID',
                    style: GoogleFonts.jetBrainsMono(
                      color: kAccent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.manufacturer.isNotEmpty
                        ? entry.manufacturer
                        : 'Unknown Maker',
                    style: GoogleFonts.spaceGrotesk(
                      color: kPrimaryText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: BorderRadius.circular(kRadiusPill),
                          border: Border.all(color: kOutline, width: 1),
                        ),
                        child: Text(
                          entry.instrumentType.label,
                          style: GoogleFonts.inter(
                            color: kSecondaryText,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (entry.measurementRange.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(kRadiusPill),
                              border: Border.all(color: kOutline, width: 1),
                            ),
                            child: Text(
                              entry.measurementRange,
                              style: GoogleFonts.jetBrainsMono(
                                color: kSecondaryText,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Provenance tag or arrow
            if (entry.provenance.isNotEmpty)
              Container(
                constraints: BoxConstraints(maxWidth: 80.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: kAccentSurface,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
                child: Text(
                  entry.provenance,
                  style: GoogleFonts.inter(
                    color: kAccent,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              Icon(Icons.chevron_right, color: kOutline, size: 20.sp),
          ],
        ),
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

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(24.w),
      padding: EdgeInsets.all(40.w),
      alignment: const Alignment(0, -0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(64.w, 64.w),
            painter: VaneWheelPainter(
              bladeCount: 4,
              color: kOutline,
              rotationAngle: 0,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'NO INSTRUMENTS IN THIS ATTIC YET.',
            textAlign: TextAlign.center,
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

/// Minimal top-down SVG-like vane wheel painter per ui_rules.
/// Teal for operational, amber for display-only.
class VaneWheelPainter extends CustomPainter {
  final int bladeCount;
  final Color color;
  final double rotationAngle;

  VaneWheelPainter({
    required this.bladeCount,
    required this.color,
    this.rotationAngle = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bladeLength = radius * 0.85;
    final bladeWidth = radius * 0.22;

    // Hub circle
    final hubPaint = Paint()
      ..color = color.withAlpha(40)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.18, hubPaint);

    final hubStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.18, hubStroke);

    // Outer ring
    final ringPaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.95, ringPaint);

    // Blades
    final bladePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    for (int i = 0; i < bladeCount; i++) {
      final angle = (2 * math.pi * i) / bladeCount;
      canvas.save();
      canvas.rotate(angle);

      final path = Path()
        ..moveTo(0, -radius * 0.2)
        ..quadraticBezierTo(
          bladeWidth,
          -bladeLength * 0.5,
          bladeWidth * 0.6,
          -bladeLength,
        )
        ..lineTo(0, -bladeLength * 0.9)
        ..lineTo(-bladeWidth * 0.2, -bladeLength * 0.5)
        ..close();

      canvas.drawPath(path, bladePaint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VaneWheelPainter oldDelegate) =>
      oldDelegate.bladeCount != bladeCount ||
      oldDelegate.color != color ||
      oldDelegate.rotationAngle != rotationAngle;
}
