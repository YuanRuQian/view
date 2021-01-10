import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:view/models/userData.dart';
import 'package:provider/provider.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = Firestore.instance;

  static _showErrorDialog(BuildContext context, String err) {
    print('展示错误信息');
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('操作失败!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('以下为返回信息:'),
                  Text(err),
                ],
              ),
            ));
      },
    );
  }

  static void signUpUser(
      BuildContext context, String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser signedInUser = authResult.user;
      if (signedInUser != null) {
        _firestore.collection('/users').document(signedInUser.uid).setData({
          'name': name,
          'email': email,
          'profileImageUrl': '',
        });
        Provider.of<UserData>(context, listen: false).currentUserId =
            signedInUser.uid;
        print('注册成功 $signedInUser');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
      print(e);
    }
  }

  static void logout() {
    _auth.signOut();
  }

  static void login(BuildContext context, String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('认证成功 $result');
    } catch (e) {
      // 登录 contextLogInPage(state: _LoginPageState#5649e)
      _showErrorDialog(context, e.toString());
      print(e);
    }
  }
}
