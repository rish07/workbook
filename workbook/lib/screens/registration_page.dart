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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _isLoading,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [violet1, violet2]),
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
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(child: AdminForm(), type: PageTransitionType.rightToLeft),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 16),
                                  height: MediaQuery.of(context).size.height * 0.18,
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.14,
                                          child: Image.asset('images/admin.png'),
                                        ),
                                        Text(
                                          'Admin',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  var response = await http.get('$baseUrl/superAdmin/viewAllAdmin');
                                  print(response.body);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        child: EmployeeCustomerForm(
                                          admins: json.decode(response.body)['payload']['admin'],
                                          isEmployee: true,
                                        ),
                                        type: PageTransitionType.rightToLeft),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 16),
                                  height: MediaQuery.of(context).size.height * 0.18,
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.14,
                                          child: Image.asset('images/emp.png'),
                                        ),
                                        Text(
                                          'Employee/Staff',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(child: DriverForm(), type: PageTransitionType.rightToLeft),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 16),
                                  height: MediaQuery.of(context).size.height * 0.18,
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.14,
                                          child: Image.asset('images/driver.jpeg'),
                                        ),
                                        Text(
                                          'Driver',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        child: EmployeeCustomerForm(
                                          isEmployee: false,
                                        ),
                                        type: PageTransitionType.rightToLeft),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 16),
                                  height: MediaQuery.of(context).size.height * 0.18,
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.14,
                                          child: Image.asset('images/cust.jpg'),
                                        ),
                                        Text(
                                          'Customer',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
//                  registerButton(
//                      role: 'Admin',
//                      context: context,
//                      onPressed: () async {
//                        Navigator.push(
//                          context,
//                          PageTransition(child: AdminForm(), type: PageTransitionType.rightToLeft),
//                        );
//                      }),
//                  SizedBox(
//                    height: MediaQuery.of(context).size.height * 0.02,
//                  ),
//                  registerButton(
//                      role: 'Employee',
//                      context: context,
//                      onPressed: () async {
//                        setState(() {
//                          _isLoading = true;
//                        });
//                        var response = await http.get('$baseUrl/superAdmin/viewAllAdmin');
//                        print(response.body);
//                        setState(() {
//                          _isLoading = false;
//                        });
//                        Navigator.push(
//                          context,
//                          PageTransition(
//                              child: EmployeeCustomerForm(
//                                admins: json.decode(response.body)['payload']['admin'],
//                                isEmployee: true,
//                              ),
//                              type: PageTransitionType.rightToLeft),
//                        );
//                      }),
//                  SizedBox(
//                    height: MediaQuery.of(context).size.height * 0.02,
//                  ),
//                  registerButton(
//                      role: 'Driver',
//                      context: context,
//                      onPressed: () async {
//                        Navigator.push(
//                          context,
//                          PageTransition(child: DriverForm(), type: PageTransitionType.rightToLeft),
//                        );
//                      }),
//                  SizedBox(
//                    height: MediaQuery.of(context).size.height * 0.02,
//                  ),
//                  registerButton(
//                      role: 'Customer',
//                      context: context,
//                      onPressed: () async {
//                        Navigator.push(
//                          context,
//                          PageTransition(
//                              child: EmployeeCustomerForm(
//                                isEmployee: false,
//                              ),
//                              type: PageTransitionType.rightToLeft),
//                        );
//                      }),
//                  SizedBox(
//                    height: MediaQuery.of(context).size.height * 0.02,
//                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
