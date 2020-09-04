import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workbook/constants.dart';
import 'package:http/http.dart' as http;

import '../../../user.dart';

class CreateHoliday extends StatefulWidget {
  @override
  _CreateHolidayState createState() => _CreateHolidayState();
}

class _CreateHolidayState extends State<CreateHoliday> {
  List _holidays = [];
  List _toSend = [];
  List _isSelected = [];
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
  }

  Future _setHolidays() async {
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
      } else {}
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHolidays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                await _setHolidays();
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
                DateFormat.yMd().format(
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
                        _toSend.removeAt(index);
                      }
                      print(_toSend);
                    });
                  }),
            );
          },
        ),
      ),
    );
  }
}
