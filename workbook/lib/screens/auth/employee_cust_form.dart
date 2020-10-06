import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:universal_io/prefer_sdk/io.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/auth/login_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../responsive_widget.dart';

class EmployeeCustomerForm extends StatefulWidget {
  final bool isEmployee;
  final List admins;

  const EmployeeCustomerForm({
    Key key,
    this.isEmployee,
    this.admins,
  }) : super(key: key);
  @override
  _EmployeeCustomerFormState createState() => _EmployeeCustomerFormState();
}

class _EmployeeCustomerFormState extends State<EmployeeCustomerForm> {
  List employees = [];
  bool _isLoading = false;
  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateRePassword = false;
  bool _validateInstitution = false;
  bool _validateGrade = false;
  bool _validateDivision = false;
  bool _validateAadhar = false;
  bool _validatePhoneNumber = false;

  String _selectedInstitution;
  String _selectedGrade;
  String _selectedDivision;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordReController = TextEditingController();
  List gradeDivision = [];

  // Get grades
  Future getGrades({String instituteName}) async {
    var response = await http.get("$baseUrl/fetchGrade/$instituteName");
    print('Response status: ${response.statusCode}');
    List temp = json.decode(response.body)['payload']['grades'];
    temp.forEach((resp) {
      grades.add(resp);
    });
    grades = Set.of(grades).toList();
    setState(() {
      _isLoading = false;
    });
  }

