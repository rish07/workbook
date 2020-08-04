import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:workbook/widget/popUpDialog.dart';

class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword({Key key, this.email}) : super(key: key);
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _isLoading = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  bool _validatePass = false;
  bool _validateRePass = false;

  Future _resetPassword() async {
    var response = await http.post('$baseUrl/resetPassword', body: {
      'userID': widget.email,
      "password": _passwordController.text.toString(),
    });
    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      popDialog(
          title: 'Success',
          context: context,
          content: 'Password reset successful! Please login now',
          onPress: () {
            Navigator.push(
              context,
              PageTransition(child: LoginPage(), type: PageTransitionType.fade),
            );
          });
    } else {
      Fluttertoast.showToast(context, msg: 'Error, try again!', gravity: ToastGravity.CENTER);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(violet2),
        backgroundColor: Colors.transparent,
      ),
      inAsyncCall: _isLoading,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [violet1, violet2]),
          ),
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InputField(
                  capital: TextCapitalization.none,
                  errorText: 'Please enter a valid password',
                  labelText: 'Password',
                  validate: _validatePass,
                  controller: _passwordController,
                ),
              ),
              InputField(
                capital: TextCapitalization.none,
                validate: _validateRePass,
                controller: _rePasswordController,
                errorText: 'Please enter a valid password',
                labelText: 'Re-enter Password',
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: MediaQuery.of(context).size.height * 0.05),
                child: MaterialButton(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _resetPassword();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Text(
                    'Reset Password',
                    style: TextStyle(color: violet2, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
