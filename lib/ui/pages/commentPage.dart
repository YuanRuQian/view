import 'package:flutter/material.dart';
import 'package:view/models/postModel.dart';

class CommentPage extends StatefulWidget {
  final Post post;
  final int likeCount;

  CommentPage({this.post, this.likeCount});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}