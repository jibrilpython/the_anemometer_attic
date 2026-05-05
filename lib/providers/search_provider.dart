import 'package:the_anemometer_attic/models/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<VentilationInstrumentModel> filteredList(List<VentilationInstrumentModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.atmosphericIdentifier.toLowerCase().contains(query) ||
              item.manufacturer.toLowerCase().contains(query) ||
              item.countryOfManufacture.toLowerCase().contains(query) ||
              item.vaneConfiguration.toLowerCase().contains(query) ||
              item.materials.toLowerCase().contains(query) ||
              item.provenance.toLowerCase().contains(query) ||
              item.yearOfManufacture.toLowerCase().contains(query) ||
              item.measurementRange.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
