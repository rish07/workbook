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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
          backgroundColor: violet2,
          centerTitle: true,
          title: GestureDetector(child: Text('Queries')),
          bottom: TabBar(labelPadding: EdgeInsets.symmetric(horizontal: 10), indicatorSize: TabBarIndicatorSize.label, isScrollable: true, indicatorColor: Colors.white, tabs: [
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.watch_later),
              text: 'Pending',
            ),
            Tab(
              icon: Icon(Icons.warning),
              text: 'Unregistered',
            ),
            Tab(
              icon: Icon(Icons.check),
              text: 'Registered',
            ),
          ]),
        ),
        body: TabBarView(children: [
          QueryDashboard(),
          QueryStatus(
            isRegistered: false,
            isPending: true,
          ),
          QueryStatus(
            isRegistered: false,
            isPending: false,
          ),
          QueryStatus(
            isRegistered: true,
            isPending: false,
          ),
        ]),
      ),
    );
  }
}
