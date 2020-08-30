import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';

class QueryStatus extends StatefulWidget {
  final bool isPending;
  final bool isRegistered;
  const QueryStatus({Key key, this.isPending, this.isRegistered}) : super(key: key);
  @override
  _QueryStatusState createState() => _QueryStatusState();
}

class _QueryStatusState extends State<QueryStatus> {
  List pending = [];
  List unregistered = [];
  List registered = [];
  List total = [];
  bool _isLoading = false;

  // Get all queries
  Future getAllQuery() async {
    var response = await http.post('$baseUrl/guest/getAllQuery', body: {
      "instituteName": "IEEE",
    });

    if (json.decode(response.body)['statusCode'] == 200) {
      total = json.decode(response.body)['payload']['query'];
      total.forEach((element) {
        if (element['status'] == 'created') {
          pending.add(element);
        } else if (element['status'] == 'unregistered') {
          unregistered.add(element);
        } else {
          registered.add(element);
        }
      });
      print(unregistered);
      print(registered);
      print(pending);
    }
    setState(() {
      registered = Set.of(registered).toList();
      unregistered = Set.of(unregistered).toList();
      pending = Set.of(pending).toList();
      _isLoading = false;
    });
  }

  Future createComment({String id, String comment}) async {
    print(id);
    print(comment);
    print(User.userEmail);
    print(User.userJwtToken);
    var response = await http.post('$baseUrl/admin/queryComment', body: {
      "id": id,
      "comment": comment,
      "jwtToken": User.userJwtToken,
      "userID": User.userEmail,
    });
    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      Navigator.pop(context);
      Fluttertoast.showToast(context, msg: 'Comment Added');
      setState(() {
        pending.clear();
        _isLoading = true;
        getAllQuery();
      });
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
    setState(() {
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
        unregistered.clear();
        registered.clear();
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
      child: RefreshIndicator(
        onRefresh: () {
          setState(() {
            pending.clear();
            _isLoading = true;
          });
          return getAllQuery();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: widget.isPending && pending.length == 0 && !_isLoading
              ? Center(
                  child: Text(
                    'No Pending Queries',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                )
              : (!widget.isPending && !widget.isRegistered && unregistered.length == 0 && !_isLoading)
                  ? Center(
                      child: Text(
                        'No Unregistered Queries',
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                    )
                  : (!widget.isPending && widget.isRegistered && registered.length == 0 && !_isLoading)
                      ? Center(
                          child: Text(
                            'No Registered Queries',
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.isPending ? pending.length : (!widget.isPending && widget.isRegistered) ? registered.length : unregistered.length,
                          itemBuilder: (context, index) {
                            final TextEditingController _descriptionController = TextEditingController();
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Stack(
                                children: [
                                  Card(
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
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  'Name: ',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  widget.isPending
                                                      ? pending[index]['userName']
                                                      : (!widget.isPending && widget.isRegistered) ? registered[index]['userName'] : unregistered[index]['userName'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  'Phone Number: ',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  widget.isPending
                                                      ? pending[index]['contactNumber'].toString()
                                                      : (!widget.isPending && widget.isRegistered)
                                                          ? registered[index]['contactNumber'].toString()
                                                          : unregistered[index]['contactNumber'].toString(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          widget.isPending
                                              ? Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Text(
                                                    'Query: ',
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                  ),
                                                )
                                              : Container(),
                                          widget.isPending
                                              ? Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Container(
                                                    child: Text(
                                                      pending[index]['message'],
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
//                                          unregistered[index]['comment'] != null
//                                              ? Padding(
//                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                                  child: Text(
//                                                    'Comment:',
//                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                                                  ),
//                                                )
//                                              : Container(),
//                                          unregistered[index]['comment'] != null
//                                              ? Padding(
//                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                                  child: Container(
//                                                    child: Text(
//                                                      pending[index]['comment'],
//                                                      textAlign: TextAlign.justify,
//                                                    ),
//                                                  ),
//                                                )
//                                              : Container(),
                                          widget.isPending
                                              ? Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                                  child: MaterialButton(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(32),
                                                    ),
                                                    color: violet1,
                                                    onPressed: () async {
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                      await resolveQuery(id: pending[index]['_id']);
                                                    },
                                                    child: Text(
                                                      'Resolve query',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                            child: MaterialButton(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.phone,
                                                    color: Colors.white,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Text(
                                                      'Call',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () async {
                                                var url = "tel:${pending[index]['contactNumber']}";
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(32),
                                              ),
                                              color: violet1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0, left: MediaQuery.of(context).size.width * 0.83),
                                    child: PopupMenuButton(
                                      onSelected: (value) async {
                                        if (value == 1) {
                                          showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (BuildContext context) => Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(32),
                                              ),
                                              height: MediaQuery.of(context).size.height * 0.7,
                                              padding: EdgeInsets.all(16),
                                              child: ListView(
                                                children: [
                                                  Text(
                                                    widget.isPending && pending[index]['comment'] == null ? 'Add Comment' : 'Edit Comment',
                                                    style: TextStyle(color: violet1, fontSize: 20),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Container(
                                                      height: MediaQuery.of(context).size.height * 0.35,
                                                      width: MediaQuery.of(context).size.width,
                                                      child: TextFormField(
                                                        autocorrect: true,
                                                        maxLines: 10,
                                                        onTap: () {},
                                                        cursorRadius: Radius.circular(8),
                                                        cursorColor: violet1,
                                                        keyboardType: TextInputType.text,
                                                        textCapitalization: TextCapitalization.sentences,
                                                        controller: _descriptionController,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: violet1,
                                                        ),
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                                                          isDense: true,
                                                          errorMaxLines: 1,
                                                          focusedErrorBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: violet1, width: 2),
                                                          ),
                                                          errorStyle: TextStyle(height: 0, fontSize: 10),
                                                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: violet1, width: 1),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: violet1, width: 2.0),
                                                          ),
                                                          fillColor: Colors.lightBlueAccent,
                                                          hintText: 'Start typing...',
                                                          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                                                          alignLabelWithHint: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 100.0),
                                                    child: MaterialButton(
                                                      padding: EdgeInsets.all(16),
                                                      color: violet1,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(32),
                                                      ),
                                                      onPressed: () async {
                                                        if (_descriptionController.text.isNotEmpty) {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });
                                                          Fluttertoast.showToast(context, msg: 'Posting comment', toastDuration: 3);
                                                          await createComment(id: pending[index]['_id'], comment: _descriptionController.text);
                                                        } else {
                                                          Fluttertoast.showToast(context, msg: 'Comment can\'t be empty!');
                                                        }
                                                      },
                                                      child: Text(
                                                        'Submit Enquiry',
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 1,
                                          child: Text(widget.isPending && pending[index]['comment'] == null ? 'Add Comment' : 'Edit Comment'),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
        ),
      ),
    );
  }
}
