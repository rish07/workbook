import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';
import 'dart:convert';

import 'package:workbook/widget/popUpDialog.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
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
      appBar: AppBar(
        centerTitle: true,
        title: Text('View all employees'),
        backgroundColor: teal1,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Center(
          child: ListView.builder(
              itemCount: _employeeList.length,
              itemBuilder: (context, index) {
                if (_employeeList[index]['approved'] == false) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2,
                              spreadRadius: 0.2,
                              offset: Offset(5, 5),
                            )
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Name: ',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _employeeList[index]['userName'],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Division: ',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _employeeList[index]['division'],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Grade: ',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _employeeList[index]['grade'],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                    minWidth:
                                        MediaQuery.of(context).size.width * 0.1,
                                    color: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                                    child: Icon(Icons.check),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                    minWidth:
                                        MediaQuery.of(context).size.width * 0.1,
                                    color: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                                    child: Icon(Icons.close),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )),
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
