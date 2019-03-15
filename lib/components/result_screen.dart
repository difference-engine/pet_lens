import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rubber/rubber.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';

// import './bottom_sheet.dart';
import './tempData.dart';

class ResultScreen extends StatefulWidget{

  final File queryImage;
  ResultScreen({Key key, @required this.queryImage}): super(key: key);

  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin{

  RubberAnimationController _controller;
  ScrollController _scrollController = ScrollController();
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
      halfBoundValue: AnimationControllerValue(percentage: 0.25),
      upperBoundValue: AnimationControllerValue(percentage: 0.75),
      duration: Duration(milliseconds: 200),
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
                heroTag: 'queryImage',
                imageProvider: FileImage(widget.queryImage),
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

  Widget _getUpperLayer() {
    return Container(
      child:Column(
        children: [
          _getBottomSheetHeader(),
          Container(
            child: Text('This is some info about basset hound', style: TextStyle(decoration: TextDecoration.none, color: Color(0xff2a2a2a), fontWeight: FontWeight.normal, fontFamily: 'Roboto', fontSize: 16)),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(14),
          ),
          Expanded(
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              itemCount: similarImages.length,
              controller: _scrollController,
              padding: EdgeInsets.all(8.0),
              itemBuilder: (BuildContext context, int index) => new Container(
                  // color: Colors.green,
                  // decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Colors.green),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)), 
                  child:Image(
                    fit: BoxFit.cover,
                    image: NetworkImage(similarImages[index]['url']),
                  )
                )
              ),
              staggeredTileBuilder: (int index) =>
                  new StaggeredTile.fit(2),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
          )
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
      child: Text('Basset Hound', style: TextStyle(decoration: TextDecoration.none, color: Color(0xff2a2a2a), fontFamily: 'Raleway', fontSize: 32)),
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
      // header: _getBottomSheetHeader(),
    ));
  }
}