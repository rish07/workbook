import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';

class QueryStatus extends StatefulWidget {
  final bool isPending;

  const QueryStatus({Key key, this.isPending}) : super(key: key);
  @override
  _QueryStatusState createState() => _QueryStatusState();
}

class _QueryStatusState extends State<QueryStatus> {
  bool _isLoading = false;
  List pending = [];
  List approved = [];
  Future getAllQuery() async {
    var response = await http.post('$baseUrl/guest/getAllQuery', body: {
      "instituteName": "IEEE",
    });

    if (json.decode(response.body)['statusCode'] == 200) {
      List temp = json.decode(response.body)['payload']['query'];
      temp.forEach((element) {
        if (element['status'] == 'created') {
          pending.add(element);
        } else {
          approved.add(element);
        }
      });
      print(approved);
      print(pending);
    }
    setState(() {
      approved = Set.of(approved).toList();
      pending = Set.of(pending).toList();
      _isLoading = false;
    });
  }

  Future resolveQuery({String id}) async {
    var response = await http.post('$baseUrl/guest/unregister', body: {
      "id": id,
    });
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        getAllQuery();
      });
    }
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
      child: Container(
        padding: EdgeInsets.all(16),
        child: widget.isPending && pending.length == 0 && !_isLoading
            ? Center(
                child: Text(
                  'No Pending Queries',
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ),
              )
            : (!widget.isPending && approved.length == 0 && !_isLoading)
                ? Center(
                    child: Text(
                      'No Approved Queries',
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemCount:
                        widget.isPending ? pending.length : approved.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(widget.isPending
                              ? pending[index]['userName']
                              : approved[index]['userName']),
                          Text(widget.isPending
                              ? pending[index]['message']
                              : approved[index]['userName']),
                          widget.isPending
                              ? MaterialButton(
                                  color: teal1,
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await resolveQuery(
                                        id: pending[index]['_id']);
                                  },
                                  child: Text(
                                    'Resolve query',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Container(
                                  child: Row(
                                    children: [
                                      Text('Status: '),
                                      Text(approved[index]['status']),
                                    ],
                                  ),
                                )
                        ],
                      ));
                    }),
      ),
    );
  }
}
