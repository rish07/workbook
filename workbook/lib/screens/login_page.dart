import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/widget/button.dart';
import 'package:workbook/widget/first.dart';
import 'package:workbook/widget/input_field.dart';

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
              colors: [teal1, teal2]),
        ),
        child: ListView(
          children: <Widget>[
            Row(children: <Widget>[
              VerticalText(),
              TextLogin(),
            ]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputField(
                validate: false,
                labelText: 'Email',
                textInputType: TextInputType.emailAddress,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: PasswordInput(
                validate: false,
                labelText: 'Password',
              ),
            ),
            ButtonLogin(),
            FirstTime(),
          ],
        ),
      ),
    );
  }
}
