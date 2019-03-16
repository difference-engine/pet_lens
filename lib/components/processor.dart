import 'package:flutter/services.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:tflite/tflite.dart';
import 'package:csv/csv.dart';
import 'dart:io';

const platform = MethodChannel('com.petlens/model');
const String embeddingsFile = 'embeddings_v4.ann';

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
    ByteData data = await rootBundle.load("assets/v2.ann");
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

Future<List<dynamic>> performSearch(File image) async {
  print('Finding Similar...');
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

    return response;
  } on PlatformException catch(e) {
    print('Error Finding similar: ${e.message}');
  }

  return [];
}


Future<String> loadAsset(String path) async {
   return await rootBundle.loadString(path);
}

Future<List<Map>> extractImageDetails(List<dynamic> similarImageIds) async {
  dynamic output = await loadAsset('assets/all_images.csv');
  List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter(eol: '\n').convert(output);
  print(rowsAsListOfValues[0]);

  List<Map> similarPets = [];
  for (int imageId in similarImageIds) {
    List<dynamic> petDetailsList = rowsAsListOfValues[imageId+1];
    Map<String, dynamic> petDetailsMap = Map<String, dynamic>();
    petDetailsMap['id'] = petDetailsList[0];
    petDetailsMap['image_name'] = petDetailsList[1];
    petDetailsMap['label'] = petDetailsList[5];
    similarPets.add(petDetailsMap);
  }
  return similarPets;
}

Future<Map> seperateCategories(List<Map> similarImageDetails) async {
  Map<String, int> classFrequencies = Map();
  int maxFrequencyYet = 0;
  String maxFrequencyLabel = '';
  for (int idx = 0; idx < 7; idx++) {
    String label = similarImageDetails[idx]['label'];
    if (classFrequencies.containsKey(label)) {
      classFrequencies[label] += 1;
    } else {
      classFrequencies[label] = 1;
    }

    if (classFrequencies[label] > maxFrequencyYet) {
      maxFrequencyYet = classFrequencies[label];
      maxFrequencyLabel = label;
    }
  }

  List<Map> sameClassSimilar = similarImageDetails.where((image) => (image['label'] == maxFrequencyLabel)).toList();
  List<Map> differentClassSimilar = similarImageDetails.where((image) => (image['label'] != maxFrequencyLabel)).toList();

  return {'sameClassSimilar': sameClassSimilar, 'differentClassSimilar': differentClassSimilar, 'predictedLabel': maxFrequencyLabel};
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