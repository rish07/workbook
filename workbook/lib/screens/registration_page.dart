import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/employee_form.dart';
import 'package:workbook/widget/buttonNewUser.dart';
import 'package:workbook/screens/admin_form.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/signup.dart';
import 'package:workbook/widget/textNew.dart';
import 'package:http/http.dart' as http;

import 'package:workbook/widget/registerButton.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _isLoading = false;
  Future getInstitutes() async {
    var response =
        await http.get("https://app-workbook.herokuapp.com/admin/institutes");
    print('Response status: ${response.statusCode}');
    List temp = json.decode(response.body)['payload']['institute'];
    temp.forEach((resp) {
      institutes.add(resp['instituteName']);
    });
    institutes = Set.of(institutes).toList();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [teal1, teal2]),
          ),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SignUp(),
                      TextNew(),
                    ],
                  ),
                  Text(
                    'Register as',
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                  ),
                  registerButton(
                      role: 'Admin',
                      context: context,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: AdminForm(),
                              type: PageTransitionType.rightToLeft),
                        );
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  registerButton(
                      role: 'Employee',
                      context: context,
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await getInstitutes();
                        Navigator.push(
                          context,
                          PageTransition(
                              child: EmployeeForm(),
                              type: PageTransitionType.rightToLeft),
                        );
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  registerButton(
                      role: 'Driver',
                      context: context,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: AdminForm(),
                              type: PageTransitionType.rightToLeft),
                        );
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  registerButton(
                      role: 'Customer',
                      context: context,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: AdminForm(),
                              type: PageTransitionType.rightToLeft),
                        );
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
