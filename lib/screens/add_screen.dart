import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_anemometer_attic/common/photo_bottom_sheet.dart';
import 'package:the_anemometer_attic/enum/my_enums.dart';
import 'package:the_anemometer_attic/providers/image_provider.dart';
import 'package:the_anemometer_attic/providers/input_provider.dart';
import 'package:the_anemometer_attic/providers/project_provider.dart';
import 'package:the_anemometer_attic/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late TextEditingController _idCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _vaneCtrl;
  late TextEditingController _rangeCtrl;
  late TextEditingController _matCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _accCtrl;
  late TextEditingController _markCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  static const _pageTitles = [
    'Identity',
    'Mechanical',
    'Physical',
    'Provenance',
  ];

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.atmosphericIdentifier);
    _manCtrl = TextEditingController(text: p.manufacturer);
    _countryCtrl = TextEditingController(text: p.countryOfManufacture);
    _yearCtrl = TextEditingController(text: p.yearOfManufacture);
    _vaneCtrl = TextEditingController(text: p.vaneConfiguration);
    _rangeCtrl = TextEditingController(text: p.measurementRange);
    _matCtrl = TextEditingController(text: p.materials);
    _dimCtrl = TextEditingController(text: p.dimensionsAndWeight);
    _accCtrl = TextEditingController(text: p.includedAccessories);
    _markCtrl = TextEditingController(text: p.markingsAndStamps);
    _provCtrl = TextEditingController(text: p.provenance);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _idCtrl,
      _manCtrl,
      _countryCtrl,
      _yearCtrl,
      _vaneCtrl,
      _rangeCtrl,
      _matCtrl,
      _dimCtrl,
      _accCtrl,
      _markCtrl,
      _provCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pageTitles.length) return;
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _save() async {
    final p = ref.read(inputProvider);
    final bool missingId = p.atmosphericIdentifier.trim().isEmpty;
    final bool missingMan = p.manufacturer.trim().isEmpty;

    if (missingId || missingMan) {
      String errorMsg = 'Atmospheric Identifier and Manufacturer are required.';
      if (missingId && !missingMan) {
        errorMsg = 'Atmospheric Identifier is required.';
      } else if (!missingId && missingMan) {
        errorMsg = 'Manufacturer is required.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusSmall),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leadingWidth: 68.w,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSmall),
                  border: Border.all(color: kOutline, width: 1),
                ),
                child: Icon(Icons.close, color: kPrimaryText, size: 22.sp),
              ),
            ),
          ),
        ),
        title: Text(
          widget.isEdit ? 'Edit instrument' : 'Record instrument',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Page stepper indicator
                _buildStepperBar(),
                SizedBox(height: 8.h),
                // Paged form
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildPage1Identity(),
                      _buildPage2Mechanical(),
                      _buildPage3Physical(),
                      _buildPage4Provenance(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: List.generate(_pageTitles.length, (i) {
          final isActive = i == _currentPage;
          final isDone = i < _currentPage;
          return Expanded(
            child: GestureDetector(
              onTap: () => _goToPage(i),
              child: Column(
                children: [
                  Container(
                    height: 3.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: isActive
                          ? kAccent
                          : isDone
                          ? kAccent.withAlpha(60)
                          : kOutline,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _pageTitles[i],
                    style: GoogleFonts.inter(
                      color: isActive ? kAccent : kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1Identity() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(),
          SizedBox(height: 28.h),
          _sectionLabel('Registry Information'),
          SizedBox(height: 16.h),
          _field(
            label: 'Atmospheric Identifier',
            ctrl: _idCtrl,
            hint: 'e.g. TAA-BIRAM-1920-UK-084',
            onChanged: (v) => p.atmosphericIdentifier = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Manufacturer & Model',
            ctrl: _manCtrl,
            hint: 'e.g. Casella London, Short & Mason',
            onChanged: (v) => p.manufacturer = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Country of Manufacture',
            ctrl: _countryCtrl,
            hint: 'e.g. UK, USA, Germany',
            onChanged: (v) => p.countryOfManufacture = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Year of Manufacture',
            ctrl: _yearCtrl,
            hint: 'e.g. 1920',
            onChanged: (v) => p.yearOfManufacture = v,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}s?$')),
            ],
          ),
          SizedBox(height: 24.h),
          _sectionLabel('Instrument Type'),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: InstrumentType.values.map((t) {
              final isSel = p.instrumentType == t;
              return GestureDetector(
                onTap: () => p.instrumentType = t,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSel ? kAccent : kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    border: Border.all(
                      color: isSel ? kAccent : kOutline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: GoogleFonts.inter(
                      color: isSel ? Colors.white : kPrimaryText,
                      fontSize: 13.sp,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2Mechanical() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Vane & Fan Configuration'),
          SizedBox(height: 16.h),
          _field(
            label: 'Vane/Fan Configuration',
            ctrl: _vaneCtrl,
            hint: 'e.g. 4 aluminum vanes, brass frame, 76mm diameter',
            maxLines: 2,
            onChanged: (v) => p.vaneConfiguration = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Measurement Range',
            ctrl: _rangeCtrl,
            hint: 'e.g. 0–5,000 FPM',
            onChanged: (v) => p.measurementRange = v,
          ),
          SizedBox(height: 24.h),
          _sectionLabel('Movement Type'),
          SizedBox(height: 12.h),
          Column(
            children: MovementType.values.map((mv) {
              final isSel = p.movementType == mv;
              return GestureDetector(
                onTap: () => p.movementType = mv,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSel ? kAccentSurface : kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSmall),
                    border: Border.all(
                      color: isSel ? kAccent : kOutline,
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSel
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_off,
                        color: isSel ? kAccent : kSecondaryText.withAlpha(100),
                        size: 22.sp,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          mv.label,
                          style: GoogleFonts.inter(
                            color: isSel ? kPrimaryText : kSecondaryText,
                            fontSize: 14.sp,
                            fontWeight: isSel
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3Physical() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Materials & Dimensions'),
          SizedBox(height: 16.h),
          _field(
            label: 'Materials',
            ctrl: _matCtrl,
            hint: 'e.g. brass, nickel-plated steel, aluminum, glass',
            maxLines: 2,
            onChanged: (v) => p.materials = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Dimensions & Weight',
            ctrl: _dimCtrl,
            hint: 'e.g. 150mm × 80mm, 420g',
            maxLines: 2,
            onChanged: (v) => p.dimensionsAndWeight = v,
          ),
          SizedBox(height: 24.h),
          _sectionLabel('Condition State'),
          SizedBox(height: 12.h),
          Column(
            children: ConditionState.values.map((state) {
              final isSel = p.conditionState == state;
              return GestureDetector(
                onTap: () => p.conditionState = state,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSel ? kAccentSurface : kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSmall),
                    border: Border.all(
                      color: isSel ? kAccent : kOutline,
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSel
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_off,
                        color: isSel ? kAccent : kSecondaryText.withAlpha(100),
                        size: 22.sp,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          state.label,
                          style: GoogleFonts.inter(
                            color: isSel ? kPrimaryText : kSecondaryText,
                            fontSize: 14.sp,
                            fontWeight: isSel
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage4Provenance() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Archival Details'),
          SizedBox(height: 16.h),
          _field(
            label: 'Included Accessories',
            ctrl: _accCtrl,
            hint: 'e.g. wooden case, extension rods, calibration charts',
            maxLines: 2,
            onChanged: (v) => p.includedAccessories = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Markings & Stamps',
            ctrl: _markCtrl,
            hint: 'e.g. serial numbers, mine safety approval stamps',
            maxLines: 2,
            onChanged: (v) => p.markingsAndStamps = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Provenance',
            ctrl: _provCtrl,
            hint: 'e.g. Rhondda Colliery, Metropolitan Railway',
            maxLines: 3,
            onChanged: (v) => p.provenance = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Notes',
            ctrl: _notesCtrl,
            hint: 'Additional details about this instrument...',
            maxLines: 3,
            onChanged: (v) => p.notes = v,
          ),
          SizedBox(height: 18.h),
          _field(
            label: 'Tags (comma separated)',
            ctrl: _tagsCtrl,
            hint: 'brass, colliery, Biram...',
            onChanged: (v) => p.tags = v
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final imageProv = ref.watch(imageProvider);
    final displayPath = imageProv.getImagePath(imageProv.resultImage);

    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 220.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSmall),
          border: Border.all(color: kOutline, width: 1),
        ),
        child: displayPath != null && File(displayPath).existsSync()
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(displayPath), fit: BoxFit.cover),
                  Positioned(
                    bottom: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                      child: Text(
                        'Replace photo',
                        style: GoogleFonts.inter(
                          color: kPrimaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: kSecondaryText,
                    size: 32.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Upload instrument photograph',
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Vane assembly forward, dial face visible',
                    style: GoogleFonts.inter(
                      color: kSecondaryText.withAlpha(150),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        color: kPrimaryText,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          minLines: 1,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.inter(
            color: kPrimaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final isLastPage = _currentPage == _pageTitles.length - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: GestureDetector(
                onTap: () => _goToPage(_currentPage - 1),
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSmall),
                    border: Border.all(color: kOutline, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        color: kSecondaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: isLastPage ? _save : () => _goToPage(_currentPage + 1),
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(kRadiusSmall),
                ),
                child: Center(
                  child: Text(
                    isLastPage
                        ? (widget.isEdit ? 'Save edits' : 'Save record')
                        : 'Continue',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kRadiusSmall),
          border: Border.all(color: kOutline, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kAccent, strokeWidth: 3),
            SizedBox(height: 24.h),
            Text(
              'Cataloging instrument...',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: kPrimaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
