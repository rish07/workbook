import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/view_divisions.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:workbook/widget/popUpDialog.dart';

class AddGrade extends StatefulWidget {
  @override
  _AddGradeState createState() => _AddGradeState();
}

class _AddGradeState extends State<AddGrade> {
  bool _isLoading = false;
  List toBeUploadedGrade = [];
  Future getGrades({String instituteName}) async {
    var response = await http.get("$baseUrl/fetchGrade/$instituteName");
    print('Response status: ${response.statusCode}');
    print(User.instituteName);
    print(response.body);
    List temp = json.decode(response.body)['payload']['grades'];
    temp.forEach((resp) {
      grades.add(resp);
    });
    grades = Set.of(grades).toList();
    setState(() {
      _isLoading = false;
    });
  }

  Future updateGD() async {
    grades.forEach((gra) {
      toBeUploadedGrade.add({"grade": gra});
    });

    var data = {"userID": User.userEmail, "instituteName": User.instituteName, "jwtToken": User.userJwtToken, "grade": toBeUploadedGrade, "division": divisions};
    String body = json.encode(data);
    print(body);
    var response = await http.post("$baseUrl/admin/setGD", body: body, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(msg: 'Updated');
      setState(() {
        _isLoading = false;
      });
    } else {
      Fluttertoast.showToast(msg: 'Error');
    }
  }

  Future getDivision({String instituteName}) async {
    var response = await http.get("$baseUrl/fetchDivision/$instituteName");
    print('Response status: ${response.statusCode}');

    divisionData = json.decode(response.body)['payload']['divisions'];
  }

  bool _isEdit = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    getDivision(instituteName: User.instituteName);
    getGrades(instituteName: User.instituteName);
  }

  Future addDivision({BuildContext context, String label, int index, List division}) {
    final controller = TextEditingController();
    String name;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "CANCEL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: violet2,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please enter a name');
                  } else {
                    divisions.add({'division': name, 'grade': grades[index]});
                    print(divisions);
                    print(grades);
                    controller.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'ADD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: violet2,
                  ),
                ),
              )
            ],
            title: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Add a new $label',
                    style: TextStyle(
                      color: violet2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: 'Enter ${StringUtils.capitalize(label)} Name',
                      hintStyle: TextStyle(
                        color: violet1,
                      )),
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(violet2),
        backgroundColor: Colors.transparent,
      ),
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Grades and Divisions',
            style: TextStyle(color: violet2, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: violet2),
          actions: [
            _isEdit
                ? IconButton(
                    icon: Icon(
                      Icons.check,
                      color: violet2,
                    ),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await updateGD();
                      setState(() {
                        _isEdit = !_isEdit;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEdit = !_isEdit;
                      });
                    })
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Grades',
                    style: TextStyle(color: violet2, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: grades.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              shadowColor: Colors.grey,
                              child: GestureDetector(
                                onLongPress: () {
                                  if (_isEdit) {
                                    popDialog(
                                        content: 'Do you want to delete this grade?',
                                        title: 'Delete Grade',
                                        context: context,
                                        buttonTitle: 'Delete',
                                        onPress: () {
                                          setState(() {
                                            grades.removeAt(index);
                                          });
                                        });
                                  }
                                },
                                child: ListTile(
                                  title: Text(grades[index]),
                                  trailing: _isEdit
                                      ? Container(
                                          width: MediaQuery.of(context).size.width * 0.32,
                                          child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(32),
                                            ),
                                            padding: EdgeInsets.all(2),
                                            color: violet1,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Add Division',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              return addDivision(context: context, index: index, division: divisions, label: 'division');
                                            },
                                          ),
                                        )
                                      : IconButton(
                                          icon: Icon(Icons.navigate_next),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                  child: ViewDivisions(
                                                    gradeName: grades[index],
                                                  ),
                                                  type: PageTransitionType.rightToLeft),
                                            );
                                          }),
                                ),
                              ),
                            );
                          }),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        drawer: buildDrawer(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _isEdit
            ? Padding(
                padding: EdgeInsets.all(16.0),
                child: FloatingActionButton.extended(
                  backgroundColor: violet2,
                  onPressed: () {
                    return addGrade(context: context, label: 'grade');
                  },
                  label: Text('Add Grade'),
                ),
              )
            : null,
      ),
    );
  }

  Future addGrade({BuildContext context, String label}) {
    final controller = TextEditingController();
    String name;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "CANCEL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: violet2,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please enter a name');
                  } else if (grades.contains(controller.text)) {
                    Fluttertoast.showToast(msg: 'Duplicate Entry', gravity: ToastGravity.TOP);
                  } else {
                    grades.add(name);
                    controller.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'ADD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: violet2,
                  ),
                ),
              )
            ],
            title: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Add a new $label',
                    style: TextStyle(
                      color: violet2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: 'Enter ${StringUtils.capitalize(label)} Name',
                      hintStyle: TextStyle(
                        color: violet1,
                      )),
                ),
              ],
            ),
          );
        });
  }
}
