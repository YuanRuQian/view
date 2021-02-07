import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:view/models/activityModel.dart';
import 'package:view/models/postModel.dart';
import 'package:view/models/userData.dart';
import 'package:view/models/userModel.dart';
import 'package:view/services/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:view/ui/pages/singlePostPage.dart';
import 'package:view/ui/widgets/noActivityIllustration.dart';
import 'package:view/ui/widgets/viewTitle.dart';

class ActivityPage extends StatefulWidget {
  final String currentUserId;
  ActivityPage({this.currentUserId});
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Activity> _activities = [];
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
      });
    }
  }

  _buildActivity(Activity activity, double _height, double _width) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(activity.fromUserId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return NoActivityIllustration(
            containerHeight: _height,
            containerWidth: _width,
          );
        }
        User user = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.grey,
            backgroundImage: user.profileImageUrl.isEmpty
                ? AssetImage('assets/images/user_placeholder.jpg')
                : CachedNetworkImageProvider(user.profileImageUrl),
          ),
          title: activity.comment != null
              ? Text('${user.name} 评论: "${activity.comment}"')
              : Text('${user.name} 觉得很赞'),
          subtitle: Text(
            DateFormat.yMd().add_jm().format(activity.timestamp.toDate()),
          ),
          trailing: CachedNetworkImage(
            imageUrl: activity.postImageUrl,
            height: 40.0,
            width: 40.0,
            fit: BoxFit.cover,
          ),
          onTap: () async {
            String currentUserId = Provider.of<UserData>(context,listen: false).currentUserId;
            Post post = await DatabaseService.getUserPost(
              currentUserId,
              activity.postId,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SinglePostPage(post: post,currentUserId: currentUserId,author: user),
              ),
            );
          },
        );
      },
    );
  }

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
      body: RefreshIndicator(
        onRefresh: () => _setupActivities(),
        child: _activities.length == 0
            ? NoActivityIllustration(
                containerHeight: _height,
                containerWidth: _width,
              )
            : ListView.builder(
                itemCount: _activities.length,
                itemBuilder: (BuildContext context, int index) {
                  Activity activity = _activities[index];
                  return _buildActivity(activity, _height, _width);
                },
              ),
      ),
    );
  }
}
