import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:my_kisan/Component/bottom_bar.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/Login_Screen.dart';

void main() {
  runApp(SplashScreen());
}

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<SplashScreen> {
  final Location location = Location();
  PermissionStatus? _permissionGranted;
  Future<void> _checkPermissions() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestResult =
          await location.requestPermission();

      setState(() {
        _permissionGranted = permissionRequestResult;
      });
    }
  }

  String? currentuser;
  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _requestPermission();
    // startTime();
  }

  _onlaund() {
    Timer(Duration(seconds: 2), () async {
      try {
        currentuser = await FirebaseAuth.instance.currentUser!.uid;
        if (currentuser == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(),
              ),
              (route) => false);
        } else if (currentuser != null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => BottomBar(0),
              ),
              (route) => false);
        }
      } catch (e) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(),
            ),
            (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return initWidget(context);
  }

  Widget initWidget(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _onlaund(),
          builder: (context, snapshot) {
            return Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(),
                    child: SvgPicture.asset("assets/icons/logo.svg"),
                  ),
                ),
                Container(child: Text("       Vegetables And Fruits",style: TextStyle(color: greencolor,fontSize: 20,fontWeight: FontWeight.bold),),),

              ],
            );
          }),
    );
  }
}
