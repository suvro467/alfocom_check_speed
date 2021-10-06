import 'dart:async';

import 'package:alfocom_check_speed/presentation/widgets/checkspeedmeter.dart';
import 'package:alfocom_check_speed/presentation/widgets/shared_container.dart';
import 'package:alfocom_check_speed/services/download_upload_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';

class SpeedTest extends StatefulWidget {
  final String title;
  final FirebaseStorage storage;
  final String appPath;
  SpeedTest({Key key, this.title, this.storage, this.appPath})
      : super(key: key);
  @override
  _SpeedTestState createState() => _SpeedTestState();
}

class _SpeedTestState extends State<SpeedTest> with TickerProviderStateMixin {
  DownloadUploadHelper downloadUploadHelper;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  double currentDowloadSpeed;

  double _lowerValue = 40.0;
  double _upperValue = 60.0;
  int start = 0;
  int end = 100;

  int counter = 0;
  Timer timer;

  PublishSubject<double> eventObservable;
  PublishSubject<bool> eventSpeedTestCompletion;
  CheckSpeedMeter checkSpeedMeter;
  ThemeData themeData;

  AnimationController _controllerRaisedButtonRestart;
  Animation<double> _animationRaisedButtonRestart;

  AnimationController _pingDecorationTweenController;
  AnimationController _downloadDecorationTweenController;
  AnimationController _uploadDecorationTweenController;

  AnimationController _pingSlideTransistionController;
  AnimationController _downloadSlideTransistionController;
  AnimationController _uploadSlideTransistionController;
  Animation<Offset> _pingOffsetAnimation;
  Animation<Offset> _downloadOffsetAnimation;
  Animation<Offset> _uploadOffsetAnimation;

  double pingInMilliSeconds = 0.0;
  double downloadSpeed = 0.0;
  double uploadSpeed = 0.0;
  dynamic result;

  bool isPingTestComplete = false;
  bool isDownloadTestComplete = false;
  bool isUploadTestComplete = false;

  double _downloadOpacity = 0.0;
  double _uploadOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    eventObservable = PublishSubject();
    eventSpeedTestCompletion = PublishSubject();
    themeData = ThemeData(
        primaryColor: Colors.amberAccent[100],
        accentColor: Colors.yellow[100],
        backgroundColor: Colors.black);
    downloadUploadHelper = DownloadUploadHelper(
        appPath: widget.appPath,
        storage: widget.storage,
        eventObservable: eventObservable,
        eventSpeedTestCompletion: eventSpeedTestCompletion);
    checkSpeedMeter = CheckSpeedMeter(
      start: start,
      end: end,
      highlightStart: (_lowerValue / end),
      highlightEnd: (_upperValue / end),
      themeData: themeData,
      eventObservable: this.eventObservable,
    );

    _pingSlideTransistionController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pingOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pingSlideTransistionController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _downloadSlideTransistionController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _downloadOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _downloadSlideTransistionController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _uploadSlideTransistionController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _uploadOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _uploadSlideTransistionController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _pingDecorationTweenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Start the animation in the initState() as this is the first test
    // which is being run.
    _pingDecorationTweenController.repeat(reverse: true);

    _pingDecorationTweenController.addListener(() {
      if (isPingTestComplete) {
        _pingDecorationTweenController
            .reverse()
            .whenComplete(() => _pingDecorationTweenController.stop());
      }
    });

    _downloadDecorationTweenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _downloadDecorationTweenController.addListener(() {
      if (isDownloadTestComplete) {
        _downloadDecorationTweenController
            .reverse()
            .whenComplete(() => _downloadDecorationTweenController.stop());
      }
    });

    _uploadDecorationTweenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _uploadDecorationTweenController.addListener(() {
      if (isUploadTestComplete) {
        _uploadDecorationTweenController
            .reverse()
            .whenComplete(() => _uploadDecorationTweenController.stop());
      }
    });

    // Reset the opacity value of the download widget
    _downloadOpacity = 0.0;
    // Reset the opacity value of the upload widget
    _uploadOpacity = 0.0;

