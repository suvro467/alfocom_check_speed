import 'dart:io';

import 'package:alfocom_check_speed/data/datasource/remote/firebase_data_source.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

GetIt serviceLocator = GetIt.instance; // Inititate the service locator

// Call this method before runApp in main.
Future<void> setUp() async {
  /* final appPath =
      await getApplicationDocumentsDirectory().then((value) => value.path); */
  /* final FirebaseOptions firebaseOptions = (Platform.isIOS || Platform.isMacOS)
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
      app: app, bucket: 'gs://check-speed-firebase-project.appspot.com'); */

  serviceLocator
    ..registerLazySingleton<FirebaseDataSource>(() => FirebaseDataSourceImpl());
}
