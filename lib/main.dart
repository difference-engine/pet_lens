import 'package:flutter/material.dart';
import 'components/landing_screen.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  File _image;
  List _similarImages;
  Map<String, dynamic> _selectedProduct;
  Future<String> res = Tflite.loadModel(model: "assets/converted_embeddings_model.tflite", labels: "assets/labels.txt");

  void updateSimilarImages(List similarImages) {
    setState(() {
      this._similarImages = similarImages;
    });
  }

  void updateSelectedProduct(Map<String, dynamic> newSelectedProduct) {
    setState(() {
      this._selectedProduct = newSelectedProduct;
    });
  }

  @override
  Widget build(context) {


    return MaterialApp(
      theme: new ThemeData(
        primaryColor: Colors.brown,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PickerScreen(),
        // '/processing': (context) => ProcessingScreen(image: this._image, updateSimilarImages: this.updateSimilarImages),
        // '/results': (context) => ResultsScreen(queryImage: this._image, updateSlectedProduct: this.updateSelectedProduct,),
        // '/product': (context) => ProductScreen(selectedProduct: this._selectedProduct,),
      },
    );
  }
}
