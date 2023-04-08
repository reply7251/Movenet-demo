import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../ui/HomePage.dart';
import 'package:image/image.dart' as imglib;
import 'dart:ui' as ui;

double threshold = 0.13;

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

  Widget toWidget() {
    return LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            painter: PosePainter(this),
            size: Size(constraints.biggest.width, constraints.biggest.height),
          );
        }
    );
  }
}

class MoveNetPoints {
  List<Pose> poses = List.empty(growable: true);
  MoveNetCallbackData data;

  MoveNetPoints(this.data) {
    poses.addAll(data.result[0].map((e) => Pose(e)));
  }

  Widget toWidget() {
    List<Widget> children = [];

    children.addAll(poses.map((x) => x.toWidget()));

    return Stack(
      children: children,
    );
  }
}

class PosePainter extends CustomPainter{
  Pose pose;
  Paint linePaint = Paint();
  Paint dotPaint = Paint();

  Canvas? canvas;
  Size? size;

  PosePainter(this.pose) {
    linePaint.color = Colors.blue;
    linePaint.strokeWidth = 3;
    dotPaint.color = Colors.green;
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;

    line(pose.nose, pose.leftEye);
    line(pose.leftEye, pose.leftEar);
    line(pose.nose, pose.rightEye);
    line(pose.rightEye, pose.rightEar);

    line(pose.leftShoulder, pose.rightShoulder);
    line(pose.leftShoulder, pose.leftElbow);
    line(pose.leftElbow, pose.leftWrist);
    line(pose.rightShoulder, pose.rightElbow);
    line(pose.rightElbow, pose.rightWrist);

    line(pose.leftShoulder, pose.leftHip);
    line(pose.rightShoulder, pose.rightHip);
    line(pose.leftHip, pose.rightHip);

    line(pose.leftHip, pose.leftKnee);
    line(pose.leftKnee, pose.leftAnkle);
    line(pose.rightHip, pose.rightKnee);
    line(pose.rightKnee, pose.rightAnkle);

    for(var point in pose.points) {
      dot(point);
    }

    this.canvas = null;
    this.size = null;
  }

  void dot(Point p) {
    if(p.score < threshold) {
      return;
    }
    canvas?.drawCircle(point2Offset(p), 5, dotPaint);
  }

  void line(Point p1, Point p2) {
    if(p1.score < threshold || p2.score < threshold) {
      return;
    }
    canvas?.drawLine(point2Offset(p1), point2Offset(p2), linePaint);
  }

  Offset point2Offset(Point p) {
    return Offset(p.x * size!.width, p.y * size!.height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}

class Point {
  final double x;
  final double y;
  final double score;
  const Point({required this.x, required this.y, required this.score});
}