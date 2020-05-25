import 'dart:async';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  static double z = 2;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 50),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = Size(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return Container(
      color: Colors.black,
      width: size.width,
      height: size.height,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          var dragPer = details.localPosition.dx / size.width; // [0 ... 1]
          var newVelocity = (-8 + dragPer * 16); //[-8 ... 8]
          MyApp.z = newVelocity;
        },
        child: CustomPaint(
          child: HintText(),
          isComplex: true,
          willChange: true,
          painter: MyPinter(_controller, size),
        ),
      ),
    );
  }
}

class HintText extends StatefulWidget {
  @override
  _HintTextState createState() => _HintTextState();
}

class _HintTextState extends State<HintText> {
  var _OK = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () => setState(() => _OK = true));
  }

  @override
  Widget build(BuildContext context) {
    return !_OK
        ? Align(
            alignment: Alignment.center,
            child: Container(
              child: Text(
                'Drag horizontally to go back or forward ',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    decoration: TextDecoration.none),
              ),
            ),
          )
        : Container();
  }
}

class MyPinter extends CustomPainter {
  List<Star> stars;
  Size size;
  AnimationController controller;

  MyPinter(this.controller, this.size) : super(repaint: controller) {
    stars = List.generate(400, (index) => Star(size));
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white;

    canvas.translate(size.width / 2, size.height / 2);

    stars.forEach((element) {
      double scaleR = element.upDate();
      Offset starOffset = element.show();
      Offset tileOffset = starOffset * 0.975;
      canvas.drawLine(tileOffset, starOffset, paint); // star tile
      canvas.drawCircle(starOffset, scaleR, paint);
    });
  }

  @override
  bool shouldRepaint(MyPinter oldDelegate) {
    return true;
  }
}

class Star {
  int x;
  int y;
  double z;
  Size size;
  int width;
  int height;

  Star(this.size) {
    width = size.width.floor();
    height = size.height.floor();
    reset();
  }

  void reset() {
    x = Random().nextInt(width * 2) - width;
    y = Random().nextInt(height * 2) - height;
    z = width.ceilToDouble();
  }

  double upDate() {
    z -= MyApp.z;

    return (1 - (z / width)) / 0.25; // star radius
  }

  Offset show() {
    var xz = x / (z) * width;
    var yz = y / (z) * height;

    if (xz >= width || yz >= height || yz <= -height || xz <= -height) {
      reset();
    }
    return Offset(xz, yz);
  }
}
