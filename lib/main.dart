import 'dart:io';

import 'package:admin/branchRequestApprove_ARM.dart';
import 'package:admin/branchRequestApprove_RM.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/Homepage.dart';

import 'package:firebase_dart/firebase_dart.dart' as fd;
import 'package:firebase_dart_flutter/firebase_dart_flutter.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverride();

  // 1️⃣ Setup firebase_dart for Flutter
  await FirebaseDartFlutter.setup(isolated: false);

  // 2️⃣ Initialize Firebase DEFAULT app (firebase_core) with your FirebaseOptions
  await fd.Firebase.initializeApp(
    options: fd.FirebaseOptions(
      apiKey: DefaultFirebaseOptions.currentPlatform.apiKey,
      appId: DefaultFirebaseOptions.currentPlatform.appId,
      messagingSenderId:
          DefaultFirebaseOptions.currentPlatform.messagingSenderId,
      projectId: DefaultFirebaseOptions.currentPlatform.projectId,
      storageBucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
      authDomain: DefaultFirebaseOptions.currentPlatform.authDomain,
      measurementId: DefaultFirebaseOptions.currentPlatform.measurementId,
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
    ),
  );

  // ✅ Now you can safely run the app
  runApp(const MyApp());
}

class MyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      restorationScopeId: "Test",
      home: DashboardScreen(),
    );
  }
}
