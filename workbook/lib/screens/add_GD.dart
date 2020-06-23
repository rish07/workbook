import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddGD extends StatefulWidget {
  @override
  _AddGDState createState() => _AddGDState();
}

class _AddGDState extends State<AddGD> {
  List toBeUploadedGrade = [];

  List tobeUploadedDivision = [];
  bool _isLoading = false;
  Future getGrades({String instituteName}) async {
    var response = await http.get("$baseUrl/fetchGrade/$instituteName");
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

  Future updateGD() async {
    divisions.forEach((div) {
      tobeUploadedDivision.add({"division": div});
    });
    grades.forEach((gra) {
      toBeUploadedGrade.add({"grade": gra});
    });

    var data = {
      "instituteName": User.instituteName,
      "grade": toBeUploadedGrade,
      "division": tobeUploadedDivision
    };
    String body = json.encode(data);
    var response =
        await http.post("$baseUrl/admin/setGD", body: body, headers: {
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
    List temp = json.decode(response.body)['payload']['divisions'];
    temp.forEach((resp) {
      divisions.add(resp);
    });
    divisions = Set.of(divisions).toList();
    setState(() {
      _isLoading = false;
    });
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(teal2),
        backgroundColor: Colors.transparent,
      ),
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Grades and Divisions',
            style: TextStyle(color: teal2, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: teal2),
          actions: [
            _isEdit
                ? IconButton(
                    icon: Icon(
                      Icons.check,
                      color: teal2,
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
                    style: TextStyle(color: teal2, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: grades.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              shadowColor: Colors.grey,
                              child: ListTile(
                                title: Text(grades[index]),
                                trailing: _isEdit
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 25,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            grades.removeAt(index);
                                          });
                                        })
                                    : null,
                              ),
                            );
                          }),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Divisions',
                    style: TextStyle(color: teal2, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: _isEdit
                          ? MediaQuery.of(context).size.height * 0.35
                          : MediaQuery.of(context).size.height * 0.4,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: divisions.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              shadowColor: Colors.grey,
                              child: ListTile(
                                title: Text(divisions[index]),
                                trailing: _isEdit
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 25,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            divisions.removeAt(index);
                                          });
                                        })
                                    : null,
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
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.03),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton.extended(
                          backgroundColor: teal2,
                          onPressed: () {
                            return addGD(
                                context: context,
                                label: 'division',
                                toBeAdded: divisions);
                          },
                          label: Text('Add Division'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.02),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton.extended(
                          backgroundColor: teal2,
                          onPressed: () {
                            return addGD(
                                context: context,
                                label: 'grade',
                                toBeAdded: grades);
                          },
                          label: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Add Grade'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Future addGD({BuildContext context, String label, List toBeAdded}) {
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
                    color: teal2,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please enter a name');
                  } else if (toBeAdded.contains(controller.text)) {
                    Fluttertoast.showToast(
                        msg: 'Duplicate Entry', gravity: ToastGravity.TOP);
                  } else {
                    toBeAdded.add(name);
                    controller.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'ADD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: teal2,
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
                      color: teal2,
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
                        color: teal1,
                      )),
                ),
              ],
            ),
          );
        });
  }
}
