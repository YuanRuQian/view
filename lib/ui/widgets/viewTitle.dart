import 'package:flutter/material.dart';

class ViewAppTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'View',
        style: TextStyle(fontSize: 50.0, fontFamily: 'PermanentMarker'),
      ),
    );
  }
}

class ViewPageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'View',
      style: TextStyle(fontSize: 35.0, color: Colors.black, fontFamily: 'PermanentMarker'),
      textAlign: TextAlign.center,
    );
  }
}
