import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:view/models/userModel.dart';
import 'package:view/services/database.dart';
import 'package:view/services/storage.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  final Function updateUser;

  EditProfilePage({this.user, this.updateUser});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File _profileImage;
  String _name = '';
  String _bio = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  _handleImageFromGallery() async {
    PickedFile selectedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    File imageFile = File(selectedFile.path);
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  _displayProfileImage() {
    // No new profile image
    if (_profileImage == null) {
      // No existing profile image
      if (widget.user.profileImageUrl.isEmpty) {
        // Display placeholder
        return AssetImage('assets/images/user_placeholder.jpg');
      } else {
        // User profile image exists
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      // New profile image
      return FileImage(_profileImage);
    }
  }

  _submit() async {
    if (_formKey.currentState.validate() && !_isLoading) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // Update user in database
      String _profileImageUrl = '';

      if (_profileImage == null) {
        _profileImageUrl = widget.user.profileImageUrl;
      } else {
        _profileImageUrl = await StorageService.uploadUserProfileImage(
          widget.user.profileImageUrl,
          _profileImage,
        );
      }

      User user = User(
        id: widget.user.id,
        name: _name,
        profileImageUrl: _profileImageUrl,
        bio: _bio,
      );
      // Database update
      DatabaseService.updateUser(user);
      widget.updateUser(user);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '编辑',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: _displayProfileImage(),
                    ),
                    TextButton(
                      onPressed: _handleImageFromGallery,
                      style: TextButton.styleFrom(
                          textStyle:
                              TextStyle(color: Colors.black, fontSize: 15.0),
                          primary: Colors.black),
                      child: Text(
                        '更改头像',
                      ),
                    ),
                    TextFormField(
                      initialValue: _name,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.person,
                          size: 30.0,
                        ),
                        labelText: '用户名',
                      ),
                      validator: (input) =>
                          input.trim().length < 1 ? '用户名不可为空' : null,
                      onSaved: (input) => _name = input,
                    ),
                    TextFormField(
                      initialValue: _bio,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.book,
                          size: 30.0,
                        ),
                        labelText: '简介',
                      ),
                      validator: (input) =>
                          input.trim().length > 150 ? '简介需要小于150字' : null,
                      onSaved: (input) => _bio = input,
                    ),
                    Container(
                      margin: EdgeInsets.all(100.0),
                      width: 200.0,
                      child: TextButton(
                        onPressed: _submit,
                        style: TextButton.styleFrom(
                          textStyle:
                              TextStyle(color: Colors.black, fontSize: 20.0),
                          primary: Colors.white,
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.black, width: 1),
                          minimumSize: Size(100, 50),
                        ),
                        child: Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
