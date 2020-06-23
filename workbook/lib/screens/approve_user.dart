import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';

import 'package:workbook/constants.dart';
import 'package:workbook/screens/active_users.dart';
import 'package:workbook/screens/request_profile_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'dart:convert';

import 'package:workbook/widget/popUpDialog.dart';

class ApproveUser extends StatefulWidget {
  final bool isDriver;

  const ApproveUser({Key key, this.isDriver}) : super(key: key);
  @override
  _ApproveUserState createState() => _ApproveUserState();
}

class _ApproveUserState extends State<ApproveUser> {
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
                    : "$baseUrl/employee/viewAllCustomers",
            body: {
              "instituteName": User.instituteName,
            },
          )
        : await http.get('$baseUrl/superAdmin/viewAllAdmin');
    print('Response status: ${response.statusCode}');

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

  Future _approveUser({String id}) async {
    print('working');
    var response = await http.post(
        User.userRole == 'admin' && !widget.isDriver
            ? "$baseUrl/admin/approveEmployee"
            : (User.userRole == 'admin' && widget.isDriver)
                ? "$baseUrl/admin/approveDriver"
                : (User.userRole == 'employee')
                    ? "$baseUrl/employee/approveCustomer"
                    : "$baseUrl/superAdmin/approveAdmin",
        body: User.userRole != 'employee'
            ? {"id": id}
            : {
                "id": id,
                "employeeID": User.userEmail,
              });
    print('Response status: ${response.statusCode}');
    print(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      setState(() {
        _loading = true;
        _employeeList.clear();
      });
      _getUsers();
    } else {
      throw Exception('Failed to load the employees');
    }
  }

  Future _rejectUser({String id}) async {
    print('working');
    var response = await http.post(
        User.userRole == 'admin' && !widget.isDriver
            ? "$baseUrl/admin/rejectEmployee"
            : (User.userRole == 'admin' && widget.isDriver)
                ? "$baseUrl/admin/rejectDriver"
                : (User.userRole == 'employee')
                    ? "$baseUrl/employee/rejectCustomer"
                    : "$baseUrl/superAdmin/rejectAdmin",
        body: User.userRole != 'employee'
            ? {"id": id}
            : {
                "id": id,
                "employeeID": User.userEmail,
              });
    print('Response status: ${response.statusCode}');
    print(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      setState(() {
        _loading = true;
        _employeeList.clear();
      });
      _getUsers();
    } else {
      throw Exception('Failed to load the employees');
    }
  }

  Future _sendNotification(
      {String fcmToken, String message, String title}) async {
    var response = await http.post('$baseUrl/sendNotification',
        body: {"fcmToken": fcmToken, "message": message, "title": title});
    print('Response status: ${response.statusCode}');
    print(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      print('Notification Sent');
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
              ? 'Approve Employees'
              : (User.userRole == 'admin' && widget.isDriver)
                  ? "Approve Driver"
                  : (User.userRole == 'employee')
                      ? 'Approve Customers'
                      : 'Approve Admins',
          style: TextStyle(color: teal2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: teal2),
      ),
      drawer: buildDrawer(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: teal2,
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                  child: !widget.isDriver
                      ? ActiveUsers(
                          isDriver: false,
                        )
                      : ActiveUsers(
                          isDriver: true,
                        ),
                  type: PageTransitionType.rightToLeft),
            );
          },
          label: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.visibility),
              ),
              Text(
                User.userRole == 'admin' && !widget.isDriver
                    ? 'Active Employees'
                    : (User.userRole == 'admin' && widget.isDriver)
                        ? "Active Drivers"
                        : (User.userRole == 'employee')
                            ? 'Active Customers'
                            : 'Active Admins',
              ),
            ],
          )),
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(teal2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _loading,
        child: Center(
          child: _employeeList.length == 0
              ? Text(
                  'No pending requests',
                  style: TextStyle(fontSize: 30, color: Colors.grey),
                )
              : ListView.builder(
                  itemCount: _employeeList.length,
                  itemBuilder: (context, index) {
                    if (_employeeList[index]['approved'] == false) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: RequestProfilePage(
                                      carNumber: _employeeList[index]
                                          ['carNumber'],
                                      isDriver: widget.isDriver ? true : false,
                                      instituteName: _employeeList[index]
                                          ['instituteName'],
                                      isActive: false,
                                      exists: _employeeList[index]
                                                  ['profilePicture'] ==
                                              null
                                          ? false
                                          : true,
                                      id: _employeeList[index]['_id'],
                                      role: _employeeList[index]['role'],
                                      userName: _employeeList[index]
                                          ['userName'],
                                      aadharNumber: _employeeList[index]
                                              ['adharNumber']
                                          .toString(),
                                      instituteType: _employeeList[index]
                                          ['instituteType'],
                                      contactNumber: _employeeList[index]
                                              ['contactNumber']
                                          .toString(),
                                      division: User.userRole != 'superAdmin'
                                          ? _employeeList[index]['division']
                                          : null,
                                      grade: User.userRole != 'superAdmin'
                                          ? _employeeList[index]['grade']
                                          : null,
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
                                    blurRadius: 10,
                                    spreadRadius: 0.5,
                                  )
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  _employeeList[index]
                                                      ['division'],
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Text(
                                                  'Institute Name: ',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  _employeeList[index]
                                                      ['instituteName'],
                                                  style:
                                                      TextStyle(fontSize: 14),
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  _employeeList[index]['grade'],
                                                  style:
                                                      TextStyle(fontSize: 14),
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
                                                      style: TextStyle(
                                                          fontSize: 14),
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
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    )
                                                  ],
                                                ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      MaterialButton(
                                        minWidth: 35,
                                        padding: EdgeInsets.zero,
                                        shape: CircleBorder(
                                          side: BorderSide(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          popDialog(
                                              title: User.userRole == 'admin' &&
                                                      !widget.isDriver
                                                  ? "Reject Employee"
                                                  : (User.userRole == 'admin' &&
                                                          widget.isDriver)
                                                      ? "Reject Driver"
                                                      : (User
                                                                  .userRole ==
                                                              'employee')
                                                          ? "Reject Customer"
                                                          : "Reject Admin",
                                              content:
                                                  'Do you want to reject this registration?',
                                              context: context,
                                              buttonTitle: 'Reject',
                                              onPress: () {
                                                setState(() {
                                                  _loading = true;
                                                });

                                                _rejectUser(
                                                    id: _employeeList[index]
                                                        ['_id']);
                                                _sendNotification(
                                                    title: "Request Rejected",
                                                    fcmToken:
                                                        _employeeList[index]
                                                            ['fcmToken'],
                                                    message: User.userRole ==
                                                                'admin' &&
                                                            !widget.isDriver
                                                        ? "You have been rejected as an employee. Please login now"
                                                        : (User.userRole ==
                                                                    'admin' &&
                                                                widget.isDriver)
                                                            ? "You have been rejected as a driver. Please contact admin"
                                                            : (User.userRole ==
                                                                    'employee')
                                                                ? "You have been rejected as a customer. Please contact admin"
                                                                : "You have been rejected as an admin. Please contact superadmin");
                                                Navigator.pop(context);
                                              });
                                        },
                                        child: Icon(
                                          Icons.close,
                                        ),
                                      ),
                                      MaterialButton(
                                        minWidth: 35,
                                        elevation: 10,
                                        shape: CircleBorder(
                                            side: BorderSide(
                                                color: Colors.green)),
                                        onPressed: () {
                                          popDialog(
                                              title: User.userRole == 'admin' &&
                                                      !widget.isDriver
                                                  ? "Approve Employee"
                                                  : (User.userRole == 'admin' &&
                                                          widget.isDriver)
                                                      ? "Approve Driver"
                                                      : (User
                                                                  .userRole ==
                                                              'employee')
                                                          ? "Approve Customer"
                                                          : "Approve Admin",
                                              content:
                                                  'Do you want to approve this registration?',
                                              context: context,
                                              buttonTitle: 'Approve',
                                              onPress: () {
                                                setState(() {
                                                  _loading = true;
                                                });
                                                _approveUser(
                                                  id: _employeeList[index]
                                                      ['_id'],
                                                );
                                                _sendNotification(
                                                    fcmToken:
                                                        _employeeList[index]
                                                            ['fcmToken'],
                                                    title: "Request Approved",
                                                    message: User.userRole ==
                                                                'admin' &&
                                                            !widget.isDriver
                                                        ? "You have been approved as an employee. Please login now"
                                                        : (User.userRole ==
                                                                    'admin' &&
                                                                widget.isDriver)
                                                            ? "You have been approved as a driver. Please login now"
                                                            : (User.userRole ==
                                                                    'employee')
                                                                ? "You have been approved as a customer. Please login"
                                                                : "You have been approved as an admin. Please login");
                                                Navigator.pop(context);
                                              });
                                        },
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  )
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
