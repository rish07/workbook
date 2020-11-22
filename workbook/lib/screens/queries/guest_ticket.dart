import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:universal_io/io.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/auth/login_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/popUpDialog.dart';

import '../../responsive_widget.dart';

class GenerateTicket extends StatefulWidget {
  @override
  _GenerateTicketState createState() => _GenerateTicketState();
}

class _GenerateTicketState extends State<GenerateTicket> {
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePhoneNumber = false;
  bool _validateDescription = false;
  bool _validateInstitution = false;
  String _selectedInstitution;

  // Generate query
  Future createTicket() async {
    var response = await http.post('$baseUrl/guest/createQuery', body: {
      "userName": _nameController.text.toString(),
      "userID": _emailController.text.toString(),
      "message": _descriptionController.text.toString(),
      "fcmToken": User.userFcmToken ?? 'fcmToken',
      "instituteName": _selectedInstitution,
      "contactNumber": _phoneController.text
    });

    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      popDialog(
          title: "Submitted successfully",
          context: context,
          content:
              "Your query has been submitted successfully. Please wait for the admin to contact you",
          buttonTitle: 'Close',
          onPress: () {
            Navigator.push(
              context,
              PageTransition(
                  child: LoginPage(), type: PageTransitionType.rightToLeft),
            );
            _nameController.clear();
            _emailController.clear();
            _descriptionController.clear();
            _selectedInstitution = null;
          });
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(violet2),
        backgroundColor: Colors.transparent,
      ),
      inAsyncCall: _isLoading,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [violet1, violet2]),
              ),
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    'Enquiry Form',
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
                            horizontal: ResponsiveWidget.isMediumScreen(context)
                                ? size.width * 0.15
                                : ResponsiveWidget.isLargeScreen(context)
                                    ? size.width * 0.32
                                    : 0),
                    child: InputField(
                      errorText: 'This field can\'t be empty',
                      labelText: 'Name',
                      validate: _validateName,
                      controller: _nameController,
                    ),
                  ),
                  Padding(
                    padding: Platform.isAndroid
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(
                            horizontal: ResponsiveWidget.isMediumScreen(context)
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
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(
                            horizontal: ResponsiveWidget.isMediumScreen(context)
                                ? size.width * 0.15
                                : ResponsiveWidget.isLargeScreen(context)
                                    ? size.width * 0.32
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
                    padding: Platform.isAndroid
                        ? EdgeInsets.all(16)
                        : EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: ResponsiveWidget.isMediumScreen(context)
                                ? size.width * 0.168
                                : ResponsiveWidget.isLargeScreen(context)
                                    ? size.width * 0.328
                                    : 0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: violet1,
                      ),
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
                        ? EdgeInsets.only(top: 16.0)
                        : EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: ResponsiveWidget.isMediumScreen(context)
                                ? size.width * 0.165
                                : ResponsiveWidget.isLargeScreen(context)
                                    ? size.width * 0.328
                                    : 0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        autocorrect: true,
                        maxLines: 10,
                        onTap: () {
                          setState(() {
                            _validateDescription = false;
                          });
                        },
                        cursorRadius: Radius.circular(8),
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: _descriptionController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 18),
                          isDense: true,
                          errorMaxLines: 1,
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2),
                          ),
                          errorStyle: TextStyle(height: 0, fontSize: 10),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          errorText: _validateDescription
                              ? "This field can't be empty"
                              : null,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white70, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          fillColor: Colors.lightBlueAccent,
                          labelText: "Enquiry description",
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: Platform.isAndroid
                        ? EdgeInsets.symmetric(vertical: 16.0, horizontal: 64)
                        : EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: ResponsiveWidget.isMediumScreen(context)
                                ? size.width * 0.3
                                : size.width * 0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            _nameController.clear();
                            _emailController.clear();
                            _phoneController.clear();
                            _descriptionController.clear();
                            _selectedInstitution = null;
                          },
                          padding: EdgeInsets.all(16),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: violet2, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        MaterialButton(
                          padding: EdgeInsets.all(16),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          onPressed: () async {
                            setState(() {
                              _nameController.text.isEmpty
                                  ? _validateName = true
                                  : _validateName = false;
                              _descriptionController.text.isEmpty
                                  ? _validateDescription = true
                                  : _validateDescription = false;
                              (_emailController.text.isEmpty ||
                                      !validator.email(_emailController.text))
                                  ? _validateEmail = true
                                  : _validateEmail = false;
                              (_phoneController.text.isEmpty ||
                                      !validator.phone(_phoneController.text))
                                  ? _validatePhoneNumber = true
                                  : _validatePhoneNumber = false;
                              if (_selectedInstitution == null) {
                                _validateInstitution = true;
                              }
                            });

                            if (!_validateInstitution &&
                                !_validateDescription &&
                                !_validateName &&
                                !_validatePhoneNumber &&
                                !_validateEmail) {
                              setState(() {
                                _isLoading = true;
                              });
                              await createTicket();
                            }
                          },
                          child: Text(
                            'Submit Enquiry',
                            style: TextStyle(
                                color: violet2, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
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
