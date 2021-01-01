import 'package:flutter/material.dart';
import 'package:view/ui/pages/LogInPage.dart';
import 'package:view/ui/pages/signUpPage.dart';

void main() {
  runApp(MyApp());
}

   class MyApp extends StatelessWidget {
      // This widget is the root of your application.
      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          title: 'Welcome to View',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: LogInPage(),
          routes: {
          LogInPage.id: (context) => LogInPage(),
          SignUpPage.id: (context) => SignUpPage(),
        },
        );
      }
    }
