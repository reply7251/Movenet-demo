import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

class Patch {
  static void run(Interpreter interpreter, Object input, Object output) {
    var map = <int, Object>{};
    map[0] = output;
    runForMultipleInputs(interpreter, [input], map);
  }

  static void runForMultipleInputs(Interpreter interpreter, List<Object> inputs, Map<int, Object> outputs) {
    if (inputs.isEmpty) {
      throw ArgumentError('Input error: Inputs should not be null or empty.');
    }
    if (outputs.isEmpty) {
      throw ArgumentError('Input error: Outputs should not be null or empty.');
    }

    var inputTensors = interpreter.getInputTensors();

    for (int i = 0; i < inputs.length; i++) {
      var tensor = inputTensors.elementAt(i);
      final newShape = tensor.getInputShapeIfDifferent(inputs[i]);
      if (newShape != null) {
        interpreter.resizeInputTensor(i, newShape);
      }
    }

    if (!interpreter.isAllocated) {
      interpreter.allocateTensors();
    }

    inputTensors = interpreter.getInputTensors();
    for (int i = 0; i < inputs.length; i++) {
      var input = convertObjectToBytes(inputs[i], inputTensors.elementAt(i).type);
      inputTensors.elementAt(i).setTo(input);
    }
    interpreter.invoke();
    var outputTensors = interpreter.getOutputTensors();
    for (var i = 0; i < outputTensors.length; i++) {
      outputTensors[i].copyTo(outputs[i]!);
    }
  }

  static Uint8List convertObjectToBytes(Object o, TfLiteType tfliteType) {
    if (o is Uint8List) {
      return o;
    }
    if (o is ByteBuffer) {
      return o.asUint8List();
    }
    List<int> bytes = <int>[];
    if (o is List) {
      for (var e in o) {
        bytes.addAll(convertObjectToBytes(e, tfliteType));
      }
    } else {
      return convertElementToBytes(o, tfliteType);
    }
    return Uint8List.fromList(bytes);
  }

  static Uint8List convertElementToBytes(Object o, TfLiteType tfliteType) {
    if (tfliteType == TfLiteType.float32) {
      if (o is double) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o, Endian.little);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.float32}');
      }
    } else if (tfliteType == TfLiteType.int32) {
      if (o is int) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt32(0, o, Endian.little);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.int32}');
      }
    } else if (tfliteType == TfLiteType.int64) {
      if (o is int) {
        var buffer = Uint8List(8).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt64(0, o, Endian.big);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.int32}');
      }
    } else if (tfliteType == TfLiteType.int16) {
      if (o is int) {
        var buffer = Uint8List(2).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt16(0, o, Endian.little);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.int32}');
      }
    } else if (tfliteType == TfLiteType.float16) {
      if (o is double) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o, Endian.little);
        return buffer.asUint8List().sublist(0, 2);
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.float32}');
      }
    } else if (tfliteType == TfLiteType.int8) {
      if (o is int) {
        var buffer = Uint8List(1).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt8(0, o);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.float32}');
      }
    } else if (tfliteType == TfLiteType.uint8) {
      if (o is int) {
        var buffer = Uint8List(1).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setUint8(0, o);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.float32}');
      }
    } else {
      throw ArgumentError(
          'The input data tfliteType ${o.runtimeType} is unsupported');
    }
  }
}