import 'package:flutter/material.dart';

class ViewAppTitle extends StatefulWidget {
  @override
  _ViewAppTitleState createState() => _ViewAppTitleState();
}

class _ViewAppTitleState extends State<ViewAppTitle>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _hi;
  String hi = "Hi, Welcome to";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 5500));
    _hi = StepTween(begin: 0, end: hi.length).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
    _controller.forward();
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _hi,
          builder: (BuildContext context, Widget child) {
            String text = hi.substring(0, _hi.value);
            return Text(
              text,
              style: TextStyle(fontSize: 35.0, fontFamily: 'Caveat'),
            );
          },
        ),
        SizedBox(
          height: _height * 0.015,
        ),
        Text(
          'View',
          style: TextStyle(fontSize: 60.0, fontFamily: 'PermanentMarker'),
        ),
      ],
    );
  }

  @override
  void dispose() {
     _controller.dispose();
    super.dispose();
  }
}

class ViewPageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'View',
      style: TextStyle(
          fontSize: 35.0, color: Colors.black, fontFamily: 'PermanentMarker'),
      textAlign: TextAlign.center,
    );
  }
}
