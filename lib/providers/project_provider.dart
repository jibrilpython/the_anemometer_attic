import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_anemometer_attic/models/project_model.dart';
import 'package:the_anemometer_attic/providers/image_provider.dart';
import 'package:the_anemometer_attic/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<VentilationInstrumentModel> entries = [];
  bool isLoading = true;
  static const String _storageKey = 'taa_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => VentilationInstrumentModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    entries.add(
      VentilationInstrumentModel(
        id: _uuid.v4(),
        atmosphericIdentifier: p.atmosphericIdentifier,
        instrumentType: p.instrumentType,
        manufacturer: p.manufacturer,
        countryOfManufacture: p.countryOfManufacture,
        yearOfManufacture: p.yearOfManufacture,
        vaneConfiguration: p.vaneConfiguration,
        measurementRange: p.measurementRange,
        movementType: p.movementType,
        materials: p.materials,
        dimensionsAndWeight: p.dimensionsAndWeight,
        conditionState: p.conditionState,
        includedAccessories: p.includedAccessories,
        markingsAndStamps: p.markingsAndStamps,
        provenance: p.provenance,
        notes: p.notes,
        photoPath: imgProv.resultImage.isNotEmpty
            ? imgProv.resultImage
            : p.photoPath,
        tags: List<String>.from(p.tags),
        dateAdded: p.dateAdded,
      ),
    );

    _save();
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    entries[index] = VentilationInstrumentModel(
      id: existing.id,
      atmosphericIdentifier: p.atmosphericIdentifier,
      instrumentType: p.instrumentType,
      manufacturer: p.manufacturer,
      countryOfManufacture: p.countryOfManufacture,
      yearOfManufacture: p.yearOfManufacture,
      vaneConfiguration: p.vaneConfiguration,
      measurementRange: p.measurementRange,
      movementType: p.movementType,
      materials: p.materials,
      dimensionsAndWeight: p.dimensionsAndWeight,
      conditionState: p.conditionState,
      includedAccessories: p.includedAccessories,
      markingsAndStamps: p.markingsAndStamps,
      provenance: p.provenance,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    _save();
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    _save();
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.atmosphericIdentifier = entry.atmosphericIdentifier;
    p.instrumentType = entry.instrumentType;
    p.manufacturer = entry.manufacturer;
    p.countryOfManufacture = entry.countryOfManufacture;
    p.yearOfManufacture = entry.yearOfManufacture;
    p.vaneConfiguration = entry.vaneConfiguration;
    p.measurementRange = entry.measurementRange;
    p.movementType = entry.movementType;
    p.materials = entry.materials;
    p.dimensionsAndWeight = entry.dimensionsAndWeight;
    p.conditionState = entry.conditionState;
    p.includedAccessories = entry.includedAccessories;
    p.markingsAndStamps = entry.markingsAndStamps;
    p.provenance = entry.provenance;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
