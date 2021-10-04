import 'dart:io';

import 'package:alfocom_check_speed/core/error/failures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseDataSource {
  Future<FirebaseStorage> getStorage();
}

class FirebaseDataSourceImpl extends FirebaseDataSource {
  Future<FirebaseStorage> getStorage() async {
    try {
      final FirebaseOptions firebaseOptions =
          (Platform.isIOS || Platform.isMacOS)
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

      return storage;
    } on FirebaseException catch (e) {
      throw ServerFailure(code: e.code, message: e.message);
    } on Exception catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
