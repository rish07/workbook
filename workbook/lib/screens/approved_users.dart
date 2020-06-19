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

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  int counter = 0;
  bool _loading = false;
  List _employeeList = [];

  Future _getUsers() async {
    var response = await http.post(
      User.userRole == 'admin'
          ? "$baseUrl/admin/viewAllEmployees"
          : "$baseUrl/employee/activeCustomer",
      body: User.userRole == 'admin'
          ? {
              "instituteName": User.instituteName,
            }
          : {
              "employeeID": User.userEmail,
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
          User.userRole == 'admin' ? 'Active Employees' : 'Active Customers',
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
                        var res = await _checkExist(
                            role: _employeeList[index]['role'],
                            id: _employeeList[index]['_id']);
                        print('hereeeeeeeeeeeeeeeeee $res');

                        Navigator.push(
                            context,
                            PageTransition(
                                child: RequestProfilePage(
                                  exists: res,
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
