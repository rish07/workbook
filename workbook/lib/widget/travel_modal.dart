import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workbook/user.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/constants.dart';

class OpenBottomModal extends StatefulWidget {
  final String regId;

  final String userRole;

  const OpenBottomModal({Key key, this.regId, this.userRole}) : super(key: key);
  @override
  _OpenBottomModalState createState() => _OpenBottomModalState();
}

class _OpenBottomModalState extends State<OpenBottomModal> {
  final format = DateFormat("HH:mm");
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _selectedRouteName;
  String _selectedBoardingPoint;
  String _selectedDroppingPoint;
  String _selectedPickupTime;
  var body;

  Future _setRoute(String areaName, double cost, String time) async {
    Map boardingPoint = {};
    Map droppingPoint = {};
    routeData.forEach((element) {
      if (element['routeName'] == _selectedRouteName) {
        element['location'].forEach((location) {
          if (location['locationName'] == _selectedBoardingPoint) {
            setState(() {
              boardingPoint = location;
            });
          }
          if (location['locationName'] == _selectedDroppingPoint) {
            setState(() {
              droppingPoint = location;
            });
          }
        });
      }
    });
    setState(() {
      body = json.encode({
        "route": {
          "routeName": _selectedRouteName,
          "area": areaName,
          "boardingPoint": boardingPoint,
          "droppingPoint": droppingPoint,
          "pickUpTime": time,
          "cost": cost,
        },
        "id": widget.regId,
        "role": widget.userRole,
        "jwtToken": User.userJwtToken,
        "userID": User.userEmail,
      });
    });

    var response = await http.post(
      '$baseUrl/admin/addUserRoute',
      body: body,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(context, msg: 'Travel service added');
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(context, msg: 'Error, try again');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationNames = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timeController.dispose();
    _costController.dispose();
    _areaController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            children: <Widget>[
              Text(
                'Travel Details',
                textAlign: TextAlign.center,
                style: TextStyle(color: violet2, fontSize: 24),
              ),
              buildFieldEntry(label: 'Area', controller: _areaController, hint: 'Enter residence Area'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                      child: Text(
                        'Route: ',
                        style: TextStyle(fontSize: 20, color: violet2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: Colors.white),
                      child: DropdownButtonFormField(
                        hint: Text(
                          'Select Route',
                          style: TextStyle(color: violet1, fontSize: 18),
                        ),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                        ),
                        items: routeNames.map((route) {
                          return DropdownMenuItem(
                            child: AutoSizeText(
                              route,
                              maxLines: 1,
                              style: TextStyle(color: violet1),
                            ),
                            value: route,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRouteName = value;
                            locationNames = [];
                            routeData.forEach((element) {
                              if (element['routeName'] == _selectedRouteName) {
                                element['location'].forEach((location) {
                                  locationNames.add(location['locationName']);
                                });
                              }
                            });
                            locationNames = Set.of(locationNames).toList();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                      child: Text(
                        'Boarding Point: ',
                        style: TextStyle(fontSize: 20, color: violet2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: Colors.white),
                      child: DropdownButtonFormField(
                        hint: Text(
                          'Select Location',
                          style: TextStyle(color: violet1, fontSize: 18),
                        ),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                        ),
                        items: locationNames.map((route) {
                          return DropdownMenuItem(
                            child: AutoSizeText(
                              route,
                              maxLines: 2,
                              style: TextStyle(color: violet1),
                            ),
                            value: route,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBoardingPoint = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                      child: Text(
                        'Dropping Point: ',
                        style: TextStyle(fontSize: 20, color: violet2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: Colors.white),
                      child: DropdownButtonFormField(
                        hint: Text(
                          'Select Location',
                          style: TextStyle(color: violet1, fontSize: 18),
                        ),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                        ),
                        items: locationNames.map((route) {
                          return DropdownMenuItem(
                            child: AutoSizeText(
                              route,
                              maxLines: 1,
                              style: TextStyle(color: violet1),
                            ),
                            value: route,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDroppingPoint = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                      child: Text(
                        'Pick-up time: ',
                        style: TextStyle(fontSize: 20, color: violet2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DateTimeField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: 'Select Time',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      format: format,
                      onShowPicker: (context, currentValue) async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                        );
                        setState(() {
                          print(_timeController.text.toString());
                          _selectedPickupTime = _timeController.text.toString();
                        });
                        return DateTimeField.convert(time);
                      },
                    ),
                    flex: 2,
                  ),
                ],
              ),
              buildFieldEntry(label: 'Cost', controller: _costController, hint: 'Enter cost per month', textInputType: TextInputType.number),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: MediaQuery.of(context).size.width * 0.3),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  onPressed: () async {
                    await _setRoute(_areaController.text, double.parse(_costController.text), _selectedPickupTime);
                    print(body);
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  color: violet2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Padding buildFieldEntry({String label, TextEditingController controller, String hint, TextInputType textInputType}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
    child: Row(
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            child: Text(
              '$label: ',
              style: TextStyle(fontSize: 20, color: violet2),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: TextFormField(
              keyboardType: textInputType ?? null,
              autofocus: false,
              cursorColor: violet1,
              controller: controller,
              style: TextStyle(color: violet1),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8),
                hintText: hint,
                isDense: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: violet2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1, color: violet2),
                ),
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
