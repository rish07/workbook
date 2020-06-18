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

class ApproveEmployees extends StatefulWidget {
  @override
  _ApproveEmployeesState createState() => _ApproveEmployeesState();
}

class _ApproveEmployeesState extends State<ApproveEmployees> {
  int counter = 0;
  bool _loading = false;
  List _employeeList = [];

  Future _getEmployees() async {
    var response = await http.post(
      "https://app-workbook.herokuapp.com/admin/viewAllEmployees",
      body: {
        "instituteName": User.instituteName,
      },
    );
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var employees = json.decode(response.body)['payload']['employees'];
      for (var employee in employees) {
        _employeeList.add(employee);
      }
      print(_employeeList);
    } else {
      throw Exception('Failed to load the employees');
    }
  }

  Future _approveEmployee({String id}) async {
    print('working');
    var response = await http.post(
        'https://app-workbook.herokuapp.com/admin/approveEmployee',
        body: {"id": id});
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
      _getEmployees();
    } else {
      throw Exception('Failed to load the employees');
    }
  }

  Future _rejectEmployee({String id}) async {
    print('working');
    var response = await http.post(
        'https://app-workbook.herokuapp.com/admin/rejectEmployee',
        body: {"id": id});
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
      _getEmployees();
    } else {
      throw Exception('Failed to load the employees');
    }
  }

  Future _sendNotification(
      {String fcmToken, String message, String title}) async {
    var response = await http.post(
        'https://app-workbook.herokuapp.com/sendNotification',
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
    _getEmployees();
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
          'Approve employees',
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
                if (_employeeList[index]['approved'] == false) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: RequestProfilePage(
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
                                spreadRadius: 2,
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
                                          title: "Reject Employee",
                                          content:
                                              'Do you want to reject the registration of this employee?',
                                          context: context,
                                          buttonTitle: 'Reject',
                                          onPress: () {
                                            _loading = true;
                                            _rejectEmployee(
                                                id: _employeeList[index]
                                                    ['_id']);
                                            _sendNotification(
                                                title: "Request Rejected",
                                                fcmToken: _employeeList[index]
                                                    ['fcmToken'],
                                                message:
                                                    "You have been rejected as an employee. Please contact the admin");
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
                                        side: BorderSide(color: Colors.green)),
                                    onPressed: () {
                                      popDialog(
                                          title: "Approve Employee",
                                          content:
                                              'Do you want to approve the registration of this employee?',
                                          context: context,
                                          buttonTitle: 'Approve',
                                          onPress: () {
                                            _loading = true;
                                            _approveEmployee(
                                                id: _employeeList[index]
                                                    ['_id']);
                                            _sendNotification(
                                                fcmToken: _employeeList[index]
                                                    ['fcmToken'],
                                                title: "Request Approved",
                                                message:
                                                    "You have been approved as an employee. Please login now");
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
