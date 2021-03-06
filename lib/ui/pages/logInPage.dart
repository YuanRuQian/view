import 'package:flutter/material.dart';
import 'package:view/services/authentication.dart';
import 'package:view/ui/pages/signUpPage.dart';
import 'package:view/utilities/constants.dart';
import 'package:view/utilities/tools.dart';
import 'package:view/ui/widgets/viewTitle.dart';

class LogInPage extends StatefulWidget {
  static final String id = 'log_in_page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Logging in the user w/ Firebase
      print('登录: $_email $_password');
      AuthService.login(context, _email, _password);
    }
  }

  Route _createSignUpPageRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignUpPage(),
      transitionsBuilder: generalPageTransitionAnimation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ViewAppTitle(),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 10.0,
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: '邮箱'),
                      validator: (input) =>
                          !validateEmail(input) ? '请输入正确的邮箱地址' : null,
                      onSaved: (input) => _email = input,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 10.0,
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: '密码'),
                      validator: (input) => !validatePassword(input)
                          ? '密码至少分别一位大小字母,特殊字符和数字且至少8位'
                          : null,
                      onSaved: (input) => _password = input,
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Container(
                      width: 200.0,
                      child: TextButton(
                        child: Text("登录"),
                        style: logInSignUpBtnStyle,
                        onPressed: _submit,
                      )),
                  SizedBox(height: 20.0),
                  Container(
                      width: 200.0,
                      child: TextButton(
                        child: Text("前往注册"),
                        style: logInSignUpBtnStyle,
                        onPressed: () => Navigator.of(context)
                            .push(_createSignUpPageRoute()),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
