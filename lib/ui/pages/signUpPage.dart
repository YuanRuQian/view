import 'package:flutter/material.dart';
import 'package:view/services/authentication.dart';
import 'package:view/ui/widgets/viewTitle.dart';
import 'package:view/utilities/constants.dart';
import 'package:view/utilities/tools.dart';

class SignUpPage extends StatefulWidget {
  static final String id = 'sign_up_page';
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _name, _email, _password;

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('创建账号 $_email $_name $_password');
      // Logging in the user w/ Firebase
      AuthService.signup(context, _name, _email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
                        decoration: InputDecoration(labelText: '用户名'),
                        validator: (input) =>
                            input.trim().isEmpty ? '请输入一个非空的用户名' : null,
                        onSaved: (input) => _name = input,
                      ),
                    ),
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
                        child: Text("注册"),
                        style: logInSignUpBtnStyle,
                        onPressed: _submit,
                      )),
                    SizedBox(height: 20.0),
                    Container(
                        width: 200.0,
                        child: TextButton(
                          child: Text("回到登录"),
                          style: logInSignUpBtnStyle,
                          onPressed: () => Navigator.pop(context),
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
