import 'dart:convert';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';

class QueryStatus extends StatefulWidget {
  final bool isPending;

  const QueryStatus({Key key, this.isPending}) : super(key: key);
  @override
  _QueryStatusState createState() => _QueryStatusState();
}

class _QueryStatusState extends State<QueryStatus> {
  List pending = [];
  List approved = [];
  List total = [];
  bool _isLoading = false;

  Future getAllQuery() async {
    var response = await http.post('$baseUrl/guest/getAllQuery', body: {
      "instituteName": "IEEE",
    });

    if (json.decode(response.body)['statusCode'] == 200) {
      total = json.decode(response.body)['payload']['query'];
      total.forEach((element) {
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
        approved.clear();
        pending.clear();
        _isLoading = true;
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
        padding: EdgeInsets.symmetric(vertical: 16),
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
                    shrinkWrap: true,
                    itemCount:
                        widget.isPending ? pending.length : approved.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          'Name: ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          widget.isPending
                                              ? pending[index]['userName']
                                              : approved[index]['userName'],
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          'Phone Number: ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          widget.isPending
                                              ? pending[index]['contactNumber']
                                                  .toString()
                                              : approved[index]['contactNumber']
                                                  .toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  widget.isPending
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Query: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        )
                                      : Container(),
                                  widget.isPending
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Container(
                                            child: Text(
                                              pending[index]['message'],
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  widget.isPending
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8),
                                          child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
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
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Container(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Status: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  StringUtils.capitalize(
                                                      approved[index]
                                                          ['status']),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8),
                                    child: MaterialButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              'Call',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () async {
                                        var url =
                                            "tel:${pending[index]['contactNumber']}";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      color: teal1,
                                    ),
                                  )
                                ],
                              ),
                            )),
                      );
                    }),
      ),
    );
  }
}
