import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:view/models/postModel.dart';
import 'package:view/models/userModel.dart';
import 'package:view/ui/pages/commentPage.dart';
import 'package:view/ui/pages/profilePage.dart';
import 'package:view/services/database.dart';

class PostView extends StatefulWidget {
  final bool showDeleteBtn;
  final String currentUserId;
  final Post post;
  final User author;
  final parentCall;

  PostView(
      {this.showDeleteBtn,
      this.currentUserId,
      this.post,
      this.author,
      this.parentCall});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  int _likeCount = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _initPostLiked();
  }

  @override
  void didUpdateWidget(PostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != widget.post.likeCount) {
      _likeCount = widget.post.likeCount;
    }
  }

  _initPostLiked() async {
    print('postView 的帖子 id : ${widget.post.id}');
    bool isLiked = await DatabaseService.didLikePost(
      currentUserId: widget.currentUserId,
      post: widget.post,
    );
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  _likePost() {
    if (_isLiked) {
      // 取消赞
      DatabaseService.unlikePost(
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _isLiked = false;
        _likeCount = _likeCount - 1;
      });
    } else {
      // 点赞
      DatabaseService.likePost(
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _isLiked = true;
        _likeCount = _likeCount + 1;
      });
    }
  }

  _deleteThisPost() async {
    List res = await DatabaseService.deletePostData(widget.post);
    if (res.length > 0) {
      widget.parentCall();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(title: Text('刪除成功!'));
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(title: Text('刪除失败!'));
          });
    }
  }

  _showDeletePostDialog() {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("取消"),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget continueButton = FlatButton(
        child: Text("确定"),
        onPressed: () {
          _deleteThisPost();
          Navigator.of(context).pop();
        });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("确认删除"),
      content: Text("您要继续删除操作吗？"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(
                currentUserId: widget.currentUserId,
                userId: widget.post.authorId,
              ),
            ),
          ),
          child: Container(
            width: _width,
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.author.profileImageUrl.isEmpty
                      ? AssetImage('assets/images/user_placeholder.jpg')
                      : CachedNetworkImageProvider(
                          widget.author.profileImageUrl),
                ),
                SizedBox(width: 15.0),
                Text(
                  widget.author.name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: widget.currentUserId == widget.post.authorId
                      ? Container(
                          alignment: Alignment.centerRight,
                          child: widget.showDeleteBtn
                              ? IconButton(
                                  icon: Icon(Icons.delete_forever),
                                  iconSize: 30.0,
                                  onPressed: () => _showDeletePostDialog(),
                                )
                              : SizedBox.shrink(),
                        )
                      : SizedBox.shrink(),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: _likePost,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.post.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: _isLiked
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : Icon(Icons.favorite),
                    iconSize: 30.0,
                    onPressed: _likePost,
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    iconSize: 30.0,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentPage(
                          post: widget.post,
                          likeCount: _likeCount,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '${_likeCount.toString()} 个赞',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      left: 12.0,
                      right: 6.0,
                    ),
                    child: Text(
                      widget.author.name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.post.caption,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
            ],
          ),
        ),
      ],
    );
  }
}
