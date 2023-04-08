import 'package:flutter/material.dart';

class Pose {
  List<Point> points = List.empty(growable: true);
  Point get nose => points[0];
  set nose(Point newValue){
    points[0] = newValue;
  }

  Point get leftEye => points[1];
  set leftEye(Point newValue){
    points[1] = newValue;
  }

  Point get rightEye => points[2];
  set rightEye(Point newValue){
    points[2] = newValue;
  }

  Point get leftEar => points[3];
  set leftEar(Point newValue){
    points[3] = newValue;
  }

  Point get rightEar => points[4];
  set rightEar(Point newValue){
    points[4] = newValue;
  }

  Point get leftShoulder => points[5];
  set leftShoulder(Point newValue){
    points[5] = newValue;
  }

  Point get rightShoulder => points[6];
  set rightShoulder(Point newValue){
    points[6] = newValue;
  }

  Point get leftElbow => points[7];
  set leftElbow(Point newValue){
    points[7] = newValue;
  }

  Point get rightElbow => points[8];
  set rightElbow(Point newValue){
    points[8] = newValue;
  }

  Point get leftWrist => points[9];
  set leftWrist(Point newValue){
    points[9] = newValue;
  }

  Point get rightWrist => points[10];
  set rightWrist(Point newValue){
    points[10] = newValue;
  }

  Point get leftHip => points[11];
  set leftHip(Point newValue){
    points[11] = newValue;
  }

  Point get rightHip => points[12];
  set rightHip(Point newValue){
    points[12] = newValue;
  }

  Point get leftKnee => points[13];
  set leftKnee(Point newValue){
    points[13] = newValue;
  }

  Point get rightKnee => points[14];
  set rightKnee(Point newValue){
    points[14] = newValue;
  }

  Point get leftAnkle => points[15];
  set leftAnkle(Point newValue){
    points[15] = newValue;
  }

  Point get rightAnkle => points[16];
  set rightAnkle(Point newValue){
    points[16] = newValue;
  }

  Pose(List<double> points) {
    for(var i = 0; i < 17; i++) {
      this.points.add(Point(x: points[i*3], y: points[i*3+1], score: points[i*3+2]));
    }
  }

  List<Widget> toWidgets() {
    List<Widget> widgets = List.empty(growable: true);
    for(var point in points) {
      if(point.score < 0.11) {
        continue;
      }

      widgets.add(
          Positioned(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(padding:
                    EdgeInsets.only(
                      left: constraints.biggest.width * point.x,
                      top: constraints.biggest.height * point.y
                    ),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(100)
                      ),
                    ),
                  );
                },
              )
          )
      );
    }
    return widgets;
  }
}

class MoveNetPoints {
  List<Pose> poses = List.empty(growable: true);
  MoveNetPoints(List<List<List<double>>> points) {
    for(var i = 0; i < 6; i++) {
      poses.add(Pose(points[0][i]));
    }
  }

  List<Widget> toWidgets() {
    List<Widget> widgets = List.empty(growable: true);
    /*

    for(var pose in poses) {
      widgets.add(
          Stack(children: pose.toWidgets())
      );
    }
    */
    widgets.add(
        Stack(children: poses[0].toWidgets())
    );
    return widgets;
  }
}

class Point {
  final double x;
  final double y;
  final double score;
  const Point({required this.x, required this.y, required this.score});
}