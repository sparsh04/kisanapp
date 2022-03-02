import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_kisan/bloc/application_bloc.dart';
import 'package:my_kisan/models/place.dart';
import 'package:my_kisan/screens/Cart_Screen.dart';
import 'package:provider/provider.dart';

class LocationService extends StatefulWidget {
  var latitude, longitude;
  LocationService(this.latitude, this.longitude);

  @override
  _LocationServiceState createState() => _LocationServiceState();
}

class _LocationServiceState extends State<LocationService> {
  Completer<GoogleMapController> _mapcontroller = Completer();
  TextEditingController maptextsearch = TextEditingController();
  var locationsubscription;
  // StreamSubscription locationsubscription = StreamSubscription;
  @override
  void initState() {
    // TODO: implement initState
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    locationsubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _goToPlace(place);
        print(place);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    locationsubscription.cancel();
    locationsubscription.dispose();
    applicationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      body: (applicationBloc.currentLocation == null)
          ? Center(
              child: Container(),
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      controller: maptextsearch,
                      decoration: InputDecoration(
                        hintText: 'Search Location',
                        // icon: IconButton(
                        //   icon: Icon(Icons.done),
                        //   onPressed: () {
                        //     applicationBloc.searchPlaces(maptextsearch.text);
                        //   },
                        // ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CartScreen()));
                          },
                        ),
                      ),
                      onChanged: (value) {
                        if (maptextsearch.text.length > 2)
                          applicationBloc.searchPlaces(value);
                      }),
                ),
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                applicationBloc.currentLocation!.latitude,
                                applicationBloc.currentLocation!.longitude),
                            zoom: 50),
                        onMapCreated: (GoogleMapController controller) {
                          _mapcontroller.complete(controller);
                        },
                      ),
                    ),
                    if (applicationBloc.searchResults != null &&
                        applicationBloc.searchResults.length != 0)
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.6),
                            backgroundBlendMode: BlendMode.darken),
                      ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: applicationBloc.searchResults.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              applicationBloc.searchResults[index].description,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () async {
                              applicationBloc.setSelectedLocation(
                                  applicationBloc.searchResults[index].placeId);

                              //   applicationBloc.currentLocation![index].latitude,
                              // "latitude":
                              //     applicationBloc.currentLocation!.latitude,

                              FocusScope.of(context).unfocus();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapcontroller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 14.0)));
  }
}
