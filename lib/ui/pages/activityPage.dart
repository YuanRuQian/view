
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:view/models/activityModel.dart';
import 'package:view/models/postModel.dart';
import 'package:view/models/userData.dart';
import 'package:view/models/userModel.dart';
import 'package:view/ui/pages/commentPage.dart';
import 'package:view/services/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:view/ui/pages/commentPage.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CommentPage(),
    );
  }
}