    _controllerRaisedButtonRestart = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    ); //..repeat();
    _animationRaisedButtonRestart = CurvedAnimation(
      parent: _controllerRaisedButtonRestart,
      curve: Curves.bounceIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Call the methods to start speed test,
      // after speedtest.dart widget is loaded.

      try {
        _pingSlideTransistionController.forward();

        await downloadUploadHelper.getPing();

        if (this.mounted) {
          setState(() {
            pingInMilliSeconds = downloadUploadHelper.pingInMilliSeconds ?? 0.0;
            isPingTestComplete =
                downloadUploadHelper.isPingTestComplete ? true : false;
            _downloadOpacity = 1.0;
          });
        }

        // After ping test is complete, start the download animation controller.
        if (isPingTestComplete)
          _downloadDecorationTweenController.repeat(reverse: true);

        _downloadSlideTransistionController.forward();

        await downloadUploadHelper.getDownloadSpeed();

        // Show the speeds on the screen, after the speed test is completed.
        if (this.mounted) {
          setState(() {
            _uploadOpacity = 1.0;
            downloadSpeed = downloadUploadHelper.downloadSpeed ?? 0.0;
            isDownloadTestComplete =
                downloadUploadHelper.isDownloadTestComplete ? true : false;
          });
        }

        // After download test is complete, start the upload animation controller.
        if (isDownloadTestComplete)
          _uploadDecorationTweenController.repeat(reverse: true);

        _uploadSlideTransistionController.forward();

        await downloadUploadHelper.getUploadSpeed();

        if (this.mounted) {
          setState(() {
            uploadSpeed = downloadUploadHelper.uploadSpeed ?? 0.0;
            isUploadTestComplete =
                downloadUploadHelper.isUploadTestComplete ? true : false;
          });
        }
      } on Exception catch (e) {
        setState(() {
          pingInMilliSeconds = 0.0;
          downloadSpeed = 0.0;
          uploadSpeed = 0.0;
          isPingTestComplete = true;
          isDownloadTestComplete = true;
          isUploadTestComplete = true;
        });
        print('Exception caught: $e');
      }

      print('#############   Inside speedtest.dart...........');
      print('pingInMilliSeconds : $pingInMilliSeconds');
      print('downloadSpeed : $downloadSpeed');
      print('uploadSpeed : $uploadSpeed');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isUploadTestComplete) _controllerRaisedButtonRestart.forward();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Check Speed',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.yellow[100],
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.cyan[900]]),
            ),
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(135.0, 20.0, 0.0, 10.0),
                    child: SizeTransition(
                      sizeFactor: _animationRaisedButtonRestart,
                      axisAlignment: -1.0,
                      child: RaisedButton(
                        color: Colors.yellow[100],
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45.0),
                          side: BorderSide(color: Colors.teal),
                        ),
                        onPressed: () async {
                          try {
                            if (!isUploadTestComplete) return;

                            setState(() {
                              isPingTestComplete = false;
                              isDownloadTestComplete = false;
                              isUploadTestComplete = false;
                              downloadUploadHelper = DownloadUploadHelper(
                                  appPath: widget.appPath,
                                  storage: widget.storage,
                                  eventObservable: eventObservable,
                                  eventSpeedTestCompletion:
                                      eventSpeedTestCompletion);
                              pingInMilliSeconds = 0.0;
                              downloadSpeed = 0.0;
                              uploadSpeed = 0.0;

                              // Hide the restart button after tapping on it.
                              _controllerRaisedButtonRestart.reverse();

                              // Reset the opacity value of the download widget
                              _downloadOpacity = 0.0;
                              // Reset the opacity value of the upload widget
                              _uploadOpacity = 0.0;
                            });

                            _pingDecorationTweenController.repeat(
                                reverse: true);

                            _pingSlideTransistionController.reset();
                            _pingSlideTransistionController.forward();

                            await downloadUploadHelper.getPing();

                            setState(() {
                              pingInMilliSeconds =
                                  downloadUploadHelper.pingInMilliSeconds ??
                                      0.0;
                              isPingTestComplete =
                                  downloadUploadHelper.isPingTestComplete
                                      ? true
                                      : false;
                              _downloadOpacity = 1.0;
                            });

                            if (isPingTestComplete) {
                              _downloadDecorationTweenController.repeat(
                                  reverse: true);
                            }

                            _downloadSlideTransistionController.reset();
                            _downloadSlideTransistionController.forward();

                            await downloadUploadHelper.getDownloadSpeed();

                            setState(() {
                              downloadSpeed =
                                  downloadUploadHelper.downloadSpeed ?? 0.0;
                              isDownloadTestComplete =
                                  downloadUploadHelper.isDownloadTestComplete
                                      ? true
                                      : false;
                              _uploadOpacity = 1.0;
                            });

                            if (isDownloadTestComplete) {
                              _uploadDecorationTweenController.repeat(
                                  reverse: true);
                            }

                            _uploadSlideTransistionController.reset();
                            _uploadSlideTransistionController.forward();

                            await downloadUploadHelper.getUploadSpeed();

                            setState(() {
                              uploadSpeed =
                                  downloadUploadHelper.uploadSpeed ?? 0.0;
                              isUploadTestComplete =
                                  downloadUploadHelper.isUploadTestComplete
                                      ? true
                                      : false;
                            });
                          } on Exception catch (e) {
                            setState(() {
                              pingInMilliSeconds = 0.0;
                              downloadSpeed = 0.0;
                              uploadSpeed = 0.0;
                              isPingTestComplete = true;
                              isDownloadTestComplete = true;
                              isUploadTestComplete = true;
                            });
                          }
                        },
                        child: Text(
                          'Restart',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40.0, 60.0, 40.0, 0),
                    child: Container(
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.circle,
                      //   gradient: LinearGradient(
                      //       begin: Alignment.topRight,
                      //       end: Alignment.bottomLeft,
                      //       colors: [Colors.blue, Colors.yellow]),
                      // ),
                      child: checkSpeedMeter,
                      height: 275,
                      width: 275,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isUploadTestComplete
                        ? Text(
                            'Speed Test Results.',
                            style: TextStyle(
                              color: Colors.yellow[100],
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        // : SpinKitFadingCircle(
                        //     itemBuilder: (BuildContext context, int index) {
                        //       return DecoratedBox(
                        //         decoration: BoxDecoration(
                        //           shape: BoxShape.circle,
                        //           color: index.isEven
                        //               ? Colors.yellow[100]
                        //               : Colors.amber,
                        //         ),
                        //       );
                        //     },
                        //   ),
                        : SpinKitDualRing(
                            color: Colors.yellow[100],
                            size: 50.0,
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SlideTransition(
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(milliseconds: 500),
                            child: SharedContainer(
                              containerText:
                                  'Ping:\n${pingInMilliSeconds.toStringAsFixed(2)} ms',
                              controller: _pingDecorationTweenController,
                            ),
                          ),
                          position: _pingOffsetAnimation,
                        ),
                        SlideTransition(
                          child: AnimatedOpacity(
                            opacity: _downloadOpacity,
                            duration: Duration(seconds: 1),
                            child: SharedContainer(
                              containerText:
                                  'Download Speed:\n${downloadSpeed.toStringAsFixed(2)} Mbps',
                              controller: _downloadDecorationTweenController,
                            ),
                          ),
                          position: _downloadOffsetAnimation,
                        ),
                        SlideTransition(
                          child: AnimatedOpacity(
                            opacity: _uploadOpacity,
                            duration: Duration(seconds: 1),
                            child: SharedContainer(
                              containerText:
                                  'Upload Speed:\n${uploadSpeed.toStringAsFixed(2)} Mbps',
                              controller: _uploadDecorationTweenController,
                            ),
                          ),
                          position: _uploadOffsetAnimation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    eventObservable.close();
    eventSpeedTestCompletion.close();
    _pingDecorationTweenController.dispose();
    _downloadDecorationTweenController.dispose();
    _uploadDecorationTweenController.dispose();
    _controllerRaisedButtonRestart.dispose();
    _pingSlideTransistionController.dispose();
    _downloadSlideTransistionController.dispose();
    _uploadSlideTransistionController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    downloadUploadHelper.cleanup();
    Navigator.pop(context);
    return true;
  }
}
