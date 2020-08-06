import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/screens/reset_password.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:http/http.dart' as http;

class OTPVerification extends StatefulWidget {
  final String name;
  final String password;
  final String instituteName;
  final String instituteType;
  final String instituteImageUrl;
  final String numberOfMembers;
  final String state;
  final String city;
  final String carNumber;
  final String grade;
  final String division;
  final String mail;
  final String aadhar;
  final String phone;
  final String fcm;
  final String role;
  final String otp;
  final bool isEmailVerify;
  final String email;

  const OTPVerification(
      {Key key,
      this.email,
      @required this.isEmailVerify,
      this.otp,
      this.name,
      this.password,
      this.instituteName,
      this.instituteType,
      this.instituteImageUrl,
      this.numberOfMembers,
      this.state,
      this.city,
      this.mail,
      this.aadhar,
      this.phone,
      this.fcm,
      this.role,
      this.grade,
      this.division,
      this.carNumber})
      : super(key: key);
  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  bool _time = false;
  bool _isLoading = false;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: Color(0xFFF1F1F1),
      border: Border.all(
        color: Color(0xFFF1F1F1),
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Future _resetPassword(String email) async {
    var response = await http.get('$baseUrl/forgot/$email');
    print(response.body);
    Navigator.pop(context);
    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(context, msg: 'Email sent', gravity: ToastGravity.CENTER);
    } else if (json.decode(response.body)['statusCode'] == 400) {
      popDialog(
          title: 'Error',
          content: 'The user with this email ID does not exist, please create an account first!',
          buttonTitle: 'Okay',
          onPress: () {
            Navigator.pop(context);
          },
          context: context);
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
  }

  Future _registerUser() async {
    var response = await http.post(
      widget.role == 'admin'
          ? "$baseUrl/admin/register"
          : (widget.role == 'employee')
              ? "$baseUrl/employee/register"
              : (widget.role == 'customer') ? "$baseUrl/customer/register" : (widget.role == 'driver') ? "$baseUrl/driver/register" : "",
      body: widget.role == 'admin'
          ? {
              "userName": widget.name,
              "userID": widget.email,
              "password": widget.password,
              "instituteName": widget.instituteName,
              "instituteType": widget.instituteType,
              "instituteImageUrl": widget.instituteImageUrl,
              "numberOfMembers": widget.numberOfMembers,
              "state": widget.state,
              "city": widget.city,
              "mailAddress": widget.mail,
              "adharNumber": widget.aadhar,
              "contactNumber": widget.phone,
              "fcmToken": widget.fcm,
            }
          : (widget.role == 'customer' || widget.role == 'employee')
              ? {
                  "role": widget.role == 'employee' ? "Employee" : "customer",
                  "userName": widget.name,
                  "userID": widget.email,
                  "password": widget.password,
                  "instituteName": widget.instituteName,
                  "grade": widget.grade,
                  "division": widget.division,
                  "adharNumber": widget.aadhar,
                  "contactNumber": widget.phone,
                  "fcmToken": User.userFcmToken,
                }
              : {
                  "role": "driver",
                  "userName": widget.name,
                  "userID": widget.email,
                  "password": widget.password,
                  "instituteName": widget.instituteName,
                  "carNumber": widget.carNumber,
                  "adharNumber": widget.aadhar,
                  "contactNumber": widget.phone,
                  "fcmToken": User.userFcmToken,
                },
    );
    print(response.body);
    setState(() {
      _isLoading = false;
    });
    if (json.decode(response.body)['statusCode'] == 200) {
      popDialog(
          onPress: () {
            Navigator.push(
              context,
              PageTransition(child: LoginPage(), type: PageTransitionType.rightToLeft),
            );
          },
          title: 'Registration Successful',
          context: context,
          buttonTitle: 'Close',
          content: 'Your form has been submitted. Please wait for 24 hours for it to get approved');
    } else if (json.decode(response.body)['payload']['err'] != null) {
      if (json.decode(response.body)['payload']['err']['keyValue'] != null) {
        popDialog(
            title: 'Duplicate user',
            context: context,
            content: 'Admin with email ID ${json.decode(response.body)['payload']['err']['keyValue']['userID']} already exists. Please login in!',
            onPress: () {
              Navigator.push(
                context,
                PageTransition(child: LoginPage(), type: PageTransitionType.rightToLeft),
              );
            },
            buttonTitle: 'Login');
      }
    } else {
      popDialog(
          title: 'Error',
          content: "Registration failed, please try again!",
          context: context,
          onPress: () {
            Navigator.pop(context);
          },
          buttonTitle: 'Okay');
    }
  }

  Future _verifyOTP(String otp) async {
    var response = await http.post(widget.isEmailVerify ? '$baseUrl/verifyUser' : '$baseUrl/verifyOTP', body: {
      'userID': widget.email,
      'token': otp,
    });

    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(context, msg: 'Success', gravity: ToastGravity.CENTER);

      if (!widget.isEmailVerify) {
        Navigator.push(
          context,
          PageTransition(
              child: ResetPassword(
                email: widget.email,
              ),
              type: PageTransitionType.fade),
        );
      } else {
        Navigator.pop(context);
        setState(() {
          isEmailVerified = true;
        });
      }
    } else {
      print('ERROR');
      Fluttertoast.showToast(context, msg: 'Try again', gravity: ToastGravity.CENTER);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(minutes: 5), () {
      setState(() {
        _time = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: violet1,
      body: ModalProgressHUD(
        opacity: 0.5,
        inAsyncCall: _isLoading,
        child: Container(
          child: Stack(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.08, left: MediaQuery.of(context).size.width * 0.12),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
              Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.14, horizontal: MediaQuery.of(context).size.width * 0.12),
                child: Text(
                  widget.isEmailVerify ? 'Verify Email' : 'Reset Password',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.12),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Text(
                          'OTP Verification',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Have you received a six digit\nVerification Code?',
                          style: TextStyle(color: Colors.grey, fontSize: 19),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(top: 20, bottom: 10),
                              child: PinPut(
                                autofocus: true,
                                fieldsCount: 6,
                                onSubmit: (String pin) async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    if (!widget.isEmailVerify) {
                                      await _verifyOTP(pin);
                                    } else {
                                      if (widget.otp == pin) {
                                        Fluttertoast.showToast(context, msg: 'Success', gravity: ToastGravity.CENTER);

                                        setState(() {
                                          isEmailVerified = true;
                                        });
                                        await _registerUser();
                                      } else {
                                        Fluttertoast.showToast(
                                          context,
                                          msg: 'Wrong OTP',
                                          gravity: ToastGravity.CENTER,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                  setState(() {
                                    _pinPutController.clear();
                                    _isLoading = false;
                                  });
                                },
                                focusNode: _pinPutFocusNode,
                                controller: _pinPutController,
                                submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
                                selectedFieldDecoration: _pinPutDecoration,
                                followingFieldDecoration: _pinPutDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Color(0xFFF1F1F1),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_time) {
                                  await _resetPassword(widget.email);
                                } else {
                                  popDialog(
                                      title: 'Wait',
                                      context: context,
                                      content: 'Please wait for 5 minutes before trying for new otp!',
                                      buttonTitle: 'Okay',
                                      onPress: () {
                                        Navigator.pop(context);
                                      });
                                }
                              },
                              child: Container(
                                height: 30,
                                child: Text(
                                  'Resend Code',
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            registerButton(
                              color: violet2,
                              onPressed: () {},
                              role: 'Verify',
                              fontColor: Colors.white,
                              context: context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
