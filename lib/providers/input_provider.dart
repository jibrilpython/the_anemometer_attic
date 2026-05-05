import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_anemometer_attic/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _atmosphericIdentifier = '';
  InstrumentType _instrumentType = InstrumentType.fanAnemometer;
  String _manufacturer = '';
  String _countryOfManufacture = '';
  String _yearOfManufacture = '';
  String _vaneConfiguration = '';
  String _measurementRange = '';
  MovementType _movementType = MovementType.unknown;
  String _materials = '';
  String _dimensionsAndWeight = '';
  ConditionState _conditionState = ConditionState.unknown;
  String _includedAccessories = '';
  String _markingsAndStamps = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get atmosphericIdentifier => _atmosphericIdentifier;
  InstrumentType get instrumentType => _instrumentType;
  String get manufacturer => _manufacturer;
  String get countryOfManufacture => _countryOfManufacture;
  String get yearOfManufacture => _yearOfManufacture;
  String get vaneConfiguration => _vaneConfiguration;
  String get measurementRange => _measurementRange;
  MovementType get movementType => _movementType;
  String get materials => _materials;
  String get dimensionsAndWeight => _dimensionsAndWeight;
  ConditionState get conditionState => _conditionState;
  String get includedAccessories => _includedAccessories;
  String get markingsAndStamps => _markingsAndStamps;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set atmosphericIdentifier(String v) { _atmosphericIdentifier = v; notifyListeners(); }
  set instrumentType(InstrumentType v) { _instrumentType = v; notifyListeners(); }
  set manufacturer(String v) { _manufacturer = v; notifyListeners(); }
  set countryOfManufacture(String v) { _countryOfManufacture = v; notifyListeners(); }
  set yearOfManufacture(String v) { _yearOfManufacture = v; notifyListeners(); }
  set vaneConfiguration(String v) { _vaneConfiguration = v; notifyListeners(); }
  set measurementRange(String v) { _measurementRange = v; notifyListeners(); }
  set movementType(MovementType v) { _movementType = v; notifyListeners(); }
  set materials(String v) { _materials = v; notifyListeners(); }
  set dimensionsAndWeight(String v) { _dimensionsAndWeight = v; notifyListeners(); }
  set conditionState(ConditionState v) { _conditionState = v; notifyListeners(); }
  set includedAccessories(String v) { _includedAccessories = v; notifyListeners(); }
  set markingsAndStamps(String v) { _markingsAndStamps = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _atmosphericIdentifier = '';
    _instrumentType = InstrumentType.fanAnemometer;
    _manufacturer = '';
    _countryOfManufacture = '';
    _yearOfManufacture = '';
    _vaneConfiguration = '';
    _measurementRange = '';
    _movementType = MovementType.unknown;
    _materials = '';
    _dimensionsAndWeight = '';
    _conditionState = ConditionState.unknown;
    _includedAccessories = '';
    _markingsAndStamps = '';
    _provenance = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
