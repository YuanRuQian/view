import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:view/models/userData.dart';
import 'package:view/models/userModel.dart';
import 'package:view/ui/pages/profilePage.dart';
import 'package:view/services/database.dart';
import 'package:provider/provider.dart';
import 'package:view/utilities/constants.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchQuery = new TextEditingController();
  Timer _debounce;
  Future<QuerySnapshot> _users;
  String _currentInput;

  _userNameIncludesInput(String userName) {
    return userName.indexOf(_currentInput) != -1;
  }

  _onSearchChanged() {
    String input = _searchQuery.text;
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (input.isNotEmpty) {
        setState(() {
          _users = DatabaseService.searchUsers(input);
          _currentInput = input;
        });
      } else {
        setState(() {
          _users = null;
          _currentInput = null;
        });
      }
    });
  }

  _buildUserTile(User user,String currentUserId) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage('assets/images/user_placeholder.jpg')
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name),
      onTap: () => Navigator.of(context)
                            .push(_createProfilePageRoute(user,currentUserId)),
    );
  }

  Route _createProfilePageRoute(User user,String currentUserId) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(
            currentUserId: currentUserId,
            userId: user.id,
          ),
      transitionsBuilder: generalPageTransitionAnimation
    );
  }

  _clearSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchQuery.clear());
    setState(() {
      _users = null;
      _currentInput = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchQuery.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchQuery,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15.0),
            border: InputBorder.none,
            hintText: '查询',
            prefixIcon: Icon(
              Icons.search,
              size: 30.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: _clearSearch,
            ),
            filled: true,
          ),
          onSubmitted: (input) {
            if (input.isNotEmpty) {
              setState(() {
                _users = DatabaseService.searchUsers(input);
              });
            }
          },
        ),
      ),
      body: _users == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('查找用户',
                      style: TextStyle(fontSize: 20.0, color: Colors.black)),
                  Image.asset(
                    'assets/images/search_user.jpg',
                    height: 250.0,
                    width: 250.0,
                  ),
                ],
              ),
            )
          : FutureBuilder(
              future: _users,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data.documents.length == 0) {
                  return Center(
                    child: Text('Oops, 没有找到相关用户......'),
                  );
                }
                var data = snapshot.data.documents;
                var docs = [];
                for (int i = 0; i < data.length; i++) {
                  User user = User.fromDoc(data[i]);
                  if (_userNameIncludesInput(user.name)) {
                    docs.add(data[i]);
                  }
                }
                String currentUserId =
                    Provider.of<UserData>(context).currentUserId;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    User user = User.fromDoc(data[index]);
                    return _userNameIncludesInput(user.name)
                        ? _buildUserTile(user, currentUserId)
                        : SizedBox.shrink();
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _searchQuery.removeListener(_onSearchChanged);
    _searchQuery.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
