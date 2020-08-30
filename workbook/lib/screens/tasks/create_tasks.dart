import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/widget/popUpDialog.dart';
import '../../user.dart';

class CreateTask extends StatefulWidget {
  final bool isAdmin;

  const CreateTask({Key key, this.isAdmin}) : super(key: key);
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  String _selectedType;
  String _selectedGrade;
  String _selectedDivision;
  bool _isLoading = false;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  List gradeDivision = [];
  bool isOther = false;
  bool _validateDescription = false;
  bool _validateTaskName = false;
  bool _validateGrade = false;
  bool _validateDivision = false;
  bool _validateType = false;

  List types = ['Task', 'Meeting', 'Other'];
  Future getGrades() async {
    var response = await http.get("$baseUrl/fetchGrade/${User.instituteName}");
    print('Response status: ${response.statusCode}');
    List temp = json.decode(response.body)['payload']['grades'];
    temp.forEach((resp) {
      grades.add(resp);
    });
    grades = Set.of(grades).toList();
    setState(() {
      _isLoading = false;
    });
  }

  Future getDivision() async {
    var response = await http.get("$baseUrl/fetchDivision/${User.instituteName}");
    print('Response status: ${response.statusCode}');
    setState(() {
      divisionData = json.decode(response.body)['payload']['divisions'];
    });
  }

  Future _div() async {
    await getDivision();
    gradeDivision.clear();
    print(divisionData);
    divisionData.forEach((element) {
      if (element['grade'] == _selectedGrade) {
        gradeDivision.add(element['division']);
      }
    });
    gradeDivision = Set.of(gradeDivision).toList();
    print(gradeDivision);
  }

