import 'dart:io';
import 'dart:async';
import 'package:alfocom_check_speed/services/database_helpers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:easyping/easyping.dart';
import 'package:flutter/material.dart';

class DownloadUploadHelper {
  final FirebaseStorage storage;
  final String uuid = Uuid().v1();
  final GlobalKey<ScaffoldState> scaffoldKey;
  PublishSubject<double> eventObservable;
  PublishSubject<bool> eventSpeedTestCompletion;
  StreamSubscription<StorageTaskEvent> uploadStreamSubscription;
  StreamSubscription<bool> subscriptionEventSpeedTestCompletion;
  StorageUploadTask uploadTask;
  String appPath;
  var length;

  double currentDownloadSpeed;
  double currentUploadSpeed;

  var pingInMilliSeconds;
  var downloadSpeed;
  var uploadSpeed;

  var downloadStartTime;
  var downloadEndTime;

  var uploadStartTime;
  var uploadEndTime;

  bool isPingTestComplete = false;
  bool isDownloadTestComplete = false;
  bool isUploadTestComplete = false;

  DownloadUploadHelper(
      {this.storage,
      this.appPath,
      this.scaffoldKey,
      this.eventObservable,
      this.eventSpeedTestCompletion});

  Future getPing() async {
    subscriptionEventSpeedTestCompletion =
        eventSpeedTestCompletion.listen((value) {
      isUploadTestComplete = value;
    });
    isUploadTestComplete = false;
    eventSpeedTestCompletion.add(isUploadTestComplete);
    // Ping test.
    String address = '8.8.8.8';
    pingInMilliSeconds = await ping(address);
    isPingTestComplete = true;
  }

  Future getDownloadSpeed() async {
    var previousReceived = 0;
    var currentReceived = 0;

    var previousTime = DateTime.now();
    var currentTime = DateTime.now();

    var received = 0;
    var currentDownloadSpeed = 0.0;

    StorageReference storageRef =
        storage.ref().child('Images').child("Image1.png");
    final String url = await storageRef.getDownloadURL();
    print('Download Url: $url.');
    //var response = await http.get(url);

    var downloadClient = http.Client();
    http.StreamedResponse streamedResponse =
        await downloadClient.send(http.Request("GET", Uri.parse(url)));
    //var length = streamedResponse.contentLength;

    // Commenting out the temporary directory for future use.
    //final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('$appPath/Image1.png');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    var sink = tempFile.openWrite();

    var responseStream = streamedResponse.stream;
    var length = streamedResponse.contentLength;

    downloadStartTime = DateTime.now();

    var mappedStream = responseStream.map((s) {
      received += s.length;

      currentTime = DateTime.now();
      if (currentTime.difference(previousTime).inMilliseconds >= 500) {
        previousTime = currentTime;

        previousReceived = currentReceived;
        currentReceived = received;
        currentDownloadSpeed = ((currentReceived - previousReceived) /
                1000 /
                125) *
            2; // Multiplied by 2 since speed is calculated every half second.
        eventObservable.add(currentDownloadSpeed);
      }

      return s;
    });
    await mappedStream.pipe(sink).then((value) async {
      await sink.close();

      downloadEndTime = DateTime.now();
      downloadSpeed = (length / 1000 / 125) /
          downloadEndTime.difference(downloadStartTime).inSeconds;

      downloadClient.close();
      print('Download test is complete!');
      isDownloadTestComplete = true;
    }).catchError((onError) {
      print(
          'Unhandled Exception: Bad state: Cannot add new events after calling close');
      print('Navigating back to the home screen.');
      downloadClient.close();
    });
  }

  Future getUploadSpeed() async {
    final String uuid = Uuid().v1();
    final appDir = getApplicationDocumentsDirectory();
    appPath = await appDir.then((value) => value.path);
    final file = await File('$appPath/Image1.png').create();
    var length = await file.length();
    final StorageReference ref =
        storage.ref().child('Images').child('$uuid.png');

    uploadTask = ref.putData(
      file.readAsBytesSync(),
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    var previousReceived = 0;
    var currentReceived = 0;

    var previousTime = DateTime.now();
    var currentTime = DateTime.now();

    uploadStartTime = DateTime.now();

    uploadStreamSubscription = uploadTask.events.listen((event) {
      print('Inside event: ${event.snapshot.bytesTransferred}');
    });
    uploadStreamSubscription.onData((data) {
      previousTime = currentTime;
      currentTime = DateTime.now();
      var timeDifference = currentTime.difference(previousTime).inMilliseconds;

      previousReceived = currentReceived;
      currentReceived = data.snapshot.bytesTransferred;
      currentUploadSpeed =
          (((currentReceived - previousReceived) / 1000 / 125) /
                  timeDifference) *
              1000;

      if (eventObservable.hasListener && !eventObservable.isClosed) {
        if (currentUploadSpeed.toStringAsFixed(1) != 'NaN') {
          eventObservable.add(currentUploadSpeed);
        } else {
          eventObservable.add(0.0);
        }
      }

      print(
          'Percentage : ${(currentReceived / length) * 100} %, Speed : $currentUploadSpeed Mb/s.');
    });

    // To complete the upload process onComplete Future is called.
    await uploadTask.onComplete;

    uploadEndTime = DateTime.now();
    uploadSpeed = (length / 1000 / 125) /
        uploadEndTime.difference(uploadStartTime).inSeconds;

    await uploadStreamSubscription.cancel();

    print('Ping Test : $pingInMilliSeconds ms.');
    print('Download Speed is : $downloadSpeed Mb/s');
    print('Upload Speed is : $uploadSpeed Mb/s');
    // Now need to delete the file from firebase storage to manage disk space
    try {
      if (!uploadTask.isCanceled &&
          uploadTask.isComplete &&
          uploadTask.isSuccessful) await ref.delete();
      print('Successfully deleted the uploaded image.');
    } catch (error) {
      print(error);
    }

    //await eventObservable.close();

    // Change the flag of isSpeedTestComplete to true;
    isUploadTestComplete = true;
    if (eventSpeedTestCompletion.hasListener &&
        !eventSpeedTestCompletion.isClosed) {
      eventSpeedTestCompletion.add(isUploadTestComplete);
    }

    // Save the speed test to database
    if (eventSpeedTestCompletion.hasListener &&
        !eventSpeedTestCompletion.isClosed) {
      await _storeData(DateTime.now().toString(), pingInMilliSeconds,
          downloadSpeed, uploadSpeed);
    }

    // Close the subscription which checks for the completion of speed test.
    await subscriptionEventSpeedTestCompletion.cancel();
  }

  cleanup() {
    if (uploadTask != null &&
        (uploadTask.isInProgress || !uploadTask.isComplete))
      uploadTask.cancel();
    if (uploadStreamSubscription != null) uploadStreamSubscription.cancel();
    if (subscriptionEventSpeedTestCompletion != null)
      subscriptionEventSpeedTestCompletion.cancel();
  }

  Future _storeData(String dateTime, double pingInMilliSeconds,
      double downloadSpeed, double uploadSpeed) async {
    SpeedHistory speedHistory = SpeedHistory();
    speedHistory.dateTime = DateTime.now().toString();
    speedHistory.pingInMilliseconds = pingInMilliSeconds;
    speedHistory.downloadSpeed = downloadSpeed;
    speedHistory.uploadSpeed = uploadSpeed;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(speedHistory);
    print('inserted row: $id');
  }
}
