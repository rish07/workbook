import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';

import 'package:workbook/constants.dart';
import 'package:workbook/screens/request_profile_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'dart:convert';

class ActiveUsers extends StatefulWidget {
  final bool isDriver;

  const ActiveUsers({Key key, this.isDriver}) : super(key: key);
  @override
  _ActiveUsersState createState() => _ActiveUsersState();
}

class _ActiveUsersState extends State<ActiveUsers> {
  int counter = 0;
  bool _loading = false;
  List _employeeList = [];

  Future _getUsers() async {
    var response = User.userRole != 'superAdmin'
        ? await http.post(
            User.userRole == 'admin' && !widget.isDriver
                ? "$baseUrl/admin/viewAllEmployees"
                : (User.userRole == 'admin' && widget.isDriver)
                    ? "$baseUrl/admin/viewAllDrivers"
                    : "$baseUrl/employee/activeCustomer",
            body: User.userRole == 'admin'
                ? {
                    "instituteName": User.instituteName,
                  }
                : {
                    "employeeID": User.userEmail,
                  },
          )
        : await http.get('$baseUrl/superAdmin/viewAllAdmin');
    print('Response status: ${response.statusCode}');
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var employees = User.userRole == 'admin' && !widget.isDriver
          ? json.decode(response.body)['payload']['employees']
          : (User.userRole == 'admin' && widget.isDriver)
              ? json.decode(response.body)['payload']['drivers']
              : (User.userRole == 'employee')
                  ? json.decode(response.body)['payload']['customer']
                  : json.decode(response.body)['payload']['admin'];
      for (var employee in employees) {
        _employeeList.add(employee);
      }
      print(_employeeList);
    } else {
      throw Exception('Failed to load the employees');
    }
  }

  @override
  void initState() {
    setState(() {
      _loading = true;
    });
    _getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          User.userRole == 'admin' && !widget.isDriver
              ? 'Active Employees'
              : (User.userRole == 'admin' && widget.isDriver)
                  ? "Active Drivers"
                  : (User.userRole == 'employee')
                      ? 'Active Customers'
                      : 'Active Admins',
          style: TextStyle(color: teal2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: teal2),
      ),
      drawer: buildDrawer(context),
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(teal2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _loading,
        child: Center(
          child: ListView.builder(
              itemCount: _employeeList.length,
              itemBuilder: (context, index) {
                if (_employeeList[index]['approved'] == true) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: RequestProfilePage(
                                  carNumber: _employeeList[index]['carNumber'],
                                  isDriver: widget.isDriver ? true : false,
                                  instituteType: _employeeList[index]
                                      ['instituteType'],
                                  instituteName: _employeeList[index]
                                      ['instituteName'],
                                  isActive: true,
                                  exists: _employeeList[index]
                                              ['profilePicture'] ==
                                          null
                                      ? false
                                      : true,
                                  id: _employeeList[index]['_id'],
                                  role: _employeeList[index]['role'],
                                  userName: _employeeList[index]['userName'],
                                  aadharNumber: _employeeList[index]
                                          ['adharNumber']
                                      .toString(),
                                  contactNumber: _employeeList[index]
                                          ['contactNumber']
                                      .toString(),
                                  division: _employeeList[index]['division'],
                                  grade: _employeeList[index]['grade'],
                                  emailID: _employeeList[index]['userID'],
//                                  profilePicture: _employeeList[index]
//                                      ['profilePicture'],
                                ),
                                type: PageTransitionType.rightToLeft));
                      },
                      child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                spreadRadius: 0.5,
                              )
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _employeeList[index]['userName'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  User.userRole != 'superAdmin' &&
                                          !widget.isDriver
                                      ? Row(
                                          children: [
                                            Text(
                                              'Division: ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _employeeList[index]['division'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Text(
                                              'Institute Name: ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _employeeList[index]
                                                  ['instituteName'],
                                              style: TextStyle(fontSize: 14),
                                            )
                                          ],
                                        ),
                                  User.userRole != 'superAdmin' &&
                                          !widget.isDriver
                                      ? Row(
                                          children: [
                                            Text(
                                              'Grade: ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _employeeList[index]['grade'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        )
                                      : !widget.isDriver
                                          ? Row(
                                              children: [
                                                Text(
                                                  'Institute Type: ',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  _employeeList[index]
                                                      ['instituteType'],
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                )
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Text(
                                                  'Car Number: ',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  _employeeList[index]
                                                      ['carNumber'],
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                )
                                              ],
                                            )
                                ],
                              ),
                              Icon(Icons.navigate_next),
                            ],
                          )),
                    ),
                  );
                } else {
                  return Container();
                }
              }),
        ),
      ),
    );
  }
}
