import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:my_kisan/accessories/sharedpref_helper.dart';
import 'package:my_kisan/models/place.dart';
import 'dart:convert' as convert;
import 'dart:core';
import 'package:my_kisan/models/place_Search.dart';
import 'package:my_kisan/screens/Cart_Screen.dart';

class PlaceService {
  final key = 'AIzaSyD8cl8ujWs6rfax-2SicJPXRL9cjfK4mic';

  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&radius=500&types=establishment&key=$key";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key";

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var jsonResults = json['result'] as Map<String, dynamic>;

    // CartScreen(Place.fromJson(jsonResults).geometry.location.lng,
    //     Place.fromJson(jsonResults).geometry.location.lat);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .update({
      "longitude": Place.fromJson(jsonResults).geometry.location.lng,
      "latitude": Place.fromJson(jsonResults)
          .geometry
          .location
          .lat, //applicationBloc.searchResults[index],
    });

    // Navigator.of(context).pop();

    return Place.fromJson(jsonResults);
  }
}
