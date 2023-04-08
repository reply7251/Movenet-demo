

import 'package:flutter/material.dart';
import 'package:movenet_demo/ui/CameraView.dart';
import 'package:movenet_demo/ui/MoveNetPointsView.dart';

import '../tflite/MoveNetPoints.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}

class HomePageState extends State<HomePage> {
  MoveNetPoints? points;


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

  void resultCallback(List<List<List<double>>> result, int radioWidth, int radioHeight) {
    /*for(var i = 0; i < 6; i++) {
      for(var j = 0; j < 17; j++) {
        result[0][i][j*3] *= radioWidth;
        result[0][i][j*3+1] *= radioHeight;
      }
    }

     */
    //points = MoveNetPoints(result);
    setState(() {
      points = MoveNetPoints(result);
    });
  }

}