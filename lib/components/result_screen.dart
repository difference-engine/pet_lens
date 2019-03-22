import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rubber/rubber.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';
import 'dart:math';

// import './bottom_sheet.dart';
import './tempData.dart';

class ResultScreen extends StatefulWidget{

  final File queryImage;
  final String predictedLabel;
  final List<Map> sameClassSimilar;
  final List<Map> differentClassSimilar;
  final String selectedImageUrl;
  final bool showResults;
  final double flickHalfBoundValue, flickUpperBoundValue;
  ResultScreen({Key key, this.queryImage, this.selectedImageUrl, @required this.predictedLabel,
                this.sameClassSimilar, this.differentClassSimilar,
                this.flickHalfBoundValue, @required this.flickUpperBoundValue,
                @required this.showResults}): super(key: key);

  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin{

  final String IMAGE_BUCKET_BASE_URL = 'https://storage.googleapis.com/personalresources-181518.appspot.com/images/';
  int numSameClassImages, numDIfferentClassesImages;
  RubberAnimationController _controller;
  ScrollController _scrollController;
  final AppBar appBar = AppBar(
                          title: Text('Pet Lens'),
                          backgroundColor: Color(0x00000000),
                          elevation: 0,     
                        );

  @override
  void initState(){
    super.initState();
    _controller = RubberAnimationController(
      vsync: this,
      halfBoundValue: AnimationControllerValue(percentage: widget.flickHalfBoundValue),
      upperBoundValue: AnimationControllerValue(percentage: widget.flickUpperBoundValue),
      duration: Duration(milliseconds: 200),
    );

    if (widget.showResults) {
      _scrollController = ScrollController();
      numSameClassImages = min(widget.sameClassSimilar.length, 12);
      numDIfferentClassesImages = min(widget.differentClassSimilar.length, 12);
    }
  }

  Widget _makeSectionHeader(String text, double topPadding) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 8.0, top: topPadding),
      child: Text(text, style: TextStyle(fontFamily: 'Raleway', fontSize: 16.0, fontWeight: FontWeight.w500),),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x222a2a2a)))
      ),
    );
  }

  Widget _getLowerLayer() {
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
                heroTag: widget.showResults ? 'queryImage': widget.selectedImageUrl,
                imageProvider: widget.showResults ? FileImage(widget.queryImage): NetworkImage(widget.selectedImageUrl),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: appBar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultImageWidget(String imageUrl, String predictedLabel) {
    return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ResultScreen(
                  predictedLabel: predictedLabel,
                  showResults: false,
                  selectedImageUrl: imageUrl,
                  flickHalfBoundValue: null,
                  flickUpperBoundValue: 0.25,
                )
              ));
            },
            child: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)), 
              child:Hero(
                child: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(imageUrl),
                ),
                tag: imageUrl,
              )
            ),
          )
        );
  }

  Widget _getResultsSection() {
    return Expanded(
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              itemCount: numSameClassImages + numDIfferentClassesImages + 2,
              controller: _scrollController,
              padding: EdgeInsets.all(8.0),
              itemBuilder: (BuildContext context, int index) {

                if (index == 0) {
                  return _makeSectionHeader('Same Class', 8.0);
                } else if (index - 1 < numSameClassImages) {
                  return _resultImageWidget(IMAGE_BUCKET_BASE_URL + widget.sameClassSimilar[index - 1]['image_name'],
                                            widget.sameClassSimilar[index - 1]['label']);
                } else if (index == numSameClassImages + 1) {
                  return _makeSectionHeader('Different Classes', 16.0);
                } else {
                  return _resultImageWidget(IMAGE_BUCKET_BASE_URL + widget.differentClassSimilar[index - numSameClassImages - 2]['image_name'],
                                            widget.differentClassSimilar[index - numSameClassImages - 2]['label']);
                  
                }
              },
              staggeredTileBuilder: (int index) {
                if (index == 0 || index == numSameClassImages + 1) {
                  return StaggeredTile.fit(4);
                }
                return StaggeredTile.fit(2);
              },
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            )
          );
  }

  Widget _getUpperLayer() {
    return Container(
      child:Column(
        children: [
          _getBottomSheetHeader(),
          // Container(
          //   child: Text('This is some info about basset hound', style: TextStyle(decoration: TextDecoration.none, color: Color(0xff2a2a2a), fontWeight: FontWeight.normal, fontFamily: 'Roboto', fontSize: 16)),
          //   width: MediaQuery.of(context).size.width,
          //   padding: EdgeInsets.fromLTRB(14, 14, 14, 32),
          // ),
          (widget.showResults ? _getResultsSection(): Container(width: 0, height: 0)),
        ]
      ), 
      decoration: BoxDecoration(
        color: Color(0xfffafafa),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      )
    );
  }

  Widget _getBottomSheetHeader() {
    return Container(
      child: Text(widget.predictedLabel, style: TextStyle(decoration: TextDecoration.none, color: Color(0xff2a2a2a), fontFamily: 'Raleway', fontSize: 32)),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      body:RubberBottomSheet(
      scrollController: _scrollController,
      lowerLayer: _getLowerLayer(),
      upperLayer: _getUpperLayer(),
      animationController: _controller,
    ));
  }
}