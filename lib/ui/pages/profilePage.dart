import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:view/models/postModel.dart';
import 'package:view/models/userModel.dart';
import 'package:view/models/userData.dart';
import 'package:view/services/database.dart';
import 'package:provider/provider.dart';
import 'package:view/ui/pages/commentPage.dart';
import 'package:view/ui/pages/displayPeopleListPage.dart';
import 'package:view/ui/widgets/postView.dart';
import 'package:view/ui/pages/editProfilePage.dart';
import 'package:view/services/authentication.dart';
import 'package:view/ui/widgets/viewTitle.dart';
import 'package:view/utilities/constants.dart';

class ProfilePage extends StatefulWidget {
  final String currentUserId;
  final String userId;

  ProfilePage({this.currentUserId, this.userId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; // 0 - grid, 1 - column
  User _profileUser;

  @override
  void initState() {
    super.initState();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followerCount = userFollowerCount;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _followingCount = userFollowingCount;
    });
  }

  _setupPosts() async {
    print('获取 posts 数据中...');
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    print('现在一共有 ${posts.length} 个 post');
    setState(() {
      _posts = posts;
    });
  }

  _setupProfileUser() async {
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      _profileUser = profileUser;
    });
  }

  _followOrUnfollow() {
    if (_isFollowing) {
      _unfollowUser();
    } else {
      _followUser();
    }
  }

  _unfollowUser() {
    DatabaseService.unfollowUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = false;
      _followerCount--;
    });
  }

  _followUser() {
    DatabaseService.followUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = true;
      _followerCount++;
    });
  }

  Route _createEditProfilePageRoute(User user) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditProfilePage(
              user: user,
              updateUser: (User updateUser) {
                // Trigger state rebuild after editing profile
                User updatedUser = User(
                  id: updateUser.id,
                  name: updateUser.name,
                  email: user.email,
                  profileImageUrl: updateUser.profileImageUrl,
                  bio: updateUser.bio,
                );
                setState(() => _profileUser = updatedUser);
              },
            ),
        transitionsBuilder: generalPageTransitionAnimation);
  }

  _displayButton(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? Container(
            width: 180.0,
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(_createEditProfilePageRoute(user)),
              style: TextButton.styleFrom(
                textStyle: TextStyle(color: Colors.black, fontSize: 18.0),
                primary: Colors.white,
                backgroundColor: Colors.black,
                side: BorderSide(color: Colors.black, width: 1),
                minimumSize: Size(100, 20),
              ),
              child: Text('编辑'),
            ),
          )
        : Container(
            width: 180.0,
            child: TextButton(
              child: Text(
                _isFollowing ? '取消关注' : '关注',
              ),
              style: TextButton.styleFrom(
                textStyle: TextStyle(color: Colors.black, fontSize: 18.0),
                primary: _isFollowing ? Colors.black : Colors.white,
                backgroundColor: _isFollowing ? Colors.grey[200] : Colors.black,
                minimumSize: Size(100, 20),
              ),
              onPressed: _followOrUnfollow,
            ));
  }

  Route _createDisplayPeopleListPageRoute(String currentUserId, bool followers) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DisplayPeopleListPage(
              currentUserId: currentUserId,
              followers: followers,
            ),
        transitionsBuilder: generalPageTransitionAnimation);
  }

  _buildProfileInfo(User user) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.white,
                backgroundImage: user.profileImageUrl.isEmpty
                    ? AssetImage('assets/images/user_placeholder.jpg')
                    : CachedNetworkImageProvider(user.profileImageUrl),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              _posts.length.toString(),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '帖子',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        GestureDetector(
                            onTap: () => {
                              Navigator.of(context).push(
                                  _createDisplayPeopleListPageRoute(
                                      widget.currentUserId, true))
                            },
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _followerCount.toString(),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '被关注',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            )),
                        GestureDetector(
                            onTap: () async {
                              Navigator.of(context).push(
                                  _createDisplayPeopleListPageRoute(
                                      widget.currentUserId, false));
                            },
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _followingCount.toString(),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '关注中',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            )),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    _displayButton(user),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                child: Text(
                  user.bio,
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }

  _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          iconSize: 30.0,
          color: _displayPosts == 0 ? Colors.black : Colors.grey[300],
          onPressed: () => setState(() {
            _displayPosts = 0;
          }),
        ),
        IconButton(
          icon: Icon(Icons.list),
          iconSize: 30.0,
          color: _displayPosts == 1 ? Colors.black : Colors.grey[300],
          onPressed: () => setState(() {
            _displayPosts = 1;
          }),
        ),
      ],
    );
  }

  Route _createCommentPageRoute(Post post) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CommentPage(
              post: post,
              likeCount: post.likeCount,
            ),
        transitionsBuilder: generalPageTransitionAnimation);
  }

  _buildTilePost(Post post) {
    return GridTile(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(_createCommentPageRoute(post)),
        child: Image(
          image: CachedNetworkImageProvider(post.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _buildDisplayPosts() {
    if (_displayPosts == 0) {
      // Grid
      List<GridTile> tiles = [];
      _posts.forEach(
        (post) => tiles.add(_buildTilePost(post)),
      );
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: tiles,
      );
    } else {
      // Column
      List<PostView> postViews = [];
      _posts.forEach((post) {
        postViews.add(PostView(
            showDeleteBtn: true,
            currentUserId: widget.currentUserId,
            post: post,
            author: _profileUser,
            parentCall: _setupPosts));
      });
      return Column(children: postViews);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: ViewPageTitle(),
        actions: <Widget>[
          widget.currentUserId == _profileUser?.id
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: AuthService.logout,
                )
              : SizedBox.shrink(),
        ],
      ),
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);
          return ListView(
            children: <Widget>[
              _buildProfileInfo(user),
              _buildToggleButtons(),
              Divider(),
              _buildDisplayPosts(),
            ],
          );
        },
      ),
    );
  }
}
