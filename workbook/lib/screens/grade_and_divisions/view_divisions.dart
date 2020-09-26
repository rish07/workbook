import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:universal_io/prefer_universal/io.dart';
import 'package:workbook/constants.dart';

import '../../responsive_widget.dart';

class ViewDivisions extends StatefulWidget {
  final String gradeName;

  const ViewDivisions({Key key, this.gradeName}) : super(key: key);
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

  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              : EdgeInsets.symmetric(vertical: 16, horizontal: ResponsiveWidget.isMediumScreen(context) ? size.width * 0.25 : size.width * 0.3),
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
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                          itemCount: gradeDivision.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              shadowColor: Colors.grey,
                              child: ListTile(
                                title: Text(gradeDivision[index]),
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
      ),
    );
  }
}
