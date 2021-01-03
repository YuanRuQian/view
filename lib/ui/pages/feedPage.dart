import 'package:flutter/material.dart';
import 'package:view/services/database.dart';
import 'package:view/models/userModel.dart';
import 'package:view/models/postModel.dart';
import 'package:view/ui/widgets/postView.dart';

class FeedPage extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedPage({this.currentUserId});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Instagram',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: DatabaseService.getFeedPosts(widget.currentUserId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }
          final List<Post> posts = snapshot.data;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) {
              Post post = posts[index];
              return FutureBuilder(
                future: DatabaseService.getUserWithId(post.authorId),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }
                  User author = snapshot.data;
                  return PostView(
                    currentUserId: widget.currentUserId,
                    post: post,
                    author: author,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
