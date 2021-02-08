import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:view/models/userModel.dart';
import 'package:view/services/database.dart';
import 'package:view/ui/pages/profilePage.dart';
import 'package:view/utilities/constants.dart';

class DisplayPeopleListPage extends StatefulWidget {
  final String currentUserId;
  final bool followers;
  DisplayPeopleListPage({this.currentUserId, this.followers});
  @override
  _DisplayPeopleListPageState createState() => _DisplayPeopleListPageState();
}

class _DisplayPeopleListPageState extends State<DisplayPeopleListPage> {
  List<String> usersList = [];

  @override
  void initState() {
    super.initState();
    _getUsersIds();
  }

  void _getUsersIds() async {
    List<String> ids = [];
    if (widget.followers) {
      await DatabaseService.getFollowersIds(widget.currentUserId).then((res) {
        ids = res;
      }).catchError((err) {
        print('_getUsersIds ERROR : ${err.toString()}');
      });
    } else {
      await DatabaseService.getFollowingIds(widget.currentUserId).then((res) {
        ids = res;
      }).catchError((err) {
        print('_getUsersIds ERROR : ${err.toString()}');
      });
    }
    setState(() {
      usersList = ids;
    });
  }

  _buildUserTile(String id, String currentUserId) async {
    User user;
    await DatabaseService.getUserWithId(id).then((res) {
      user = res;
      print('_buildUserTile user: ${user.name}');
    }).catchError((err) {
      print('_buildUserTile ERROR : ${err.toString()}');
    });
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage('assets/images/user_placeholder.jpg')
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name),
      onTap: () => Navigator.of(context)
          .push(_createProfilePageRoute(user, currentUserId)),
    );
  }

  Route _createProfilePageRoute(User user, String currentUserId) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(
              currentUserId: currentUserId,
              userId: user.id,
            ),
        transitionsBuilder: generalPageTransitionAnimation);
  }

  _buildTextHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(widget.followers ? '暂时还没有任何人关注您' : '您还没有关注任何人',
              style: TextStyle(fontSize: 20.0, color: Colors.black)),
          Image.asset(
            widget.followers
                ? 'assets/images/followers.png'
                : 'assets/images/following.png',
            height: 250.0,
            width: 250.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.followers ? '您的被关注列表' : '您的关注列表',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: usersList == null || usersList.length == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildTextHint(),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder(
                      future: DatabaseService.getUserWithId(usersList[index]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        User user = snapshot.data;
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20.0,
                            backgroundImage: user.profileImageUrl.isEmpty
                                ? AssetImage(
                                    'assets/images/user_placeholder.jpg')
                                : CachedNetworkImageProvider(
                                    user.profileImageUrl),
                          ),
                          title: Text(user.name),
                          onTap: () => Navigator.of(context).push(
                              _createProfilePageRoute(
                                  user, widget.currentUserId)),
                        );
                      });
                }));
  }
}
