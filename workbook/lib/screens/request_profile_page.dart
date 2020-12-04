import 'dart:convert';
import 'dart:html';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image/network.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:universal_io/io.dart' as uni;
import 'package:workbook/constants.dart';
import 'package:workbook/screens/auth/active_users.dart';
import '../responsive_widget.dart';
import 'package:workbook/user.dart';

import 'auth/approve_user.dart';

class RequestProfilePage extends StatefulWidget {
  final String carNumber;
  final bool isDriver;
  final String instituteName;
  final String instituteType;
  final bool profilePicExists;
  final String id;
  final String role;
  final bool isActive;
  final bool routeExists;
  final String userName;
  final String emailID;
  final String grade;
  final String division;
  final String aadharNumber;
  final String contactNumber;

  const RequestProfilePage(
      {Key key,
      this.role,
      this.userName,
      this.emailID,
      this.grade,
      this.division,
      this.aadharNumber,
      this.contactNumber,
      this.id,
      this.profilePicExists,
      this.isActive,
      this.instituteName,
      this.instituteType,
      this.isDriver,
      this.carNumber,
      this.routeExists})
      : super(key: key);
  @override
  _RequestProfilePageState createState() => _RequestProfilePageState();
}

class _RequestProfilePageState extends State<RequestProfilePage> {
  bool isEdit = false;
  String routeID;
  String routeName;
  bool _routeExists = false;
  bool _loading = false;
  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  // Delete user
  Future _deleteUser() async {
    print('working');
    var response = await http.post('$baseUrl/${User.userRole}/delete${StringUtils.capitalize(widget.role)}', body: {
      "jwtToken": User.userJwtToken,
      "userID": User.userEmail,
      "id": widget.id,
    });

    print('Response status: ${response.statusCode}');
    print(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      print('Notification Sent');
    } else {
      throw Exception('Failed to load the employees');
    }
  }

  Future _update() async {
    setState(() {
      _loading = true;
    });
    var body = json.encode(
      {
        "id": widget.id.toString(),
        "data": {
          "userName": _nameController.text.toString().isNotEmpty ? _nameController.text.toString() : User.userName.toString(),
          "contactNumber": _contactNumberController.text.toString().isNotEmpty ? _contactNumberController.text.toString() : User.contactNumber.toString(),
          "aadharNumber": _aadharNumberController.text.toString().isNotEmpty ? _aadharNumberController.text.toString() : User.aadharNumber.toString(),
        },
      },
    );
    print(body);
    var response = await http.post(
      widget.role == 'employee'
          ? "$baseUrl/admin/updateEmployee"
          : (widget.role == 'customer')
              ? "$baseUrl/admin/updateCustomer"
              : "$baseUrl/admin/updateDriver",
      body: body,
      headers: {"content-type": "application/json"},
    );
    print(response.body);
    setState(() {
      _loading = false;
    });
    if (json.decode(response.body)['statusCode'] == 200) {
      Navigator.push(
        context,
        PageTransition(
            child: ApproveUser(
              isDriver: false,
            ),
            type: PageTransitionType.rightToLeft),
      );
    }
  }

  // Get routes
  Future _getRoutes() async {
    var response = await http.get('$baseUrl/getRoutes');
    print(response.body);
    setState(() {
      routeData = json.decode(response.body)['payload']['routes'];
      print(routeData);
      routeData.forEach((element) {
        if (element['driverID'] == widget.id) {
          setState(() {
            _routeExists = true;
            routeName = element['routeName'];
            routeID = element['_id'];
          });
        }
        routeNames.add(element['routeName']);
      });
      routeNames = Set.of(routeNames).toList();
      _loading = false;
    });
  }

  String photoUrl;
  @override
  void initState() {
    // TODO: implement initState
    _loading = true;
    _getRoutes();
    setState(() {
      photoUrl = "$baseUrl/getUserProfile/${widget.role}/${widget.id}";
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _routeNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: <Widget>[
            widget.isActive
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: MaterialButton(
                        minWidth: 80,
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Text(
                          'DELETE',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          setState(() {
                            _loading = true;
                          });
                          await _deleteUser();
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: ActiveUsers(
                                    isDriver: widget.isDriver ? true : false,
                                  ),
                                  type: PageTransitionType.rightToLeft));
                        }),
                  )
                : Container()
          ],
          title: Text('${widget.role.toUpperCase()} details'),
          iconTheme: IconThemeData(
            color: violet2,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _loading
            ? Container(
                child: Center(
                  child: Text(
                    'Loading',
                    style: TextStyle(color: Colors.grey, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : Container(
                padding: uni.Platform.isAndroid
                    ? EdgeInsets.all(16)
                    : EdgeInsets.symmetric(
                        horizontal: ResponsiveWidget.isMediumScreen(context)
                            ? size.width * 0.32
                            : ResponsiveWidget.isLargeScreen(context)
                                ? size.width * 0.4
                                : 10,
                      ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: uni.Platform.isAndroid ? 20.0 : 30),
                        child: Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: !widget.profilePicExists
                                ? AssetImage('images/userPhoto.jpg')
                                : NetworkImageWithRetry(("https://app-workbook.herokuapp.com/getUserProfile/employee/5eeccd1737d07600172c6064")),
                          ),
                        ),
                      ),
                      buildFieldEntry(
                        controller: _nameController,
                        label: 'Name',
                        value: widget.userName ?? "-",
                      ),
                      buildFieldEntry(
                        readOnly: true,
                        controller: _emailController,
                        label: 'Email ID',
                        value: widget.emailID ?? "-",
                      ),
                      buildFieldEntry(
                        readOnly: true,
                        controller: _gradeController,
                        label: User.userRole != 'superAdmin' && !widget.isDriver
                            ? 'Grade'
                            : (User.userRole != 'superAdmin' && widget.isDriver)
                                ? "Car Number"
                                : 'Institute Name',
                        value: User.userRole != 'superAdmin' && !widget.isDriver
                            ? widget.grade ?? "-"
                            : (User.userRole != 'superAdmin' && widget.isDriver)
                                ? widget.carNumber ?? '-'
                                : widget.instituteName ?? '-',
                      ),
                      User.userRole != 'superAdmin' && !widget.isDriver
                          ? buildFieldEntry(
                              readOnly: true,
                              controller: _divisionController,
                              label: User.userRole != 'superAdmin' ? 'Division' : 'Institute Type',
                              value: User.userRole != 'superAdmin' ? widget.division ?? "-" : widget.instituteType ?? '-',
                            )
                          : Container(),
                      buildFieldEntry(
                        controller: _contactNumberController,
                        label: 'Contact Number',
                        value: widget.contactNumber.toString() ?? "-",
                      ),
                      buildFieldEntry(
                        controller: _aadharNumberController,
                        label: 'Aadhar Number',
                        value: widget.aadharNumber.toString() ?? "-",
                      ),
                    ],
                  ),
                ),
              ),