  Future _createTask() async {
    setState(() {
      _isLoading = true;
    });
    print(_selectedType);
    var response = await http.post(
      widget.isAdmin ? '$baseUrl/task/adminCreate' : '$baseUrl/task/employeeCreate',
      body: widget.isAdmin
          ? {
              "userID": User.userEmail,
              "jwtToken": User.userJwtToken,
              "instituteName": User.instituteName,
              "type": _selectedType,
              "topic": "${User.instituteName.replaceAll(RegExp(r' '), '_')}",
              "description": _descriptionController.text.toString(),
              "name": _taskNameController.text.toString().isEmpty ? _selectedType : _taskNameController.text.toString(),
            }
          : {
              "userID": User.userEmail,
              "jwtToken": User.userJwtToken,
              "instituteName": User.instituteName,
              "type": _selectedType,
              "topic": "${User.grade.replaceAll(RegExp(r' '), '_')}${User.division.replaceAll(RegExp(r' '), '_')}",
              "description": _descriptionController.text.toString(),
              "grade": _selectedGrade,
              "division": _selectedDivision,
              "name": _taskNameController.text.toString().isEmpty ? _selectedType : _taskNameController.text.toString(),
            },
    );
    print(response.body);
    setState(() {
      _isLoading = false;
    });
    if (json.decode(response.body)['statusCode'] == 200) {
      popDialog(
          title: 'Successful',
          content: 'The $_selectedType was created successfully.',
          context: context,
          buttonTitle: 'Okay',
          onPress: () {
            Navigator.push(
              context,
              PageTransition(child: DashBoard(), type: PageTransitionType.fade),
            );
          });
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGrades();
    User.userRole != 'admin' ? _fcm.subscribeToTopic(User.instituteName.replaceAll(RegExp(r' '), '_')) : {};
    User.userRole == 'customer' ? _fcm.subscribeToTopic('${User.grade.replaceAll(RegExp(r' '), '_')}${User.division.replaceAll(RegExp(r' '), '_')}') : {};
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionController.dispose();
    _taskNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: violet1,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Create Task/Meeting',
            style: TextStyle(color: violet1),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                      child: Text(
                        'Type: ',
                        style: TextStyle(fontSize: 20, color: violet2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      hint: Text(
                        'Select Type',
                        style: TextStyle(color: violet1, fontSize: 18),
                      ),
                      decoration: InputDecoration(
                        errorText: _validateType ? 'Please choose an option' : null,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: violet1),
                        ),
                      ),
                      items: types.map((location) {
                        return DropdownMenuItem(
                          child: AutoSizeText(
                            location,
                            maxLines: 1,
                            style: TextStyle(color: violet1),
                          ),
                          value: location,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          value == 'Other' ? isOther = true : isOther = false;
                          _selectedType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              isOther
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                            child: Text(
                              'Task Name: ',
                              style: TextStyle(fontSize: 20, color: violet2),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            autocorrect: true,
                            controller: _taskNameController,
                            onTap: () {
//                  setState(() {
//                    _validateDescription = false;
//                  });
                            },
                            cursorRadius: Radius.circular(8),
                            cursorColor: violet1,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
//                controller: _descriptionController,
                            style: TextStyle(
                              fontSize: 18,
                              color: violet1,
                            ),
                            decoration: InputDecoration(
                              errorText: _validateTaskName ? "This field can't be empty" : null,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                              isDense: true,
                              errorMaxLines: 1,
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: violet1, width: 2),
                              ),
                              errorStyle: TextStyle(height: 0, fontSize: 10),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
//                  errorText: _validateDescription ? "This field can't be empty" : null,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: violet1, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: violet1, width: 2.0),
                              ),
                              fillColor: Colors.lightBlueAccent,
                              hintText: "Name of the task",
                              alignLabelWithHint: true,
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: violet1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: isOther ? 20 : 0,
              ),
              User.userRole == 'employee'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                            child: Text(
                              'Grade: ',
                              style: TextStyle(fontSize: 20, color: violet2),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField(
                            hint: Text(
                              'Select Grade',
                              style: TextStyle(color: violet1, fontSize: 18),
                            ),
                            decoration: InputDecoration(
                              errorText: _validateGrade ? 'Please choose an option' : null,
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: violet1),
                              ),
                            ),
                            items: grades.map((location) {
                              return DropdownMenuItem(
                                child: AutoSizeText(
                                  location,
                                  maxLines: 1,
                                  style: TextStyle(color: violet1),
                                ),
                                value: location,
                              );
                            }).toList(),
                            onChanged: (value) async {
                              setState(() {
                                _selectedGrade = value;
                              });
                              await _div();
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: User.userRole == 'employee' ? 20 : 0,
              ),
              User.userRole == 'employee'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                            child: Text(
                              'Division: ',
                              style: TextStyle(fontSize: 20, color: violet2),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField(
                            hint: Text(
                              'Select Division',
                              style: TextStyle(color: violet1, fontSize: 18),
                            ),
                            decoration: InputDecoration(
                              errorText: _validateDivision ? 'Please choose an option' : null,
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: violet1),
                              ),
                            ),
                            items: gradeDivision.map((location) {
                              return DropdownMenuItem(
                                child: AutoSizeText(
                                  location,
                                  maxLines: 1,
                                  style: TextStyle(color: violet1),
                                ),
                                value: location,
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDivision = value;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: User.userRole == 'employee' ? 40 : 0,
              ),
              Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                child: Text(
                  'Description: ',
                  style: TextStyle(fontSize: 20, color: violet2),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  autocorrect: true,
                  maxLines: 10,
                  onTap: () {
//                  setState(() {
//                    _validateDescription = false;
//                  });
                  },
                  cursorRadius: Radius.circular(8),
                  cursorColor: violet1,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _descriptionController,
                  style: TextStyle(
                    fontSize: 18,
                    color: violet1,
                  ),
                  decoration: InputDecoration(
                    errorText: _validateDescription ? "This field can't be empty!" : null,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                    isDense: true,
                    errorMaxLines: 1,
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violet1, width: 2),
                    ),
                    errorStyle: TextStyle(height: 0, fontSize: 10),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
//                  errorText: _validateDescription ? "This field can't be empty" : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violet1, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violet1, width: 2.0),
                    ),
                    fillColor: Colors.lightBlueAccent,
                    hintText: "Start typing...",
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(
                      fontSize: 20,
                      color: violet1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 100.0),
                child: MaterialButton(
                  padding: EdgeInsets.all(16),
                  color: violet2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  onPressed: () async {
                    setState(() {
                      isOther ? (_taskNameController.text.isEmpty ? _validateTaskName = true : _validateTaskName = false) : {};
                      _selectedType == null ? _validateType = true : _validateType = false;
                      User.userRole == 'employee' ? (_selectedGrade == null ? _validateGrade = true : _validateGrade = false) : {};
                      User.userRole == 'employee' ? (_selectedDivision == null ? _validateDivision = true : _validateDivision = false) : {};
                      _descriptionController.text.isEmpty ? _validateDescription = true : _validateDescription = false;
                    });
                    if (!_validateDescription && !_validateTaskName && !_validateType && !_validateGrade && !_validateDivision) {
                      await _createTask();
                    }
                  },
                  child: Text(
                    User.userRole == 'admin' ? 'Send to all' : 'Send to Customer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
