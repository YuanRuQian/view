import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:view/models/userData.dart';
import 'package:view/models/userModel.dart';
import 'package:view/ui/pages/profilePage.dart';
import 'package:view/services/database.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchQuery = new TextEditingController();
  Timer _debounce;
  Future<QuerySnapshot> _users;

  _onSearchChanged() {
    String input = _searchQuery.text;
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (input.isNotEmpty) {
        setState(() {
          _users = DatabaseService.searchUsers(input);
        });
      }
    });
  }

  _buildUserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage('assets/images/user_placeholder.jpg')
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(
            currentUserId: Provider.of<UserData>(context).currentUserId,
            userId: user.id,
          ),
        ),
      ),
    );
  }

  _clearSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchQuery.clear());
    setState(() {
      _users = null;
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
              child: Text('查找用户'),
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
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    User user = User.fromDoc(snapshot.data.documents[index]);
                    return _buildUserTile(user);
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
