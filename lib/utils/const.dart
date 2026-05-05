import 'package:flutter/material.dart';
import 'package:the_anemometer_attic/enum/my_enums.dart';

// ─── COLOR PALETTE — "Shaft & Surface" ─────────────────────────────────────
const Color kBackground    = Color(0xFFF3F4F6); // Ventilation grey
const Color kPrimaryText   = Color(0xFF111827); // Shaft black
const Color kPanelBg       = Color(0xFFFFFFFF); // White card surfaces
const Color kSecondaryText = Color(0xFF6B7280); // Muted labels
const Color kAccent        = Color(0xFF0F766E); // Mine teal — oxidized copper vanes
const Color kOutline       = Color(0xFFE5E7EB); // Stroke / dividers
const Color kAccentAmber   = Color(0xFF92400E); // Instrument amber — mahogany / ivory
const Color kError         = Color(0xFFDC2626); // Critical errors

// ─── DERIVED COLORS ────────────────────────────────────────────────────────
const Color kAccentLight   = Color(0xFF14B8A6); // Lighter teal
const Color kAccentSurface = Color(0xFFF0FDFB); // Teal at 10% opacity fill
const Color kGlassBackground = Color(0xB3FFFFFF); // 70% White for frosted glass
const Color kSuccess       = Color(0xFF059669);
const Color kWarning       = Color(0xFFD97706);

// ─── SPACING ───────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS ─────────────────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusSmall    = 16.0; // Rounder card corners
const double kRadiusSubtle   = 20.0;
const double kRadiusStandard = 28.0;
const double kRadiusMedium   = 36.0;
const double kRadiusLarge    = 48.0;
const double kRadiusXLarge   = 56.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ───────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -6,
  color: Color(0x0F111827),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 12),
  blurRadius: 32,
  spreadRadius: -8,
  color: Color(0x14000000),
);

const double kStrokeWeight        = 1.0;
const double kStrokeWeightMedium  = 1.5;

// ─── INSTRUMENT TYPE COLORS ────────────────────────────────────────────────
Color getInstrumentTypeColor(InstrumentType type) {
  switch (type) {
    case InstrumentType.fanAnemometer:
      return kAccent;
    case InstrumentType.biramAnemometer:
      return const Color(0xFF1E40AF); // Deep cobalt
    case InstrumentType.liquidManometer:
      return const Color(0xFF7C3AED); // Amethyst
    case InstrumentType.hygrometer:
      return const Color(0xFF059669); // Emerald
    case InstrumentType.barometer:
      return const Color(0xFFB45309); // Warm amber
    case InstrumentType.windSpeedMeter:
      return const Color(0xFF0369A1); // Sky
    case InstrumentType.other:
      return kSecondaryText;
  }
}

// ─── CONDITION COLORS ──────────────────────────────────────────────────────
Color getConditionColor(ConditionState state) {
  switch (state) {
    case ConditionState.operational:
      return kAccent;
    case ConditionState.displayOnly:
      return kAccentAmber;
    case ConditionState.vanesIntact:
      return const Color(0xFF0369A1);
    case ConditionState.damagedVanes:
      return kError;
    case ConditionState.unknown:
      return kSecondaryText;
  }
}

// ─── MOVEMENT TYPE COLORS ──────────────────────────────────────────────────
Color getMovementColor(MovementType type) {
  switch (type) {
    case MovementType.gearedTransmission:
      return kAccent;
    case MovementType.jeweledBearings:
      return const Color(0xFF7C3AED);
    case MovementType.frictionBrake:
      return kAccentAmber;
    case MovementType.springDriven:
      return const Color(0xFF059669);
    case MovementType.unknown:
      return kSecondaryText;
  }
}
