import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import './intermediate_screen.dart';

class PickerScreen extends StatefulWidget {

  const PickerScreen({Key key}): super(key: key);

  @override
  _PickerScreenState createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {

  // File _image;

  void _pickImage({ImageSource source}) async {
    var image = await ImagePicker.pickImage(source: source);
    // setState(() {
    //   this._image = image;
    // });
    if (image != null) {
      // Navigator.pushNamed(context, '/processing');
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => IntermediateScreen(image: image),
      ));
    }
  }

  Widget _renderButton(
      {@required String buttonText,
      EdgeInsets padding,
      List<Color> gradientColors,
      String bgImageUrl,
      IconData icon,
      ImageSource pickerSource}) {
    return GestureDetector(
      onTap: () => _pickImage(source: pickerSource),
      child: Container(
        padding: padding,
        child: Container(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select from',
                style: TextStyle(color: Color(0xfffafafa), fontSize: 16.0, fontFamily: 'Raleway'),
              ),
              Text(
                buttonText,
                style: TextStyle(color: Color(0xfffafafa), fontSize: 32.0, fontFamily: 'Raleway', fontWeight: FontWeight.w500),
              ),
              Padding(
                child: Icon(icon, size: 32.0, color: Color(0xfffafafa),),
                padding: EdgeInsets.all(8.0),
              ),
            ],
          )),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0.1, 0.4, 0.6, 0.9]),
            borderRadius: BorderRadius.circular(32.0),
            image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.08), BlendMode.dstATop),
                image: NetworkImage(bgImageUrl)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 7, offset: Offset(0, 4), color: Color(0xff212543))
            ]
          ),
        ),
      )
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  flex: 1,
                  child: _renderButton(
                    buttonText: 'CAMERA',
                    padding: EdgeInsets.fromLTRB(32.0, 64.0, 32.0, 16.0),
                    icon: Icons.camera_alt,
                    pickerSource: ImageSource.camera,
                    bgImageUrl: 'https://images.unsplash.com/photo-1520390138845-fd2d229dd553?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=80',
                    // gradientColors: [
                    //   Color(0xfff47475),
                    //   Color(0xfff26684),
                    //   Color(0xfff15a91),
                    //   Color(0xfff0599f)
                    // ],
                    gradientColors: [
                      Color(0xff464b6c),
                      Color(0xff2f3250),
                      Color(0xff252846),
                      Color(0xff212543)
                    ],
                  )),
              Flexible(
                flex: 1,
                child: _renderButton(
                  buttonText: 'FILES',
                  padding: EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 64.0),
                  icon: Icons.filter,
                  pickerSource: ImageSource.gallery,
                  bgImageUrl: 'https://images.unsplash.com/photo-1461360228754-6e81c478b882?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=80',
                  // gradientColors: [
                  //   Color(0xfff0599f),
                  //   Color(0xfff15a91),
                  //   Color(0xfff26684),
                  //   Color(0xfff47475),
                  // ]
                  gradientColors: [
                    Color(0xff212543),
                    Color(0xff252846),
                    Color(0xff2f3250),
                    Color(0xff464b6c),
                  ],
                ),
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/hypnotize.png'), repeat: ImageRepeat.repeat),
        ),
      )
    );
  }
}
