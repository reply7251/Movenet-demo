import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movenet_demo/ui/HomePage.dart';
import 'package:video_player/video_player.dart';
//import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/*
class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? controller;
  late Completer<void> cameraAvailable;
  //Interpreter? interpreter;
  Image? latest;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initModel();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initModel() async {
    //interpreter = await Interpreter.fromAsset("assets/lite-model_movenet_multipose_lightning_tflite_float16_1.tflite");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder<void>(
      future: cameraAvailable.future,
      builder: (context, snapshot) {
        if (snapshot.hasError || controller == null) {
          return Container();
        }
        return MaterialApp(
          home: Stack(
               children: [
                 controller!.buildPreview()
               ],
          )
        );
      }
    );
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

  Future<void> initCamera() async {
    cameraAvailable = Completer();
    try{
      if(controller == null) {
        final cameras = await availableCameras();
        controller = CameraController(
            cameras[0],
            ResolutionPreset.max,
            enableAudio: false);

        await controller?.initialize().then((_) async => {
          await controller?.startImageStream(onLatestImageAvailable)
        });

        cameraAvailable.complete();
      }
    } catch (error) {
      cameraAvailable.completeError(error);
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  Future<void> startRecording() async {
    if(controller == null || !controller!.value.isInitialized) {
      return;
    }
    if(controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await controller?.startImageStream(onLatestImageAvailable);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return;
    }
  }

  Future<void> onLatestImageAvailable(CameraImage cameraImage) async {
    latest = await processImage(cameraImage);
    setState(() {});
  }

  Future<Image?> processImage(CameraImage cameraImage) async {
    const shift = (0xFF << 24);
    try {
      final int width = cameraImage.width;
      final int height = cameraImage.height;
      final int uvRowStride = cameraImage.planes[1].bytesPerRow;
      final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

      print("uvRowStride: " + uvRowStride.toString());
      print("uvPixelStride: " + uvPixelStride.toString());

      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var result = img.Image(width: width, height: height);//img.Image(width, height); // Create Image buffer

      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          final int uvIndex = uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * width + x;

          final yp = cameraImage.planes[0].bytes[index];
          final up = cameraImage.planes[1].bytes[uvIndex];
          final vp = cameraImage.planes[2].bytes[uvIndex];
          // Calculate pixel color
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          if (result.isBoundsSafe(x, height-y)){
            result.setPixelRgba(x, height-y, r , g ,b ,shift);
          }
        }
      }

      img.PngEncoder pngEncoder = img.PngEncoder(level: 0, filter: img.PngFilter.none);
      Uint8List png = pngEncoder.encode(result);
      return Image.memory(png);
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }
}
*/