  //Get Employee
  Future getEmployee() async {
    var response = await http.post(
      "$baseUrl/admin/viewAllEmployees",
      body: {
        "userID": User.userEmail,
        "jwtToken": User.userJwtToken,
        "instituteName": _selectedInstitution,
      },
    );
    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      List temp = json.decode(response.body)['payload']['employees'];
      temp.forEach((element) {
        if (element['approved'] == true) {
          setState(() {
            employees.add(element);
          });
        }
      });
    }
    print(employees);
  }

  //Send noti to employee
  Future sendNotificationEmployee(String name) async {
    employees.forEach((element) async {
      var response = await http
          .post("$baseUrl/sendNotification", body: {"fcmToken": element['fcmToken'], "message": "New employee request from $name. Please login now", "title": "New Registration"});
      print(response.body);
    });
  }

  // Send email verification
  // Future _sendEmailVerification(String email) async {
  //   var response = await http.post('$baseUrl/sendVerification', body: {
  //     "userID": email,
  //     "role": widget.isEmployee ? "employee" : "customer",
  //   });
  //   print(response.body);
  //
  //   if (json.decode(response.body)['statusCode'] == 200) {
  //     Fluttertoast.showToast(context, msg: 'Email sent', gravity: ToastGravity.CENTER);
  //     Navigator.push(
  //       context,
  //       PageTransition(
  //           child: OTPVerification(
  //             role: widget.isEmployee ? 'employee' : 'customer',
  //             name: _nameController.text,
  //             password: _passwordController.text,
  //             instituteName: _selectedInstitution,
  //             grade: _selectedGrade,
  //             division: _selectedDivision,
  //             fcm: User.userFcmToken,
  //             aadhar: _aadharController.text.toString(),
  //             phone: _phoneController.text.toString(),
  //             otp: json.decode(response.body)['payload']['token'].toString(),
  //             isEmailVerify: true,
  //             email: _emailController.text,
  //           ),
  //           type: PageTransitionType.fade),
  //     );
  //   } else if (json.decode(response.body)['statusCode'] == 401) {
  //     popDialog(
  //         title: 'Duplicate User',
  //         content: 'The user with email id $email already exists. Please login or click on forgot password!',
  //         buttonTitle: 'Okay',
  //         onPress: () {
  //           Navigator.push(
  //             context,
  //             PageTransition(child: LoginPage(), type: PageTransitionType.rightToLeft),
  //           );
  //         },
  //         context: context);
  //   } else if (json.decode(response.body)['statusCode'] == 400) {
  //     popDialog(
  //         title: 'Error',
  //         content: 'There was some error,please try again!',
  //         buttonTitle: 'Okay',
  //         onPress: () {
  //           Navigator.pop(context);
  //         },
  //         context: context);
  //   } else {
  //     Fluttertoast.showToast(context, msg: 'Error');
  //   }
  // }

  Future _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    print('working');
    var response = await http.post(widget.isEmployee ? '$baseUrl/employee/register' : '$baseUrl/customer/register',
        body: json.encode(
          {
            "role": widget.isEmployee ? "Employee" : "customer",
            "userName": _nameController.text,
            "userID": _emailController.text,
            "password": _passwordController.text,
            "instituteName": _selectedInstitution,
            "grade": _selectedGrade,
            "division": _selectedDivision,
            "adharNumber": _aadharController.text,
            "contactNumber": _phoneController.text,
            "fcmToken": User.userFcmToken != null ? User.userFcmToken : "fcmToken",
          },
        ),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        });
    setState(() {
      _isLoading = false;
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (json.decode(response.body)['statusCode'] == 200) {
      if (widget.isEmployee) {
        sendNotificationAdmin(_nameController.text);
      } else {
        await getEmployee();
        sendNotificationEmployee(_nameController.text);
      }
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
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _passwordReController.clear();
      _selectedInstitution = null;
      _selectedGrade = null;
      _selectedDivision = null;
      _aadharController.clear();
      _phoneController.clear();
    } else if (json.decode(response.body)['payload']['err']['keyValue'] != null) {
      popDialog(
          title: 'Duplicate user',
          context: context,
          content: 'User with email ID ${json.decode(response.body)['payload']['err']['keyValue']['userID']} already exists. Please login in!',
          onPress: () {
            Navigator.push(
              context,
              PageTransition(child: LoginPage(), type: PageTransitionType.rightToLeft),
            );
          },
          buttonTitle: 'Login');
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

  // Send noti to admin
  Future sendNotificationAdmin(String name) async {
    String adminFcm = "";
    widget.admins.forEach((element) {
      if (element['instituteName'] == _selectedInstitution) {
        setState(() {
          adminFcm = element['fcmToken'];
        });
      }
    });
    var response =
        await http.post('$baseUrl/sendNotification', body: {"fcmToken": adminFcm, "message": "New employee request from $name. Please login now", "title": "New Registration"});
    print(response.body);
  }

  // Get divisions
  Future getDivision({String instituteName}) async {
    var response = await http.get("$baseUrl/fetchDivision/$instituteName");
    print('Response status: ${response.statusCode}');
    setState(() {
      divisionData = json.decode(response.body)['payload']['divisions'];
    });
  }

  Future _div() async {
    await getDivision(instituteName: _selectedInstitution);
    gradeDivision.clear();
    print(divisionData);
    divisionData.forEach((element) {
      if (element['grade'] == _selectedGrade) {
        gradeDivision.add(element['division']);
      }
    });
    gradeDivision = Set.of(gradeDivision).toList();
    print(gradeDivision);
  }

  @override
  void initState() {
    Timer(Duration(seconds: 5), () {
      setState(() {});
    });
    print(institutes);

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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [violet1, violet2]),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: Platform.isAndroid ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    !Platform.isAndroid
                        ? IconButton(
                            icon: Icon(
                              Icons.arrow_back_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                        : Container(),
                    !Platform.isAndroid
                        ? SizedBox(
                            width: ResponsiveWidget.isMediumScreen(context)
                                ? size.width * 0.23
                                : ResponsiveWidget.isLargeScreen(context)
                                    ? size.width * 0.38
                                    : 20)
                        : Container(),
                    Text(
                      widget.isEmployee ? 'Employee/Staff Registration' : 'Customer Registration',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Padding(
                  padding: Platform.isAndroid
                      ? EdgeInsets.only(top: 16.0)
                      : EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.15
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.27
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
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.15
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.27
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
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.15
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.27
                                  : 0),
                  child: PasswordInput(
                    validate: _validatePassword,
                    controller: _passwordController,
                    labelText: 'Password',
                    errorText: 'Min Length = 8 and Max length = 15,\nShould have atleast 1 number, 1 capital letter\nand 1 Special Character',
                  ),
                ),
                Padding(
                  padding: Platform.isAndroid
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.15
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.27
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
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.168
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.278
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
                        errorText: _validateInstitution ? 'Please choose an option' : null,
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
                      onChanged: (newValue) async {
                        setState(() {
                          _isLoading = true;
                          _selectedInstitution = newValue;
                        });
                        await getGrades(instituteName: newValue);
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
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.168
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.278
                                  : 0),
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: violet1),
                    child: DropdownButtonFormField(
                      onTap: () {
                        setState(() {
                          _validateGrade = false;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: _validateGrade ? 'Please choose an option' : null,
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
                        'Select Grade',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _selectedGrade,
                      onChanged: (newValue) async {
                        setState(() {
                          _selectedGrade = newValue;
                        });
                        await _div();
                      },
                      items: grades.map((type) {
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
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.168
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.278
                                  : 0),
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: violet1),
                    child: DropdownButtonFormField(
                      onTap: () {
                        setState(() {
                          _validateDivision = false;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: _validateDivision ? 'Please choose an option' : null,
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
                        'Select Division',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _selectedDivision,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDivision = newValue;
                        });
                      },
                      items: gradeDivision.map((location) {
                        return DropdownMenuItem(
                          child: Text(location),
                          value: location,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: Platform.isAndroid
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.15
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.27
                                  : 0),
                  child: InputField(
                    validate: _validateAadhar,
                    controller: _aadharController,
                    errorText: 'Please enter you 12 digit Aadhar Card number',
                    textInputType: TextInputType.number,
                    labelText: 'Aadhar Card Number',
                  ),
                ),
                Padding(
                  padding: Platform.isAndroid
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.15
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.27
                                  : 0),
                  child: InputField(
                    validate: _validatePhoneNumber,
                    errorText: 'Please enter a valid 10 digit mobile number',
                    controller: _phoneController,
                    textInputType: TextInputType.phone,
                    labelText: 'Contact Number',
                  ),
                ),
                Padding(
                  padding: Platform.isAndroid ? EdgeInsets.symmetric(vertical: 16.0, horizontal: 64) : EdgeInsets.symmetric(vertical: 16, horizontal: size.width * 0.4),
                  child: Builder(
                    builder: (context) => registerButton(
                      role: 'Submit',
                      context: context,
                      onPressed: () async {
                        setState(() {
                          _nameController.text.isEmpty ? _validateName = true : _validateName = false;
                          (_emailController.text.isEmpty || !validator.email(_emailController.text)) ? _validateEmail = true : _validateEmail = false;
                          (_passwordController.text.isEmpty || !validator.password(_passwordController.text)) ? _validatePassword = true : _validatePassword = false;
                          (_passwordReController.text.isEmpty || !validator.password(_passwordController.text)) ? _validateRePassword = true : _validateRePassword = false;

                          (_aadharController.text.isEmpty || _aadharController.text.length != 12) ? _validateAadhar = true : _validateAadhar = false;
                          (_phoneController.text.isEmpty || _phoneController.text.length != 10) ? _validatePhoneNumber = true : _validatePhoneNumber = false;
                          if (_selectedDivision == null) {
                            _validateDivision = true;
                          }
                          if (_selectedGrade == null) {
                            _validateGrade = true;
                          }
                          if (_selectedInstitution == null) {
                            _validateInstitution = true;
                          }
                          if (_passwordController.text != _passwordReController.text) {
                            _validateRePassword = true;
                          }
                        });
                        if (!_validateName &&
                            !_validateEmail &&
                            !_validatePhoneNumber &&
                            !_validateGrade &&
                            !_validateInstitution &&
                            !_validateDivision &&
                            !_validateAadhar &&
                            !_validatePassword &&
                            !_validateRePassword) {
                          await _registerUser();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
