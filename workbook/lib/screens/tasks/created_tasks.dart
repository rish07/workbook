import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:universal_io/io.dart';
import 'package:workbook/screens/responsive_widget.dart';
import '../../constants.dart';
import '../../user.dart';

class CreatedTasks extends StatefulWidget {
  @override
  _CreatedTasksState createState() => _CreatedTasksState();
}

class _CreatedTasksState extends State<CreatedTasks> {
  bool _isLoading = false;
  Future getTasks() async {
    var response = await http.post("$baseUrl/task/createdBy", body: {
      "userID": User.userEmail,
      "jwtToken": User.userJwtToken,
    });
    print('Response status: ${response.statusCode}');

    setState(() {
      _isLoading = false;
      _tasks = json.decode(response.body)['payload']['task'];
      _tasks = _tasks.reversed.toList();
    });
  }

  List _tasks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: violet1,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Created Tasks',
            style: TextStyle(color: violet1),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16),
          child: _tasks.length != 0
              ? ListView.separated(
                  padding: Platform.isAndroid
                      ? EdgeInsets.zero
                      : ResponsiveWidget.isMediumScreen(context)
                          ? EdgeInsets.symmetric(horizontal: size.width * 0.1)
                          : EdgeInsets.symmetric(horizontal: size.width * 0.2),
                  separatorBuilder: (BuildContext context, int index) => Divider(
                        thickness: 2,
                      ),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(_tasks[index]['name']),
                        subtitle: Text(_tasks[index]['description']),
                        trailing: Container(
                          width: ResponsiveWidget.isMediumScreen(context) ? size.width * 0.25 : size.width * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              User.userRole == 'employee'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Grade: '),
                                        Text(_tasks[index]['grade']),
                                      ],
                                    )
                                  : Container(),
                              User.userRole == 'employee'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Div: '),
                                        Text(_tasks[index]['division']),
                                      ],
                                    )
                                  : Container(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Created at: '),
                                  Text(
                                    DateFormat.yMd().add_jm().format(
                                          DateTime.fromMillisecondsSinceEpoch(_tasks[index]['createdAt']),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                  })
              : Center(
                  child: Text('No History Available'),
                ),
        ),
      ),
    );
  }
}
