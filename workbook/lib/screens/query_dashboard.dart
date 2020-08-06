import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_charts/multi_charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workbook/constants.dart';

class QueryDashboard extends StatefulWidget {
  @override
  _QueryDashboardState createState() => _QueryDashboardState();
}

class _QueryDashboardState extends State<QueryDashboard> {
  bool _isLoading = false;
  List _pending = [];
  List _registered = [];
  List _unregistered = [];

  Future getAllQuery() async {
    var response = await http.post('$baseUrl/guest/getAllQuery', body: {
      "instituteName": "IEEE",
    });

    List temp = json.decode(response.body)['payload']['query'];
    temp.forEach((element) {
      if (element['status'] == 'created') {
        _pending.add(element);
      } else if (element['status'] == 'unregistered') {
        _unregistered.add(element);
      } else {
        _registered.add(element);
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    getAllQuery();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: _isLoading
          ? Container(
              child: Center(
                child: Text(
                  'Loading..',
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: PieChart(
                  legendTextSize: 14,
                  sliceFillColors: [Colors.tealAccent, Colors.red, Colors.cyan],
                  legendItemPadding: EdgeInsets.all(8),
                  legendIconShape: LegendIconShape.Circle,
                  size: Size(MediaQuery.of(context).size.height * 0.3, MediaQuery.of(context).size.width * 0.9),
                  values: [
                    _registered.length / (_pending.length + _unregistered.length + _registered.length) * 100,
                    _unregistered.length / (_pending.length + _unregistered.length + _registered.length) * 100,
                    _pending.length / (_pending.length + _unregistered.length + _registered.length) * 100
                  ],
                  labels: ['Registered', 'Unregistered', 'Pending'],
                  legendPosition: LegendPosition.Bottom,
                ),
              ),
            ),
    );
  }
}
