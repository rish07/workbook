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

import 'package:workbook/widget/popUpDialog.dart';

class ApproveUser extends StatefulWidget {
  @override
  _ApproveUserState createState() => _ApproveUserState();
}

class _ApproveUserState extends State<ApproveUser> {
  int counter = 0;
  bool _loading = false;
  List _employeeList = [];

  Future _getUsers() async {
    var response = await http.post(
      User.userRole == 'admin'
          ? "$baseUrl/admin/viewAllEmployees"
          : "$baseUrl/employee/viewAllCustomers",
      body: {
        "instituteName": User.instituteName,
      },
    );
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var employees = User.userRole == 'admin'
          ? json.decode(response.body)['payload']['employees']
          : json.decode(response.body)['payload']['customer'];
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
        User.userRole == 'admin'
            ? "$baseUrl/admin/approveEmployee"
            : "$baseUrl/employee/approveCustomer",
        body: User.userRole == 'admin'
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

  Future _rejectEmployee({String id}) async {
    print('working');
    var response = await http.post(
        User.userRole == 'admin'
            ? "$baseUrl/admin/rejectEmployee"
            : "$baseUrl/employee/rejectCustomer",
        body: User.userRole == 'admin'
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

  Future<bool> _checkExist({String role, String id}) async {
    var response = await http.get('$baseUrl/getUserProfile/$role/$id');
    print('$baseUrl/getUserProfile/$role/$id');
    print(response.body);
    if (response.body.isNotEmpty) {
      return true;
    } else
      return false;
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
          User.userRole == 'admin' ? 'Approve Employees' : 'Approve Customers',
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
//                            var res = await _checkExist(
//                                role: _employeeList[index]['role'],
//                                id: _employeeList[index]['_id']);
//                            print('hereeeeeeeeeeeeeeeeee $res');
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: RequestProfilePage(
                                      id: _employeeList[index]['_id'],
                                      role: _employeeList[index]['role'],
                                      userName: _employeeList[index]
                                          ['userName'],
                                      aadharNumber: _employeeList[index]
                                              ['adharNumber']
                                          .toString(),
                                      contactNumber: _employeeList[index]
                                              ['contactNumber']
                                          .toString(),
                                      division: _employeeList[index]
                                          ['division'],
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
                                      Row(
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
                                      ),
                                      Row(
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
                                              title: User.userRole == 'admin'
                                                  ? "Reject Employee"
                                                  : "Reject Customer",
                                              content:
                                                  'Do you want to reject this registration?',
                                              context: context,
                                              buttonTitle: 'Reject',
                                              onPress: () {
                                                _loading = true;
                                                _rejectEmployee(
                                                    id: _employeeList[index]
                                                        ['_id']);
                                                _sendNotification(
                                                    title: "Request Rejected",
                                                    fcmToken:
                                                        _employeeList[index]
                                                            ['fcmToken'],
                                                    message: User.userRole ==
                                                            'admin'
                                                        ? "You have been rejected as an employee. Please login now"
                                                        : "You have been rejected as a customer. Please contact admin");
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
                                              title: User.userRole == 'admin'
                                                  ? "Approve Employee"
                                                  : "Approve Customer",
                                              content:
                                                  'Do you want to approve this registration?',
                                              context: context,
                                              buttonTitle: 'Approve',
                                              onPress: () {
                                                _loading = true;
                                                User.userRole == 'admin'
                                                    ? _approveUser(
                                                        id: _employeeList[index]
                                                            ['_id'])
                                                    : _approveUser(
                                                        id: _employeeList[index]
                                                            ['_id'],
                                                      );
                                                _sendNotification(
                                                    fcmToken:
                                                        _employeeList[index]
                                                            ['fcmToken'],
                                                    title: "Request Approved",
                                                    message: User.userRole ==
                                                            'admin'
                                                        ? "You have been approved as an employee. Please login now"
                                                        : "You have been approved as a customer. Please contact admin");
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
