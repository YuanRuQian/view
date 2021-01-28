import 'package:flutter/material.dart';

class SigningLoader extends StatefulWidget {
  final double containerHeight;
  final double containerWidth;
  final bool isLogInMode;
  SigningLoader({this.containerHeight, this.containerWidth, this.isLogInMode});
  @override
  _SigningLoaderState createState() => _SigningLoaderState();
}

class _SigningLoaderState extends State<SigningLoader> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.containerHeight,
        width: widget.containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(child: CircularProgressIndicator()),
            Text(widget.isLogInMode
                ? '登录中......请稍等......'
                : '注册中......请稍等......')
          ],
        ));
  }
}
