import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:universal_io/io.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/auth/otp_verification.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/registerButton.dart';

import '../../responsive_widget.dart';

class DriverForm extends StatefulWidget {
  @override
  _DriverFormState createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  bool _isLoading = false;
  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateRePassword = false;
  bool _validateInstitution = false;
  bool _validateCar = false;

  bool _validateAadhar = false;
  bool _validatePhoneNumber = false;
  String _selectedInstitution;
  String _selectedCar;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordReController = TextEditingController();

  // Send email verification
  Future _sendEmailVerification(String email) async {
    var response = await http.post('$baseUrl/sendVerification', body: {
      "userID": email,
      "role": "driver",
    });
    print(response.body);

    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(context,
          msg: 'Email sent', gravity: ToastGravity.CENTER);
      Navigator.push(
        context,
        PageTransition(
            child: OTPVerification(
              carNumber: _selectedCar,
              role: 'driver',
              name: _nameController.text,
              password: _passwordController.text,
              instituteName: _selectedInstitution,
              fcm: User.userFcmToken,
              aadhar: _aadharController.text.toString(),
              phone: _phoneController.text.toString(),
              otp: json.decode(response.body)['payload']['token'].toString(),
              isEmailVerify: true,
              email: _emailController.text,
            ),
            type: PageTransitionType.fade),
      );
    } else if (json.decode(response.body)['statusCode'] == 401) {
      popDialog(
          title: 'Duplicate User',
          content:
              'The user with email id $email already exists. Please login or click on forgot password!',
          buttonTitle: 'Okay',
          onPress: () {
            Navigator.pop(context);
          },
          context: context);
    } else if (json.decode(response.body)['statusCode'] == 400) {
      popDialog(
          title: 'Error',
          content: 'There was some error,please try again!',
          buttonTitle: 'Okay',
          onPress: () {
            Navigator.pop(context);
          },
          context: context);
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
  }

  @override
  void initState() {
    Timer(Duration(seconds: 5), () {
      setState(() {});
    });
    print(User.userFcmToken);
    super.initState();
  }

  //UI Block
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _isLoading,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [violet1, violet2]),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Text(
                      'Driver Registration',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.only(top: 16.0)
                          : EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.15
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.32
                                          : 0),
                      child: InputField(
                        validate: _validateName,
                        errorText: 'This field can\'t be empty',
                        controller: _nameController,
                        labelText: 'Name',
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.only(top: 16.0)
                          : EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.15
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.32
                                          : 0),
                      child: InputField(
                        validate: _validateEmail,
                        capital: TextCapitalization.none,
                        controller: _emailController,
                        errorText: 'Please enter a valid email ID',
                        labelText: 'Email',
                        textInputType: TextInputType.emailAddress,
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.only(top: 16.0)
                          : EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.15
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.32
                                          : 0),
                      child: PasswordInput(
                        validate: _validatePassword,
                        controller: _passwordController,
                        labelText: 'Password',
                        errorText:
                            'Min Length = 8 and Max length = 15,\nShould have atleast 1 number, 1 capital letter\nand 1 Special Character',
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.only(top: 16.0)
                          : EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.15
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.32
                                          : 0),
                      child: PasswordInput(
                        validate: _validateRePassword,
                        controller: _passwordReController,
                        labelText: 'Re-enter Password',
                        errorText: 'Passwords don\'t match',
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.all(16)
                          : EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.165
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.328
                                          : 0),
                      child: Theme(
                        data: Theme.of(context).copyWith(canvasColor: violet1),
                        child: DropdownButtonFormField(
                          onTap: () {
                            setState(() {
                              _validateInstitution = false;
                            });
                          },
                          decoration: InputDecoration(
                            errorText: _validateInstitution
                                ? 'Please choose an option'
                                : null,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                          ),
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconDisabledColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          iconSize: 24,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                          hint: Text(
                            'Select Institution',
                            style: TextStyle(color: Colors.white70),
                          ),
                          value: _selectedInstitution,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedInstitution = newValue;
                            });
                          },
                          items: institutes.map((type) {
                            return DropdownMenuItem(
                              child: Text(type),
                              value: type,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.all(16)
                          : EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.165
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.328
                                          : 0),
                      child: Theme(
                        data: Theme.of(context).copyWith(canvasColor: violet1),
                        child: DropdownButtonFormField(
                          onTap: () {
                            setState(() {
                              _validateCar = false;
                            });
                          },
                          decoration: InputDecoration(
                            errorText:
                                _validateCar ? 'Please choose an option' : null,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                          ),
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconDisabledColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          iconSize: 24,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                          hint: Text(
                            'Select Car Number',
                            style: TextStyle(color: Colors.white70),
                          ),
                          value: _selectedCar,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCar = newValue;
                            });
                          },
                          items: carNumber.map((type) {
                            return DropdownMenuItem(
                              child: Text(type),
                              value: type,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.zero
                          : EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.15
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.32
                                          : 0),
                      child: InputField(
                        validate: _validateAadhar,
                        controller: _aadharController,
                        errorText:
                            'Please enter you 12 digit Aadhar Card number',
                        textInputType: TextInputType.number,
                        labelText: 'Aadhar Card Number',
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.zero
                          : EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveWidget.isMediumScreen(context)
                                      ? size.width * 0.15
                                      : ResponsiveWidget.isLargeScreen(context)
                                          ? size.width * 0.32
                                          : 0),
                      child: InputField(
                        validate: _validatePhoneNumber,
                        errorText:
                            'Please enter a valid 10 digit mobile number',
                        controller: _phoneController,
                        textInputType: TextInputType.phone,
                        labelText: 'Contact Number',
                      ),
                    ),
                    Padding(
                      padding: Platform.isAndroid
                          ? EdgeInsets.symmetric(vertical: 16.0, horizontal: 64)
                          : EdgeInsets.symmetric(
                              vertical: 16, horizontal: size.width * 0.4),
                      child: Builder(
                        builder: (context) => registerButton(
                          role: 'Submit',
                          context: context,
                          onPressed: () async {
                            setState(() {
                              _nameController.text.isEmpty
                                  ? _validateName = true
                                  : _validateName = false;
                              (_emailController.text.isEmpty ||
                                      !validator.email(_emailController.text))
                                  ? _validateEmail = true
                                  : _validateEmail = false;
                              (_passwordController.text.isEmpty ||
                                      !validator
                                          .password(_passwordController.text))
                                  ? _validatePassword = true
                                  : _validatePassword = false;
                              (_passwordReController.text.isEmpty ||
                                      !validator
                                          .password(_passwordController.text))
                                  ? _validateRePassword = true
                                  : _validateRePassword = false;

                              (_aadharController.text.isEmpty ||
                                      _aadharController.text.length != 12)
                                  ? _validateAadhar = true
                                  : _validateAadhar = false;
                              (_phoneController.text.isEmpty ||
                                      _phoneController.text.length != 10)
                                  ? _validatePhoneNumber = true
                                  : _validatePhoneNumber = false;

                              if (_selectedCar == null) {
                                _validateCar = true;
                              }
                              if (_selectedInstitution == null) {
                                _validateInstitution = true;
                              }
                              if (_passwordController.text !=
                                  _passwordReController.text) {
                                _validateRePassword = true;
                              }
                            });
                            if (!_validateName &&
                                !_validateEmail &&
                                !_validatePhoneNumber &&
                                !_validateCar &&
                                !_validateInstitution &&
                                !_validateAadhar &&
                                !_validatePassword &&
                                !_validateRePassword) {
                              await _sendEmailVerification(
                                  _emailController.text.toString());
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.9),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Platform.isAndroid
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      )
                    : MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
