import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/widget/dash_board.dart';
import 'dart:convert';
import 'package:workbook/widget/first.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/textLogin.dart';
import 'package:workbook/widget/verticalText.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future loginUser() async {
    var response = await http
        .post('https://app-workbook.herokuapp.com/admin/login', body: {
      "email": _emailController.text,
      "password": _passwordController.text
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() {
      _loading = false;
    });
    var resp = json.decode(response.body)['payload'];
    if (resp['approved'] == true) {
      setState(() {
        userName = resp['admin']['userName'];
        userID = resp['admin']['_id'];
        userRole = resp['admin']['role'];
        userEmail = resp['admin']['userID'];
        instituteName = resp['admin']['instituteName'];
        instituteImage = resp['admin']['instituteImage'];
        userInstituteType = resp['admin']['instituteType'];
      });
      Navigator.push(
        context,
        PageTransition(
            child: DashBoard(), type: PageTransitionType.rightToLeft),
      );
    } else {
      popDialog(
          onPress: () {
            Navigator.pop(context);
          },
          context: context,
          title: 'Request Pending',
          content: 'Please wait while the superadmin approves your request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        opacity: 0.5,
        color: Colors.white,
        dismissible: false,
        inAsyncCall: _loading,
        child: Container(
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
                  captial: TextCapitalization.none,
                  errorText: 'Please enter a valid email ID',
                  controller: _emailController,
                  validate: _validateEmail,
                  labelText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: PasswordInput(
                  errorText: 'This field can\'t be empty',
                  controller: _passwordController,
                  validate: _validatePassword,
                  labelText: 'Password',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, right: 20, left: 250),
                child: Container(
                  alignment: Alignment.bottomRight,
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      print('working');

                      setState(() {
                        _loading = true;
                      });
                      (_emailController.text.isEmpty ||
                              !validator.email(_emailController.text))
                          ? _validateEmail = true
                          : _validateEmail = false;
                      _passwordController.text.isEmpty
                          ? _validatePassword = true
                          : _validatePassword = false;
                      loginUser();
                    },
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FirstTime(),
            ],
          ),
        ),
      ),
    );
  }
}
