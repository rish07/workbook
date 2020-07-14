import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/user.dart';
import 'package:workbook/widget/popUpDialog.dart';

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

  Future createTicket() async {
    var response = await http.post('$baseUrl/guest/createQuery', body: {
      "userName": _nameController.text.toString(),
      "userID": _emailController.text.toString(),
      "message": _descriptionController.text.toString(),
      "fcmToken": User.userFcmToken,
      "instituteName": _selectedInstitution,
      "contactNumber": _phoneController.text
    });

    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      popDialog(
          title: "Submitted successfully",
          context: context,
          content: "Your query has been submitted successfully. Please wait for the admin to contact you",
          buttonTitle: 'Close',
          onPress: () {
            Navigator.push(
              context,
              PageTransition(child: LoginPage(), type: PageTransitionType.rightToLeft),
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
              Text(
                'Generate Ticket',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InputField(
                  errorText: 'This field can\'t be empty',
                  labelText: 'Name',
                  validate: _validateName,
                  controller: _nameController,
                ),
              ),
              InputField(
                validate: _validateEmail,
                captial: TextCapitalization.none,
                controller: _emailController,
                errorText: 'Please enter a valid email ID',
                labelText: 'Email',
                textInputType: TextInputType.emailAddress,
              ),
              InputField(
                validate: _validatePhoneNumber,
                errorText: 'Please enter a valid 10 digit mobile number',
                controller: _phoneController,
                textInputType: TextInputType.phone,
                labelText: 'Contact Number',
              ),
              Padding(
                padding: EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(16.0),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                      isDense: true,
                      errorMaxLines: 1,
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      errorStyle: TextStyle(height: 0, fontSize: 10),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      errorText: _validateDescription ? "This field can't be empty" : null,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
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
                padding: EdgeInsets.symmetric(horizontal: 100.0),
                child: MaterialButton(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  onPressed: () async {
                    setState(() {
                      _nameController.text.isEmpty ? _validateName = true : _validateName = false;
                      _descriptionController.text.isEmpty ? _validateDescription = true : _validateDescription = false;
                      (_emailController.text.isEmpty || !validator.email(_emailController.text)) ? _validateEmail = true : _validateEmail = false;
                      (_phoneController.text.isEmpty || !validator.phone(_phoneController.text)) ? _validatePhoneNumber = true : _validatePhoneNumber = false;
                      if (_selectedInstitution == null) {
                        _validateInstitution = true;
                      }
                    });

                    if (!_validateInstitution && !_validateDescription && !_validateName && !_validatePhoneNumber && !_validateEmail) {
                      setState(() {
                        _isLoading = true;
                      });
                      await createTicket();
                    }
                  },
                  child: Text(
                    'Submit Enquiry',
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
