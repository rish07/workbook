import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/reset_password.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:http/http.dart' as http;

class OTPVerification extends StatefulWidget {
  final String email;

  const OTPVerification({Key key, this.email}) : super(key: key);
  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
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

  Future _verifyOTP(String otp) async {
    var response = await http.post('$baseUrl/verifyOTP', body: {
      'userID': widget.email,
      'token': otp,
    });

    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(context, msg: 'Success', gravity: ToastGravity.CENTER);
      Navigator.push(
        context,
        PageTransition(
            child: ResetPassword(
              email: widget.email,
            ),
            type: PageTransitionType.fade),
      );
    } else {
      print('ERROR');
      Fluttertoast.showToast(context, msg: 'Try again', gravity: ToastGravity.CENTER);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                  'Create Account',
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
                                    await _verifyOTP(pin);
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
                              onTap: () {},
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
