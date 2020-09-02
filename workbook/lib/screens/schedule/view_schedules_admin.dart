import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:workbook/screens/schedule/view_schedule.dart';
import '../../constants.dart';
import '../../user.dart';

class ViewScheduleAdmin extends StatefulWidget {
  @override
  _ViewScheduleAdminState createState() => _ViewScheduleAdminState();
}

class _ViewScheduleAdminState extends State<ViewScheduleAdmin> {
  bool _isLoading = false;
  List _schedules = [];

  Future _getAllSchedules() async {
    var response = await http.post("$baseUrl/admin/fetchAllSchedule", body: {
      "userID": User.userEmail,
      "jwtToken": User.userJwtToken,
      "instituteName": User.instituteName,
    });
    print(response.body);
    setState(() {
      _isLoading = false;
    });
    if (json.decode(response.body)['statusCode'] == 200) {
      setState(() {
        _schedules = json.decode(response.body)['payload']['schedule'];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllSchedules();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: violet1,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Schedule',
            style: TextStyle(color: violet1, fontSize: 22),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(16),
          child: _schedules.length == 0
              ? Center(
                  child: Text(
                    'No Schedule Allotted',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(_schedules[index]['grade']),
                        subtitle: Text(_schedules[index]['division']),
                        onTap: () {
                          if (_schedules[index]['schedule'] != null) {
                            Navigator.push(
                              context,
                              PageTransition(
                                  child: ViewSchedule(
                                    url: _schedules[index]['schedule'],
                                  ),
                                  type: PageTransitionType.rightToLeft),
                            );
                          } else {
                            Fluttertoast.showToast(context, msg: 'No schedule found!');
                          }
                        });
                  }),
        ),
      ),
    );
  }
}
