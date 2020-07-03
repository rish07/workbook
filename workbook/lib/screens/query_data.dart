import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/query_dashboard.dart';

class QueryData extends StatefulWidget {
  @override
  _QueryDataState createState() => _QueryDataState();
}

class _QueryDataState extends State<QueryData> {
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
          title: Text('Queries'),
          bottom: TabBar(tabs: [
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
          QueryDashboard(
            total: 50,
            unRegistered: 30,
            registered: 20,
          ),
          QueryDashboard(),
          QueryDashboard()
        ]),
      ),
    );
  }
}
