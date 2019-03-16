import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

import './result_screen.dart';
import './processor.dart';

class IntermediateScreen extends StatefulWidget {

  final File image;
  const IntermediateScreen({Key key, @required this.image}): super(key: key);

  @override
  _IntermediateScreenState createState() => _IntermediateScreenState();
}

class _IntermediateScreenState extends State<IntermediateScreen> {

  final AppBar appBar = AppBar(
                          title: Text('Pet Lens'),
                          backgroundColor: Color(0x00000000),
                          elevation: 0,     
                        );

  void handleSearch() async {
    List<dynamic> similarImageIds = await performSearch(widget.image);
    List<Map> similarImageDetails = await extractImageDetails(similarImageIds);
    Map seperatedCategories = await seperateCategories(similarImageDetails);

    print('Predicted Class: ${seperatedCategories["predictedLabel"]}');
    print('Similar of same class: ${seperatedCategories["sameClassSimilar"]}');
    print('Similar of different class: ${seperatedCategories["differentClassSimilar"]}');
    // print("Similar Image details: $similarImageDetails");
    // print(getappl)
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ResultScreen(queryImage: widget.image, 
                                        predictedLabel: seperatedCategories['predictedLabel'], 
                                        sameClassSimilar: seperatedCategories['sameClassSimilar'],
                                        differentClassSimilar: seperatedCategories['differentClassSimilar'],
                                        showResults: true, flickHalfBoundValue: 0.25, flickUpperBoundValue: 0.75,)
    ));
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: PhotoView(
                backgroundDecoration: BoxDecoration(
                  color: Color(0xff000000)
                ),
                heroTag: 'queryImage',
                imageProvider: FileImage(widget.image),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: appBar,
            ),
            Positioned(
              bottom: 75,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: this.handleSearch,
                    child: Container(
                      child: Flex(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Icon(Icons.search,),
                          Text('Search', style: TextStyle(fontSize: 20),),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xfffafafa),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [BoxShadow(blurRadius: 7,  color: Color(0x992a2a2a))],
                      ),
                    ),
                  )
                  
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}