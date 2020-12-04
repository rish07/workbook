import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';
import 'package:workbook/ad_manager.dart';
import '../../constants.dart';
import '../../user.dart';

const String testDevice = null;

class ViewTasks extends StatefulWidget {
  @override
  _ViewTasksState createState() => _ViewTasksState();
}

class _ViewTasksState extends State<ViewTasks> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  Future _getTasks() async {
    var response = await http.post(
      "$baseUrl/task/fetch",
      body: {
        "userID": User.userEmail,
        "jwtToken": User.userJwtToken,
        "instituteName": User.instituteName,
        'grade': User.grade,
        "division": User.division,
      },
    );
    print(response.body);
    setState(() {
      _loading = false;
    });
    if (json.decode(response.body)['statusCode'] == 200) {
      json.decode(response.body)['payload']['tasks'][0]?.forEach((element) {
        _taskList.add(element);
      });
      json.decode(response.body)['payload']['tasks'][1]?.forEach((element) {
        _taskList.add(element);
      });
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  BannerAd _bannerAd;
  bool _loading = false;
  List _taskList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTasks();
    setState(() {
      _loading = true;
    });
    if (Platform.isAndroid) {
      _bannerAd = createBannerAd()
        ..load()
        ..show();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tasks/Meetings',
          style: TextStyle(color: violet2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: violet2),
      ),
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _loading,
        child: Container(
          padding: EdgeInsets.all(16),
          child: _taskList.length == 0
              ? Center(
                  child: Text(
                    'No pending tasks',
                    style: TextStyle(fontSize: 30, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _taskList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(_taskList[index]['name']),
                          subtitle: Text(_taskList[index]['description']),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _taskList[index]['type'] == 'Meeting' ? Colors.deepPurple : (_taskList[index]['type'] == 'Task') ? Colors.teal : Colors.lightGreen,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _taskList[index]['type'],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 2,
                        ),
                      ],
                    );
                  }),
        ),
      ),
    );
  }
}
