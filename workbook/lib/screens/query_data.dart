import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/query_dashboard.dart';
import 'package:workbook/screens/query_status.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/user.dart';

class QueryData extends StatefulWidget {
  @override
  _QueryDataState createState() => _QueryDataState();
}

class _QueryDataState extends State<QueryData> {
  Future generateTickets() async {
    print('working');
    for (int i = 0; i < 10; i++) {
      var response = await http.post('$baseUrl/guest/createQuery', body: {
        "userName": "Test $i",
        "userID": "test$i@test.com",
        "message":
            "sacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdocsacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdocsacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdocsacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdocsacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdocsacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdocsacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdocsacbiucbabcoudscodbcadbc. UDCSDIUCBSDUCHSDCiubic ui.soduchsdoc",
        "fcmToken": User.userFcmToken,
        "instituteName": "IEEE",
        "contactNumber": 217228736483.toString()
      });
      print(response.body);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: teal2,
          centerTitle: true,
          title: GestureDetector(
              onDoubleTap: () {
                generateTickets();
              },
              child: Text('Queries')),
          bottom: TabBar(indicatorColor: Colors.white, tabs: [
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.watch_later),
              text: 'Pending',
            ),
            Tab(
              icon: Icon(Icons.check),
              text: 'Approved',
            )
          ]),
        ),
        body: TabBarView(children: [
          QueryDashboard(),
          QueryStatus(
            isPending: true,
          ),
          QueryStatus(
            isPending: false,
          ),
        ]),
      ),
    );
  }
}
