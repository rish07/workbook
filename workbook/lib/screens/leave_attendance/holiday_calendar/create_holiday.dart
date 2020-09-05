import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:http/http.dart' as http;

import '../../../user.dart';

class CreateHoliday extends StatefulWidget {
  @override
  _CreateHolidayState createState() => _CreateHolidayState();
}

class _CreateHolidayState extends State<CreateHoliday> {
  final TextEditingController _holidayNameController = TextEditingController();
  bool _isLoading = false;
  List _holidays = [];
  List _toSend = [];
  List _isSelected = [];
  DateTime _selectedDate;
  Future _getHolidays() async {
    try {
      var response = await http.get("$baseUrl/admin/defaultHolidays");
      print(response.body);
      if (json.decode(response.body)['statusCode'] == 200) {
        setState(() {
          _holidays = json.decode(response.body)['payload']['holidays'];
          for (int i = 0; i < _holidays.length; i++) {
            _isSelected.add(false);
          }
        });
      } else {}
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future _setHolidays() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post(
        "$baseUrl/admin/setHolidays",
        headers: {"content-type": "application/json"},
        body: json.encode({
          "instituteName": User.instituteName,
          "holidays": _toSend,
        }),
      );
      print(response.body);
      if (json.decode(response.body)['statusCode'] == 200) {
        Fluttertoast.showToast(context, msg: 'Holidays set successfully!');
        Navigator.pushReplacement(
          context,
          PageTransition(child: CreateHoliday(), type: PageTransitionType.fade),
        );
      } else {
        Fluttertoast.showToast(context, msg: 'Error');
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHolidays();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _holidayNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: MaterialButton(
                color: violet2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                onPressed: () async {
                  if (_toSend.isNotEmpty) {
                    await _setHolidays();
                  } else {
                    Fluttertoast.showToast(context, msg: 'Please choose holidays!');
                  }
                },
                child: Text(
                  'Send',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: violet2,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Set Holidays',
            style: TextStyle(
              color: violet2,
              fontSize: 22,
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: _holidays.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_holidays[index]['name']),
                subtitle: Text(
                  DateFormat.yMMMMd().format(
                    DateTime.fromMillisecondsSinceEpoch(int.parse(_holidays[index]['date'])),
                  ),
                ),
                trailing: IconButton(
                    icon: Icon(
                      _isSelected[index] ? Icons.check : Icons.add,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSelected[index] = !_isSelected[index];
                        if (_isSelected[index]) {
                          _toSend.add({
                            "name": _holidays[index]['name'],
                            "date": _holidays[index]['date'],
                          });
                        } else {
                          _toSend.removeWhere((element) => element['name'] == _holidays[index]['name']);
                        }
                        print(_toSend);
                      });
                    }),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            return showDialog(
                context: (context),
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                        child: Text(
                      'Add Holiday',
                      style: TextStyle(color: violet1),
                    )),
                    content: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextFormField(
                            autocorrect: true,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            cursorRadius: Radius.circular(8),
                            cursorColor: violet1,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            controller: _holidayNameController,
                            decoration: InputDecoration(
                              hintText: 'Holiday Name',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: violet2),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: violet2, width: 2),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Text(
                                    'Date: ',
                                    style: TextStyle(fontSize: 18, color: violet2),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: DateTimeField(
                                    format: DateFormat("yyyy-MM-dd"),
                                    onChanged: (dt) {
                                      _selectedDate = dt;
                                    },
                                    onShowPicker: (context, currentValue) {
                                      return showDatePicker(context: context, firstDate: DateTime(1900), initialDate: currentValue ?? DateTime.now(), lastDate: DateTime(2100));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      // usually buttons at the bottom of the dialog
                      new MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          color: violet2,
                          child: new Text(
                            'Proceed',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if (_holidayNameController.text.isNotEmpty && _selectedDate != null) {
                              setState(() {
                                _holidays.add({
                                  "name": _holidayNameController.text.toString(),
                                  "date": _selectedDate.millisecondsSinceEpoch.toString(),
                                });
                                _toSend.add({
                                  "name": _holidayNameController.text.toString(),
                                  "date": _selectedDate.millisecondsSinceEpoch.toString(),
                                });
                                _isSelected.add(true);
                                _holidayNameController.clear();
                                _selectedDate = null;
                              });
                            } else {
                              Fluttertoast.showToast(context, msg: 'Holiday Name and Date are required.');
                            }
                            Navigator.pop(context);
                          }),
                    ],
                  );
                });
          },
          label: Text('Add Holiday'),
          backgroundColor: violet2,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
