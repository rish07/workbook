import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/constants.dart';
import 'package:http/http.dart' as http;

import '../../ad_manager.dart';
import '../../user.dart';

const String testDevice = null;

class ViewSchedule extends StatefulWidget {
  final String url;
  final String grade;
  final String division;
  const ViewSchedule({Key key, this.url, this.grade, this.division}) : super(key: key);
  @override
  _ViewScheduleState createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<ViewSchedule> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;
  bool _exists = false;
  bool _isLoading = false;
  String imageUrl = '';
  Future _fetchUrl() async {
    var response = await http.post(
      "$baseUrl/admin/fetchSchedule",
      body: {
        "userID": User.userEmail,
        "jwtToken": User.userJwtToken,
        "grade": User.grade,
        "division": User.division,
        "instituteName": User.instituteName,
      },
    );
    print(response.body);
    setState(() {
      _isLoading = false;
    });
    if (json.decode(response.body)['statusCode'] == 200) {
      setState(() {
        imageUrl = json.decode(response.body)['payload']['schedule'];
        _exists = true;
      });
    }
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (User.userRole != 'admin') {
      _fetchUrl();
      setState(() {
        _exists = true;
        _isLoading = true;
      });
    }

    _bannerAd = createBannerAd()
      ..load()
      ..show();

    // TODO: Load a Banner Ad
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.url);
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
          child: User.userRole != 'admin' && !_exists
              ? Center(
                  child: Text(
                    'No Schedule Allotted',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                )
              : Center(
                  child: Image.network(
                    User.userRole != 'admin' ? imageUrl : widget.url,
                    fit: BoxFit.fill,
                  ),
                ),
        ),
      ),
    );
  }
}
