import 'dart:io';

import 'package:alfocom_check_speed/screens/speedtest.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:alfocom_check_speed/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appPath =
      await getApplicationDocumentsDirectory().then((value) => value.path);
  final FirebaseOptions firebaseOptions = (Platform.isIOS || Platform.isMacOS)
      ? const FirebaseOptions(
          appId: '1:43629338758:android:372c6ad4c9d0ec2e907107',
          messagingSenderId: '43629338758',
          apiKey: 'AIzaSyBzMYd-4Als79zM7kOZ5ygxB4qlaPEvqDg',
          projectId: 'check-speed-firebase-project',
        )
      : const FirebaseOptions(
          appId: '1:43629338758:android:372c6ad4c9d0ec2e907107',
          messagingSenderId: '43629338758',
          apiKey: 'AIzaSyBzMYd-4Als79zM7kOZ5ygxB4qlaPEvqDg',
          projectId: 'check-speed-firebase-project',
        );
  FirebaseApp app;
  try {
    app = await Firebase.initializeApp(
        name: 'Check Speed', options: firebaseOptions);
  } catch (error) {
    print('App is already registered, ignoring the exception.');
  }
  FirebaseStorage storage = FirebaseStorage.instanceFor(
      app: app, bucket: 'gs://check-speed-firebase-project.appspot.com');
  runApp(MyApp(storage: storage, appPath: appPath));
}

class MyApp extends StatelessWidget {
  MyApp({this.storage, this.appPath});
  final FirebaseStorage storage;
  final String appPath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => DefaultTabController(
              length: 2,
              child: HomePage(storage: storage, appPath: appPath),
            ), // HomePage(storage: storage, appPath: appPath),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/speedtest': (context) => SpeedTest(
              title: 'Check Speed',
              storage: storage,
              appPath: appPath,
            ),
      },
      title: 'Check Speed',
      //home: HomePage(storage: storage, appPath: appPath),
    );
  }
}
