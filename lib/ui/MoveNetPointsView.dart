

import 'package:flutter/cupertino.dart';
import 'package:movenet_demo/tflite/MoveNetPoints.dart';

class MoveNetPointsView extends StatefulWidget {
  final MoveNetPoints? points;
  const MoveNetPointsView({super.key, this.points});

  @override
  State<StatefulWidget> createState() => MoveNetPointsViewState();

}

class MoveNetPointsViewState extends State<MoveNetPointsView> {
  @override
  Widget build(BuildContext context) {
    if(widget.points == null) {
      return Container();
    }
    return widget.points!.toWidget();
  }

}