import 'package:flutter/material.dart';

class NoActivityIllustration extends StatefulWidget {
  final double containerHeight;
  final double containerWidth;
  NoActivityIllustration({this.containerHeight, this.containerWidth});
  @override
  _NoActivityIllustrationState createState() => _NoActivityIllustrationState();
}

class _NoActivityIllustrationState extends State<NoActivityIllustration> {
  @override
  Widget build(BuildContext context) {
    return Container(
              height: widget.containerHeight,
              width: widget.containerWidth,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('其他用户暂时还没有任何与您的互动',
                      style: TextStyle(fontSize: 20.0, color: Colors.black)),
                  Image.asset(
                    'assets/images/screen_time.jpg',
                    height: 250.0,
                    width: 250.0,
                  ),
                ],
              ));
  }
}
