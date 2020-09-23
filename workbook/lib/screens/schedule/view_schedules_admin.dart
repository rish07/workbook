import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:universal_io/io.dart';
import 'package:workbook/screens/schedule/view_schedule.dart';
import '../../ad_manager.dart';
import '../../constants.dart';
import '../../user.dart';

class ViewScheduleAdmin extends StatefulWidget {
  @override
  _ViewScheduleAdminState createState() => _ViewScheduleAdminState();
}

class _ViewScheduleAdminState extends State<ViewScheduleAdmin> {
  bool _isLoading = false;
  List _schedules = [];

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

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

  BannerAd _bannerAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllSchedules();
    print(User.userJwtToken);
    setState(() {
      _isLoading = true;
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
                        title: Text(_schedules[index]['grade_division'].split("_")[0]),
                        subtitle: Text(_schedules[index]['grade_division'].split("_")[1]),
                        onTap: () {
                          if (_schedules[index]['scheduleUrl'] != null) {
                            Navigator.push(
                              context,
                              PageTransition(
                                  child: ViewSchedule(
                                    url: _schedules[index]['scheduleUrl'],
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
