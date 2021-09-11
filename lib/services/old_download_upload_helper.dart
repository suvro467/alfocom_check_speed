// // Download file from Firebase Cloud Storage
//   Future<int> downloadFileFromFirebaseStorage() async {
//     StorageReference storageRef =
//         storage.ref().child('Images').child("Image1.png");
//     final String url = await storageRef.getDownloadURL();
//     print('Download Url: $url.');
//     //var response = await http.get(url);

//     var client = http.Client();
//     http.StreamedResponse streamedResponse =
//         await client.send(http.Request("GET", Uri.parse(url)));
//     var received = 0;
//     length = streamedResponse.contentLength;

//     // Commenting out the temporary directory for future use.
//     //final Directory systemTempDir = Directory.systemTemp;
//     final File tempFile = File('$appPath/Image1.png');
//     if (tempFile.existsSync()) {
//       await tempFile.delete();
//     }
//     //await tempFile.create();
//     var sink = tempFile.openWrite();

//     var previousReceived = 0;
//     var currentReceived = 0;

//     var previousTime = DateTime.now();
//     var currentTime = DateTime.now();
//     await streamedResponse.stream.map((s) {
//       received += s.length;
//       //print('"${(received / length) * 100} %"');
//       currentTime = DateTime.now();
//       if (currentTime.difference(previousTime).inMilliseconds >= 1000) {
//         previousTime = currentTime;
//         previousReceived = currentReceived;
//         currentReceived = received;

//         currentDownloadSpeed =
//             (currentReceived - previousReceived) / 1000 / 125;
//         // print(
//         //     'Percentage : ${(received / length) * 100} %, Speed : ${(currentReceived - previousReceived) / 1000} KB/s.');
//       }

//       return s;
//     }).pipe(sink);
//     await sink.close();
//     return length;
//   }

//   Future<int> uploadFileToFirebaseStorage() async {
//     final String uuid = Uuid().v1();
//     final appDir = getApplicationDocumentsDirectory();
//     appPath = await appDir.then((value) => value.path);
//     final File file = await File('$appPath/Image1.png').create();
//     var length = await file.length();
//     final StorageReference ref =
//         storage.ref().child('Images').child('$uuid.png');

//     uploadTask = ref.putFile(
//       file,
//       StorageMetadata(
//         contentLanguage: 'en',
//         customMetadata: <String, String>{'activity': 'test'},
//       ),
//     );

//     var previousReceived = 0;
//     var currentReceived = 0;

//     var previousTime = DateTime.now();
//     var currentTime = DateTime.now();
//     uploadTask.events.listen((event) {
//       print('Inside event: ${event.snapshot.bytesTransferred}');
//     }).onData((data) {
//       currentTime = DateTime.now();
//       if (currentTime.difference(previousTime).inMilliseconds >= 1000 &&
//           currentReceived < data.snapshot.bytesTransferred) {
//         previousTime = currentTime;
//         previousReceived = currentReceived;
//         currentReceived = data.snapshot.bytesTransferred;
//       }

//       currentUploadSpeed = (currentReceived - previousReceived) / 1000 / 125;

//       print(
//           'Percentage : ${(currentReceived / length) * 100} %, Speed : ${(currentReceived - previousReceived) / 1000 / 125} Mb/s.');
//     });

//     var bytesUploaded =
//         (await uploadTask.onComplete).totalByteCount; //.totalByteCount;

//     // Now need to delete the file from firebase storage to manage disk space
//     try {
//       await ref.delete();
//       print('Successfully deleted the uploaded image.');
//     } catch (error) {
//       print(error);
//     }

//     return bytesUploaded;
//   }
