

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:movenet_demo/tflite/TFLitePatch.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;
import 'package:image/image.dart' as imglib;
import 'package:synchronized/synchronized.dart';

class CameraView extends StatefulWidget {
  final Function(List<List<List<double>>>, int, int) moveNetCallback;

  const CameraView({super.key, required this.moveNetCallback});

  @override
  State<StatefulWidget> createState() {
    return CameraViewState();
  }
  
}

class CameraViewState extends State<CameraView> with WidgetsBindingObserver{
  CameraController? controller;
  Interpreter? interpreter;
  int? resizeWidth;
  int? resizeHeight;
  int? radioWidth;
  int? radioHeight;
  bool isDetecting = false;
  Lock detectingLock = Lock();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initInterpreter();
    initCamera();
  }

  Future<void> initInterpreter() async {
    interpreter = await Interpreter.fromAsset("lite-model_movenet_multipose_lightning_tflite_float16_1.tflite");
  }

  Future<void> initCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    controller?.initialize().then(onCameraReady);
  }

  Future<void> onCameraReady(dynamic value) async {
    var size = controller!.value.previewSize;
    var mx = max(size!.width, size.height);
    var radio = mx / 256;
    resizeWidth = ((size.width / radio) ~/ 32) * 32;
    resizeHeight = ((size.height / radio) ~/ 32) * 32;

    await controller?.startImageStream(onImageAvailable);
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.inactive) {
      controller?.dispose();
      controller = null;
    } else if (state == AppLifecycleState.resumed && controller == null) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    controller = null;
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    return controller!.buildPreview();
  }

  Future<void> onImageAvailable(CameraImage image) async {

      if(isDetecting || interpreter == null) {
        return;
      }
      setState(() {
        isDetecting = true;
      });
      var rgb = await convertImage(image);
      if(rgb == null) {
        return;
      }
      List<List<List<List<int>>>> input = List.generate(1,
              (_) => List.generate(rgb.height,
                      (_) => List.generate(rgb.width,
                              (_) => List.generate(3, (_) => 0)
                      )
              )
      );
      //var input = List.filled(rgb.width * rgb.height * 3, 0).reshape([1, rgb.height, rgb.width, 3]);
      List<List<List<double>>> output = List.generate(1,
              (_) => List.generate(6,
                      (_) => List.generate(56,  (_)=>30.0 )
              )
      );
      for (var element in rgb) {
        input[0][element.y][element.x][0] = element.r as int;
        input[0][element.y][element.x][1] = element.g as int;
        input[0][element.y][element.x][2] = element.b as int;
      }

      var result = await compute((isolateData) {
        List<List<List<double>>> output = List.generate(1,
                (_) => List.generate(6,
                    (_) => List.generate(56,  (_)=>30.0 )
            )
        );
        Patch.run(
            Interpreter.fromAddress(isolateData.interpreterAddress),
            isolateData.input,
            output
        );
        return output;
      }, IsolateData(input, interpreter!.address));
      widget.moveNetCallback(result, radioWidth!, radioHeight!);
      //print(output);
      //widget.moveNetCallback(output, radioWidth!, radioHeight!);
      setState(() {
        isDetecting = false;
      });
  }

  Future<imglib.Image?> convertImage(CameraImage cameraImage) async {
    const shift = (0xFF << 24);
    try {
      final int originalWidth = cameraImage.width;
      final int originalHeight = cameraImage.height;
      int croppedWidth = (originalWidth ~/ 32) * 32;
      int croppedLeft = (originalWidth - croppedWidth) ~/ 2;
      int croppedHeight = (originalHeight ~/ 32) * 32;
      int croppedTop = (originalHeight - croppedHeight) ~/ 2;
      final int uvRowStride = cameraImage.planes[1].bytesPerRow;
      final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

      //print("uvRowStride: " + uvRowStride.toString());
      //print("uvPixelStride: " + uvPixelStride.toString());

      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var result = imglib.Image(width: croppedWidth, height: croppedHeight);//img.Image(width, height); // Create Image buffer
      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < croppedWidth; x++) {
        for (int y = 0; y < croppedHeight; y++) {
          final int uvIndex = uvPixelStride! * ((x+croppedLeft) / 2).floor() + uvRowStride * ((y+croppedTop) / 2).floor();
          final int index = (y+croppedTop) * originalWidth + (x+croppedLeft);

          final yp = cameraImage.planes[0].bytes[index];
          final up = cameraImage.planes[1].bytes[uvIndex];
          final vp = cameraImage.planes[2].bytes[uvIndex];
          // Calculate pixel color
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          if (result.isBoundsSafe(x, croppedHeight-y)){
            result.setPixelRgba(x, croppedHeight-y, r , g ,b ,shift);
          }
        }
      }
      radioWidth = originalWidth;
      radioHeight = originalHeight;
      return imglib.copyResize(result, width: resizeWidth, height: resizeHeight);
      //imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: imglib.PngFilter.none);
      //Uint8List png = pngEncoder.encode(result);
      //return Image.memory(png);
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }
  
}

class IsolateData {
  List<List<List<List<int>>>> input;
  int interpreterAddress;

  IsolateData(this.input, this.interpreterAddress);
}