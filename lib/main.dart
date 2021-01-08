import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:view/models/userData.dart';
import 'package:provider/provider.dart';
import 'package:view/ui/pages/feedPage.dart';
import 'package:view/ui/pages/homePage.dart';
import 'package:view/ui/pages/logInPage.dart';
import 'package:view/ui/pages/signUpPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget _getScreenId() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          Provider.of<UserData>(context).currentUserId = snapshot.data.uid;
          return HomePage();
        } else {
          return LogInPage();
        }
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        title: 'View',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
                color: Colors.black,
              ),
        ),
        home: _getScreenId(),
        routes: {
          LogInPage.id: (context) => LogInPage(),
          SignUpPage.id: (context) => SignUpPage(),
          FeedPage.id: (context) => FeedPage(),
        },
      ),
    );
  }
}