//        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//        floatingActionButton: widget.isActive
//            ? FloatingActionButton.extended(
//                backgroundColor: violet2,
//                onPressed: () {
//                  if (widget.role == 'driver' && !_routeExists) {
//                    return showDialog(
//                        context: (context),
//                        builder: (BuildContext context) {
//                          return AlertDialog(
//                            title: Center(
//                                child: Text(
//                              'Add route name',
//                              style: TextStyle(color: violet1),
//                            )),
//                            content: TextFormField(
//                              autocorrect: true,
//                              autofocus: true,
//                              textCapitalization: TextCapitalization.words,
//                              cursorRadius: Radius.circular(8),
//                              cursorColor: violet1,
//                              style: TextStyle(color: Colors.black, fontSize: 18),
//                              controller: _routeNameController,
//                              decoration: InputDecoration(
//                                enabledBorder: UnderlineInputBorder(
//                                  borderSide: BorderSide(color: violet2),
//                                ),
//                                focusedBorder: UnderlineInputBorder(
//                                  borderSide: BorderSide(color: violet2, width: 2),
//                                ),
//                              ),
//                            ),
//                            actions: <Widget>[
//                              // usually buttons at the bottom of the dialog
//                              new MaterialButton(
//                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                                  color: violet2,
//                                  child: new Text(
//                                    'Proceed',
//                                    style: TextStyle(
//                                      color: Colors.white,
//                                    ),
//                                  ),
//                                  onPressed: () {
//                                    if (_routeNameController.text.isNotEmpty) {
//                                      Navigator.push(
//                                          context,
//                                          PageTransition(
//                                              child: GoogleMapScreen(
//                                                isEdit: _routeExists ? true : false,
//                                                driverID: widget.id,
//                                                routeName: _routeNameController.text,
//                                              ),
//                                              type: PageTransitionType.rightToLeft));
//                                      _routeNameController.clear();
//                                    } else {
//                                      Fluttertoast.showToast(context, msg: 'Route Name is required.');
//                                    }
//                                  }),
//                            ],
//                          );
//                        });
//                  } else if (widget.role == 'driver' && _routeExists) {
//                    return Navigator.push(
//                      context,
//                      PageTransition(
//                          child: GoogleMapScreen(routeID: _routeExists ? routeID : null, isEdit: _routeExists ? true : false, driverID: widget.id, routeName: routeName),
//                          type: PageTransitionType.rightToLeft),
//                    );
//                  } else {
//                    return showModalBottomSheet(
//                        backgroundColor: Colors.transparent,
//                        context: context,
//                        builder: (BuildContext context) {
//                          return OpenBottomModal(
//                            userRole: widget.role,
//                            regId: widget.id,
//                          );
//                        });
//                  }
//                },
//                label: Row(
//                  children: <Widget>[
//                    Padding(
//                      padding: EdgeInsets.only(right: 8.0),
//                      child: Icon(
//                        Icons.location_on,
//                        color: Colors.white,
//                      ),
//                    ),
//                    Text(
//                      widget.role == 'driver' && !_routeExists
//                          ? 'Add Route'
//                          : (widget.role == 'driver' && _routeExists) ? 'Edit Route' : (widget.routeExists) ? 'Edit Travel Service' : 'Add Travel Service',
//                      style: TextStyle(fontWeight: FontWeight.bold),
//                    ),
//                  ],
//                ))
//            : null,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: violet2,
          onPressed: () async {
            print(_nameController.text.toString());
            print(_emailController.text.toString());
            print(_contactNumberController.text.toString());
            if (isEdit) {
              await _update();
            }
            setState(() {
              isEdit = !isEdit;
            });
          },
          label: Text(isEdit ? 'Save' : 'Edit'),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Padding buildFieldEntry({String label, String value, TextEditingController controller, bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: uni.Platform.isAndroid ? 8.0 : 16, horizontal: 16),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 20, color: violet2),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: TextFormField(
                controller: controller,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: violet1),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: readOnly ? BorderSide.none : (isEdit ? BorderSide(width: 2, color: violet2) : BorderSide.none),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: readOnly ? BorderSide.none : (isEdit ? BorderSide(width: 2, color: violet2) : BorderSide.none),
                  ),
                  hintText: value,
                  hintStyle: TextStyle(color: violet1, fontSize: 18),
                ),
                readOnly: readOnly ? true : (isEdit ? false : true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
