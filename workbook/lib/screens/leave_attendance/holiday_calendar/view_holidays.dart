import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/screens/leave_attendance/holiday_calendar/create_holiday.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import '../../../user.dart';

const String testDevice = null;

class ViewHolidays extends StatefulWidget {
  @override
  _ViewHolidaysState createState() => _ViewHolidaysState();
}

class _ViewHolidaysState extends State<ViewHolidays> {
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

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  BannerAd _bannerAd;
  List<TableRow> _rows = [
    TableRow(children: [
      Container(
        padding: EdgeInsets.all(8),
        child: Text(
          'Date',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        padding: EdgeInsets.all(8),
        child: Text(
          'Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ]),
  ];
  bool _isLoading = false;

  Future _getInstituteHolidays() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post("$baseUrl/getHolidays", body: {
        "instituteName": User.instituteName,
      });
      print(response.body);
      if (json.decode(response.body)['statusCode'] == 200) {
        json.decode(response.body)['payload']['holidays'].forEach((element) {
          _rows.add(TableRow(children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                DateFormat.yMMMMd().format(
                  DateTime.fromMillisecondsSinceEpoch(int.parse(element['date'])),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                element['name'],
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ),
          ]));
        });
      } else {}
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
    _getInstituteHolidays();
    _bannerAd = createBannerAd()
      ..load()
      ..show();
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
          actions: [
            User.userRole == 'admin'
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: MaterialButton(
                      color: violet2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          PageTransition(child: CreateHoliday(), type: PageTransitionType.rightToLeft),
                        );
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Container(),
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
            'Holidays',
            style: TextStyle(
              color: violet2,
              fontSize: 22,
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Table(border: TableBorder.all(color: Colors.black), children: _rows),
          ),
        ),
      ),
    );
  }
}
