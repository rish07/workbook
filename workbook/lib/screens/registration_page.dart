import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/driver_form.dart';
import 'package:workbook/screens/employee_cust_form.dart';
import 'package:workbook/screens/admin_form.dart';
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
    var response = await http.get("$baseUrl/admin/institutes");
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
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(teal2),
          backgroundColor: Colors.transparent,
        ),
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
                      onPressed: () async {
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
                        var response =
                            await http.get('$baseUrl/superAdmin/viewAllAdmin');

                        await getInstitutes();
                        Navigator.push(
                          context,
                          PageTransition(
                              child: EmployeeCustomerForm(
                                admins: json.decode(response.body)['payload']
                                    ['admin'],
                                isEmployee: true,
                              ),
                              type: PageTransitionType.rightToLeft),
                        );
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  registerButton(
                      role: 'Driver',
                      context: context,
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await getInstitutes();
                        Navigator.push(
                          context,
                          PageTransition(
                              child: DriverForm(),
                              type: PageTransitionType.rightToLeft),
                        );
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  registerButton(
                      role: 'Customer',
                      context: context,
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await getInstitutes();
                        Navigator.push(
                          context,
                          PageTransition(
                              child: EmployeeCustomerForm(
                                isEmployee: false,
                              ),
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
