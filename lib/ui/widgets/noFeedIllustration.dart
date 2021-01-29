import 'package:flutter/material.dart';

class NoFeedIllustration extends StatefulWidget {
  final double containerHeight;
  final double containerWidth;
  NoFeedIllustration({this.containerHeight, this.containerWidth});
  @override
  _NoFeedIllustrationState createState() => _NoFeedIllustrationState();
}

class _NoFeedIllustrationState extends State<NoFeedIllustration> {
  @override
  Widget build(BuildContext context) {
    return Container(
              height: widget.containerHeight,
              width: widget.containerWidth,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('您暂时还没有任何订阅的内容',
                      style: TextStyle(fontSize: 20.0, color: Colors.black)),
                  Image.asset(
                    'assets/images/feed_photos.jpg',
                    height: 250.0,
                    width: 250.0,
                  ),
                ],
              ));
  }
}
