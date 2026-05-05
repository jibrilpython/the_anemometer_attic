import 'package:the_anemometer_attic/enum/my_enums.dart';

class VentilationInstrumentModel {
  String id;
  String atmosphericIdentifier;
  InstrumentType instrumentType;
  String manufacturer;
  String countryOfManufacture;
  String yearOfManufacture;
  String vaneConfiguration;
  String measurementRange;
  MovementType movementType;
  String materials;
  String dimensionsAndWeight;
  ConditionState conditionState;
  String includedAccessories;
  String markingsAndStamps;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  VentilationInstrumentModel({
    required this.id,
    required this.atmosphericIdentifier,
    required this.instrumentType,
    required this.manufacturer,
    required this.countryOfManufacture,
    required this.yearOfManufacture,
    required this.vaneConfiguration,
    required this.measurementRange,
    required this.movementType,
    required this.materials,
    required this.dimensionsAndWeight,
    required this.conditionState,
    required this.includedAccessories,
    required this.markingsAndStamps,
    required this.provenance,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'atmosphericIdentifier': atmosphericIdentifier,
        'instrumentType': instrumentType.name,
        'manufacturer': manufacturer,
        'countryOfManufacture': countryOfManufacture,
        'yearOfManufacture': yearOfManufacture,
        'vaneConfiguration': vaneConfiguration,
        'measurementRange': measurementRange,
        'movementType': movementType.name,
        'materials': materials,
        'dimensionsAndWeight': dimensionsAndWeight,
        'conditionState': conditionState.name,
        'includedAccessories': includedAccessories,
        'markingsAndStamps': markingsAndStamps,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory VentilationInstrumentModel.fromJson(Map<String, dynamic> json) =>
      VentilationInstrumentModel(
        id: json['id'] ?? '',
        atmosphericIdentifier: json['atmosphericIdentifier'] ?? '',
        instrumentType: InstrumentType.values.asNameMap()[json['instrumentType']] ?? InstrumentType.other,
        manufacturer: json['manufacturer'] ?? '',
        countryOfManufacture: json['countryOfManufacture'] ?? '',
        yearOfManufacture: json['yearOfManufacture'] ?? '',
        vaneConfiguration: json['vaneConfiguration'] ?? '',
        measurementRange: json['measurementRange'] ?? '',
        movementType: MovementType.values.asNameMap()[json['movementType']] ?? MovementType.unknown,
        materials: json['materials'] ?? '',
        dimensionsAndWeight: json['dimensionsAndWeight'] ?? '',
        conditionState: ConditionState.values.asNameMap()[json['conditionState']] ?? ConditionState.unknown,
        includedAccessories: json['includedAccessories'] ?? '',
        markingsAndStamps: json['markingsAndStamps'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
