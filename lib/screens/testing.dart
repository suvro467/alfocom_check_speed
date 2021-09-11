// import 'package:flutter/material.dart';

// final DecorationTween decorationTweenOriginal = DecorationTween(
//   begin: BoxDecoration(
//     color: const Color(0xFFFFFFFF),
//     border: Border.all(
//       color: const Color(0xFF000000),
//       style: BorderStyle.solid,
//       width: 4.0,
//     ),
//     borderRadius: BorderRadius.zero,
//     shape: BoxShape.rectangle,
//     boxShadow: const <BoxShadow>[
//       BoxShadow(
//         color: Color(0x66000000),
//         blurRadius: 10.0,
//         spreadRadius: 4.0,
//       )
//     ],
//   ),
//   end: BoxDecoration(
//     color: const Color(0xFF000000),
//     border: Border.all(
//       color: const Color(0xFF202020),
//       style: BorderStyle.solid,
//       width: 1.0,
//     ),
//     borderRadius: BorderRadius.circular(10.0),
//     shape: BoxShape.rectangle,
//     // No shadow.
//   ),
// );

// final DecorationTween decorationTween = DecorationTween(
//   begin: BoxDecoration(
//     border: Border.all(width: 1),
//     borderRadius: BorderRadius.all(
//       Radius.circular(50),
//     ),
//     gradient: LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment(2, 0.0), // 10% of the width, so there are ten blinds.
//       colors: [Colors.green, Colors.yellow, Colors.amber], // red to yellow
//       tileMode: TileMode.repeated, // repeats the gradient over the canvas
//     ),
//   ),
//   end: BoxDecoration(
//     border: Border.all(width: 4),
//     borderRadius: BorderRadius.all(
//       Radius.circular(50),
//     ),
//     gradient: LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment(2, 0.0), // 10% of the width, so there are ten blinds.
//       colors: [Colors.green, Colors.yellow, Colors.amber], // red to yellow
//       tileMode: TileMode.repeated, // repeats the gradient over the canvas
//     ),
//   ),
// );

// AnimationController _controller;

// bool _first = true;

// initState() {
//   _controller = AnimationController(
//     vsync: this,
//     duration: const Duration(seconds: 1),
//   );
//   super.initState();
// }

// @override
// Widget build(BuildContext context) {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: <Widget>[
//       DecoratedBoxTransition(
//         position: DecorationPosition.background,
//         decoration: decorationTween.animate(_controller),
//         child: Container(
//           child: Container(
//             width: 200,
//             height: 200,
//             padding: EdgeInsets.all(20),
//             child: FlutterLogo(),
//           ),
//         ),
//       ),
//       SizedBox(
//         height: 20,
//       ),
//       FlatButton(
//         onPressed: () {
//           if (_first) {
//             _controller.forward();
//           } else {
//             _controller.reverse();
//           }
//           _first = !_first;
//         },
//         child: Text(
//           "Click Me!",
//         ),
//       )
//     ],
//   );
// }
