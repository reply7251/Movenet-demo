

import 'package:flutter/material.dart';
import 'package:movenet_demo/ui/CameraView.dart';
import 'package:movenet_demo/ui/MoveNetPointsView.dart';

import '../tflite/MoveNetPoints.dart';

import 'package:image/image.dart' as imglib;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}

class HomePageState extends State<HomePage> {
  MoveNetPoints? points;
  double? radio;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(

        children: [
          CameraView(moveNetCallback: resultCallback),
          MoveNetPointsView(points: points)
        ],
      ),
    );
  }

  void resultCallback(MoveNetCallbackData data) {
    //points = MoveNetPoints(result);
    setState(() {
      points = MoveNetPoints(data);
    });
  }

}

class MoveNetCallbackData {
  List<List<List<double>>> result;
  double radio;
  MoveNetCallbackData(this.result, this.radio);
}