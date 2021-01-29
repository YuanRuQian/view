import 'package:flutter/material.dart';
import 'package:view/services/database.dart';
import 'package:view/models/userModel.dart';
import 'package:view/models/postModel.dart';
import 'package:view/ui/widgets/postView.dart';
import 'package:view/ui/widgets/viewTitle.dart';

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
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: ViewPageTitle(),
      ),
      body: StreamBuilder(
        stream: DatabaseService.getFeedPosts(widget.currentUserId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: _height,
              width: _width,
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
                    parentCall: null
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
