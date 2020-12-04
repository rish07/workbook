import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:universal_io/prefer_universal/io.dart';
import 'package:workbook/constants.dart';

import '../../responsive_widget.dart';

class ViewDivisions extends StatefulWidget {
  final String gradeName;
  final bool isEdit;
  const ViewDivisions({Key key, this.gradeName, this.isEdit}) : super(key: key);
  @override
  _ViewDivisionsState createState() => _ViewDivisionsState();
}

class _ViewDivisionsState extends State<ViewDivisions> {
  List gradeDivision = [];

  // Store local divisions
  void _div() {
    print(widget.gradeName);
    print('working div');
    divisionData.forEach((element) {
      if (element['grade'] == widget.gradeName) {
        gradeDivision.add(element['division']);
      }
    });
    gradeDivision = Set.of(gradeDivision).toList();
    print(gradeDivision);
  }

  //Local storage of Divisions
  Future addDivision({BuildContext context, String label}) {
    final controller = TextEditingController();
    String name;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "CANCEL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: violet2,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    // ignore: deprecated_member_use
                    Fluttertoast.showToast(context, msg: 'Please enter a name');
                  } else {
                    setState(() {
                      tempData[widget.gradeName]
                          .add(controller.text.toString());
                    });
                    print(tempData);
                    controller.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'ADD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: violet2,
                  ),
                ),
              )
            ],
            title: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Add a new $label',
                    style: TextStyle(
                      color: violet2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: 'Enter ${StringUtils.capitalize(label)} Name',
                      hintStyle: TextStyle(
                        color: violet1,
                      )),
                ),
              ],
            ),
          );
        });
  }

  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tempData[widget.gradeName] = [];
    _div();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.gradeName,
            style: TextStyle(color: violet2, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: violet2),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: Platform.isAndroid
              ? EdgeInsets.all(16)
              : EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: ResponsiveWidget.isMediumScreen(context)
                      ? size.width * 0.25
                      : size.width * 0.3),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Divisions',
                    style: TextStyle(color: violet2, fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                          itemCount: widget.isEdit
                              ? tempData[widget.gradeName].length
                              : gradeDivision.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              shadowColor: Colors.grey,
                              child: ListTile(
                                title: Text(widget.isEdit
                                    ? tempData[widget.gradeName][index]
                                    : gradeDivision[index]),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: widget.isEdit
            ? Padding(
                padding: EdgeInsets.all(16.0),
                child: FloatingActionButton.extended(
                  backgroundColor: violet2,
                  onPressed: () {
                    return addDivision(context: context, label: 'Division');
                  },
                  label: Text('Add Division'),
                ),
              )
            : null,
      ),
    );
  }
}
