import 'package:flutter/material.dart';
import 'package:workbook/widget/button.dart';
import 'package:workbook/widget/first.dart';
import 'package:workbook/widget/inputEmail.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/textLogin.dart';
import 'package:workbook/widget/verticalText.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF163F49), Color(0xFF377C7D)]),
        ),
        child: ListView(
          children: <Widget>[
            Row(children: <Widget>[
              VerticalText(),
              TextLogin(),
            ]),
            InputEmail(),
            PasswordInput(),
            ButtonLogin(),
            FirstTime(),
          ],
        ),
      ),
    );
  }
}
