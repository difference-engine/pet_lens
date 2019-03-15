import 'package:flutter/services.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:tflite/tflite.dart';
import 'dart:io';

const platform = MethodChannel('com.petlens/model');
const String embeddingsFile = 'embeddings.ann';

void writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path).writeAsBytesSync(
    buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<String> getEmbeddingsPath() async {
  Directory directory = await getApplicationDocumentsDirectory();
  var filePath = join(directory.path, embeddingsFile);
  return filePath;
}

Future<void> copyEmbeddingsToStorage() async {
  String filePath = await getEmbeddingsPath();
  if (FileSystemEntity.typeSync(filePath) == FileSystemEntityType.notFound) {
    print('Copying embeddings to storage');
    ByteData data = await rootBundle.load("assets/embeddings.ann");
    writeToFile(data, filePath);
  } else {
    print('Embeddings already exists');
  }
}

Future<List<dynamic>> makePrediction(File image) async {
  var imageBytes = image.readAsBytesSync();
  img.Image newImg = img.decodeJpg(imageBytes);
  newImg = img.copyResize(newImg, 224, 224);

  var recognitions = await Tflite.runModelOnBinary(
    binary: imageToByteList(newImg, 224, 0, 255),// required
    numResults: 512,    // defaults to 5
    threshold: 0.05,  // defaults to 0.1
    raw: true,
  );
  print('Model predictions: $recognitions');

  return recognitions;
}

Future<Map> performSearch(File image) async {
  print('Finding Similar 123...');
  await copyEmbeddingsToStorage();
  try {
    String embeddingsPath = await getEmbeddingsPath();
    String emebddingResponse = await platform.invokeMethod('loadEmbeddings', {'path': embeddingsPath});
    print('Embedding loader response: $emebddingResponse');

    List<dynamic> predictions = await makePrediction(image);
    predictions = predictions[0];
    print(predictions.length);
    
    List<dynamic> response = await platform.invokeMethod('findSimilar', {'queryEmbedding': predictions});
    print('MethodChannel response: $response');
  } on PlatformException catch(e) {
    print('Error Finding similar: ${e.message}');
  }

  


  return {};
}


Uint8List imageToByteList(img.Image image, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(i, j);
      buffer[pixelIndex++] = (((pixel >> 16) & 0xFF) / 127.5) - 1.0;
      buffer[pixelIndex++] = (((pixel >> 8) & 0xFF) / 127.5) - 1.0;
      buffer[pixelIndex++] = (((pixel) & 0xFF) / 127.5) - 1.0;
    }
  }
  return convertedBytes.buffer.asUint8List();
}