import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:view/models/userData.dart';
import 'package:view/pages/activityPage.dart';
import 'package:view/pages/addPostPage.dart';
import 'package:view/pages/feedPage.dart';
import 'package:view/pages/profilePage.dart';
import 'package:view/pages/searchPage.dart';
import 'package:provider/provider.dart';
import 'package:view/ui/pages/activityPage.dart';
import 'package:view/ui/pages/addPostPage.dart';
import 'package:view/ui/pages/feedPage.dart';
import 'package:view/ui/pages/profilePage.dart';
import 'package:view/ui/pages/searchPage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedPage(),
          SearchPage(),
          AddPostPage(),
          ActivityPage(),
          ProfilePage(),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentTab,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        activeColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}