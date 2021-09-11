import 'package:flutter/material.dart';

class SharedContainer extends StatelessWidget {
  final String containerText;
  final AnimationController controller;

  SharedContainer({this.containerText, this.controller});

  final DecorationTween decorationTween = DecorationTween(
    begin: BoxDecoration(
      border: Border.all(
        width: 1,
        color: Colors.black,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(50),
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(2, 0.0), // 10% of the width, so there are ten blinds.
        colors: [
          Colors.yellow[100],
          Colors.white,
          //Colors.yellow[100]
        ], // red to yellow
        tileMode: TileMode.repeated, // repeats the gradient over the canvas
      ),
    ),
    end: BoxDecoration(
      border: Border.all(
        width: 5,
        color: Colors.teal[800],
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(50),
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(2, 0.0), // 10% of the width, so there are ten blinds.
        colors: [
          // Colors.amber,
          // Colors.yellowAccent,
          // Colors.black
          Colors.white,
          Colors.red[200],
          Colors.white10
        ], // red to yellow
        tileMode: TileMode.mirror, // repeats the gradient over the canvas
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      position: DecorationPosition.background,
      decoration: decorationTween.animate(controller),
      child: Container(
        margin: EdgeInsets.all(10),
        width: 80,
        height: 80,
        child: Center(
          child: Text(
            containerText,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
