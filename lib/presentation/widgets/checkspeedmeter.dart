import 'dart:async';
import 'dart:ui';

import 'package:alfocom_check_speed/presentation/widgets/handpainter.dart';
import 'package:alfocom_check_speed/presentation/widgets/linepainter.dart';
import 'package:alfocom_check_speed/presentation/widgets/speedtextpainter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class CheckSpeedMeter extends StatefulWidget {
  final int start;
  final int end;
  final double highlightStart;
  final double highlightEnd;
  final ThemeData themeData;

  final PublishSubject<double> eventObservable;

  CheckSpeedMeter(
      {this.start,
      this.end,
      this.highlightStart,
      this.highlightEnd,
      this.themeData,
      this.eventObservable}); // {}

  @override
  _CheckSpeedMeterState createState() => _CheckSpeedMeterState(this.start,
      this.end, this.highlightStart, this.highlightEnd, this.eventObservable);
}

class _CheckSpeedMeterState extends State<CheckSpeedMeter>
    with TickerProviderStateMixin {
  int start;
  int end;
  double highlightStart;
  double highlightEnd;
  PublishSubject<double> eventObservable;
  AnimationController percentageAnimationController;
  StreamSubscription<double> subscription;

  double val = 0.0;
  double newVal;
  double textVal = 0.0;

  _CheckSpeedMeterState(int start, int end, double highlightStart,
      double highlightEnd, PublishSubject<double> eventObservable) {
    this.start = start;
    this.end = end;
    this.highlightStart = highlightStart;
    this.highlightEnd = highlightEnd;
    this.eventObservable = eventObservable;

    this.percentageAnimationController = AnimationController(
      value: 0,
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..addListener(() {
        setState(() {
          val =
              lerpDouble(val, newVal, this.percentageAnimationController.value);
        });
      });
    this.subscription = this.eventObservable.listen((value) {
      textVal = value;
      (value >= this.end)
          ? reloadData(this.end.toDouble())
          : reloadData(value != double.nan ? value : 0.0);
    }); //(value) => reloadData(value));
  }

  reloadData(double value) {
    print(value);
    newVal = value;
    this.percentageAnimationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    subscription.cancel();
    percentageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context).isCurrent == false) {
      return Text("");
    }
    return Center(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          height: constraints.maxWidth,
          width: constraints.maxWidth,
          child: Stack(fit: StackFit.expand, children: <Widget>[
            Container(
              child: CustomPaint(
                  foregroundPainter: LinePainter(
                      lineColor: this.widget.themeData.backgroundColor,
                      completeColor: this.widget.themeData.primaryColor,
                      startValue: this.start,
                      endValue: this.end,
                      startPercent: this.widget.highlightStart,
                      endPercent: this.widget.highlightEnd,
                      width: 40.0)),
            ),
            Center(
                //   aspectRatio: 1.0,
                child: Container(
                    height: constraints.maxWidth,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(fit: StackFit.expand, children: <Widget>[
                      CustomPaint(
                        painter: HandPainter(
                            value: val,
                            start: this.start,
                            end: this.end,
                            color: this.widget.themeData.accentColor),
                      ),
                    ]))),
            Center(
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1.5, 1.5),
                      )
                    ],
                    shape: BoxShape.circle,
                    //color: this.widget.themeData.backgroundColor,
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.cyan[900], Colors.yellow[100]])),
              ),
            ),
            CustomPaint(
                painter: SpeedTextPainter(
                    start: this.start,
                    end: this.end,
                    value: this.textVal != double.nan ? this.textVal : 0.0)),
          ]),
        );
      }),
    );
  }
}
