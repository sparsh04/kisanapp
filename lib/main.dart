// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_kisan/accessories/local_notification_service.dart';
import 'package:my_kisan/bloc/application_bloc.dart';
import 'dart:core';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/routes.dart';
import 'package:my_kisan/screens/Login_Screen.dart';
import 'package:my_kisan/screens/Splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNOtificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //  final applicationBloc = Provider.of<ApplicationBloc>(context);
    return ChangeNotifierProvider(
      create: (context) => ApplicationBloc(),
      child: MaterialApp(
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                color: greencolor,
                centerTitle: true,
                systemOverlayStyle:
                    SystemUiOverlayStyle(statusBarColor: greencolor))),
        routes: routes,
        debugShowCheckedModeBanner: false,
        title: 'My Kisan',
        home: SplashScreen(),
      ),
    );
  }
}
