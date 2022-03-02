import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class TrackOrder extends StatefulWidget {
  //const TrackOrder({Key? key}) : super(key: key);
  var map;
  TrackOrder(this.map);

  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  Set<Polyline> _polyline = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polylinePoints;
  LatLng? DEST_Location, SOURCE_DESTINATION;

  @override
  void initState() {
    DEST_Location = LatLng(widget.map['driverlat'], widget.map['driverlong']);
    SOURCE_DESTINATION =
        LatLng(widget.map['latitude'], widget.map['longitude']);
    polylinePoints = PolylinePoints();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    super.initState();
    _requestPermisiion();
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(snapshot.data!.docs[0]['driverlat'],
          snapshot.data!.docs[0]['driverlong']),
      zoom: 14.47,
    )));
  }

  _requestPermisiion() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Done');
    } else if (status.isDenied) {
      _requestPermisiion();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking Order"),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 700,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 20, bottom: 20),
                child: Text(
                  "Track your Order",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              widget.map['status'] == "preparing"
                  ?

                  // widget.map['status'] != "Accepted"
                  Track(
                      text: 'A delivery agent will be assigned to you shortly',
                      done: true,
                    )
                  : Container(),

              // Divider(),
              widget.map['status'] == "Accepted"
                  ? Container(
                      height: 300,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Orders")
                            .where("orderid", isEqualTo: widget.map['orderid'])
                            // .doc(widget.map['orderid'])
                            .snapshots(),
                        //   initialData: initialData,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          // print("abcd");
                          // print(snapshot.data.docs[0]['amount']);
                          mymap(snapshot);

                          if (!snapshot.hasData) {
                            return Container();
                          }
                          // return Container();
                          return GoogleMap(
                            polylines: _polyline,
                            mapType: MapType.normal,
                            markers: {
                              Marker(
                                position: LatLng(
                                    snapshot.data!.docs[0]['driverlat'],
                                    snapshot.data!.docs[0]['driverlong']),
                                markerId: MarkerId('id'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueMagenta),
                              ),
                            },
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  snapshot.data!.docs[0]['driverlat'],
                                  snapshot.data!.docs[0]['driverlong']),
                              zoom: 14.47,
                            ),
                            onMapCreated:
                                (GoogleMapController controller) async {
                              _controller = controller;
                              _added = true;
                              setPolyline();
                            },
                          );
                        },
                      ),
                    )
                  : Container(),

              "Done" == widget.map['status']
                  ? Track(
                      text: 'Order Delivered',
                      done: true,
                    )
                  : Container(),

              widget.map['status'] != "Done" &&
                      widget.map['status'] != "Accepted" &&
                      widget.map['status'] != "preparing"
                  ? Track(
                      text: 'On the Way',
                      done: true,
                    )
                  : Container(),

              widget.map['deliveredby'] != ''
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                                "+${int.parse(widget.map['deliveredby'])}"),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              // Track(
              //   text: 'Order Accepted',
              //   done: true,
              // ),
              // Divider(),
              // Track(
              //   text: 'Order Dispatched',
              //   done: false,
              // ),
              // Divider(),
              // Track(
              //   text: 'Order Delivered',
              //   done: false,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void setPolyline() async {
    PolylineResult result = await polylinePoints!.getRouteBetweenCoordinates(
        "AIzaSyD8cl8ujWs6rfax-2SicJPXRL9cjfK4mic",
        PointLatLng(
            SOURCE_DESTINATION!.latitude, SOURCE_DESTINATION!.longitude),
        PointLatLng(DEST_Location!.latitude, DEST_Location!.longitude));

    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polyline.add(
          Polyline(
              polylineId: PolylineId('polyLine'),
              width: 10,
              color: Color(0xFF08A5CB),
              points: polylineCoordinates),
        );
      });
    }
  }
}

class Track extends StatelessWidget {
  final String text;
  final bool done;
  const Track({
    Key? key,
    required this.text,
    required this.done,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 5, 0, 0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: done ? Colors.green : Colors.grey,
            radius: 11,
            child: Icon(Icons.check, size: 18, color: Colors.white),
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}

class Divider extends StatelessWidget {
  const Divider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Row(
        children: [
          Container(
            height: 25,
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
            child: VerticalDivider(
              color: Colors.grey,
              thickness: 5,
            ),
          ),
        ],
      ),
    );
  }
}
