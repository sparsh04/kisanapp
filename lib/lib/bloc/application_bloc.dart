import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_kisan/models/place.dart';
import 'package:my_kisan/models/place_Search.dart';
import 'package:my_kisan/screens/geolocator_Service.dart';
import 'package:my_kisan/services/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geolocatorserive = GeolocatorService();
  final placeService = PlaceService();

  Position? currentLocation;
  List<PlaceSearch> searchResults = [];
  StreamController<Place> selectedLocation = StreamController<Place>();

  ApplicationBloc() {
    setCurrentLOcation();
  }

  setCurrentLOcation() async {
    currentLocation = await geolocatorserive.getCurrentLocation();
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placeService.getAutoComplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placeService.getPlace(placeId));
    searchResults = [];
    searchResults.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    selectedLocation.close();
    super.dispose();
  }
}
