import 'package:flutter/material.dart';
import 'package:view/models/postModel.dart';
import 'package:view/models/userModel.dart';
import 'package:view/ui/widgets/postView.dart';

class SinglePostPage extends StatefulWidget {
  final Post post;
  final String currentUserId;
  final User author;
  SinglePostPage({this.post, this.currentUserId, this.author});
  @override
  _SinglePostPageState createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {
  Widget _buildSinglePostView() {
    List<PostView> postViews = [];
    postViews.add(PostView(
        showDeleteBtn: false,
        currentUserId: widget.currentUserId,
        post: widget.post,
        author: widget.author,
        parentCall: null));
    return Column(children: postViews);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '互动',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _buildSinglePostView(),
    );
  }
}
