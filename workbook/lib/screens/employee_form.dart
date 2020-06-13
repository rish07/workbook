import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:http/http.dart' as http;

class EmployeeForm extends StatefulWidget {
  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  List<String> _institutes = [];
  List<String> _grades = [];
  List<String> _divisions = [];
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

  Future _registerUser() async {
    var response = await http
        .post('https://app-workbook.herokuapp.com/employee/register', body: {
      "role": "Employee",
      "userName": _nameController.text,
      "userID": _emailController.text,
      "password": _passwordController.text,
      "instituteName": _selectedInstitution,
      "grade": _selectedGrade,
      "division": _selectedDivision,
      "adharNumber": _aadharController.text,
      "contactNumber": _phoneController.text
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      popDialog(
          onPress: () {
            Navigator.push(
              context,
              PageTransition(
                  child: LoginPage(), type: PageTransitionType.rightToLeft),
            );
          },
          title: 'Registration Successful',
          context: context,
          content:
              'Your form has been submitted. Please wait for 24 hours for it to get approved');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [teal1, teal2]),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                'Employee Registration',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: InputField(
                  errorText: 'This field can\'t be empty',
                  validate: _validateName,
                  controller: _nameController,
                  labelText: 'Name',
                ),
              ),
              InputField(
                captial: TextCapitalization.none,
                controller: _emailController,
                errorText: 'Please enter a valid email ID',
                validate: _validateEmail,
                labelText: 'Email',
                textInputType: TextInputType.emailAddress,
              ),
              PasswordInput(
                controller: _passwordController,
                validate: _validatePassword,
                labelText: 'Password',
                errorText:
                    'Min Length = 8 and Max length = 15,\nShould have atleast 1 number, 1 capital letter\nand 1 Special Character',
              ),
              PasswordInput(
                controller: _passwordReController,
                validate: _validateRePassword,
                labelText: 'Re-enter Password',
                errorText: 'Passwords don\'t match',
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: DropdownButtonFormField(
                  onTap: () {
                    setState(() {
                      _validateInstitution = false;
                    });
                  },
                  decoration: InputDecoration(
                    errorText:
                        _validateInstitution ? 'Please choose an option' : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconDisabledColor: Colors.white,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  dropdownColor: Colors.teal,
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
                  items: _institutes.map((type) {
                    return DropdownMenuItem(
                      child: Text(type),
                      value: type,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: DropdownButtonFormField(
                  onTap: () {
                    setState(() {
                      _validateGrade = false;
                    });
                  },
                  decoration: InputDecoration(
                    errorText:
                        _validateGrade ? 'Please choose an option' : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconDisabledColor: Colors.white,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  dropdownColor: Colors.teal,
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
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGrade = newValue;
                    });
                  },
                  items: _grades.map((type) {
                    return DropdownMenuItem(
                      child: Text(type),
                      value: type,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: DropdownButtonFormField(
                  onTap: () {
                    setState(() {
                      _validateDivision = false;
                    });
                  },
                  decoration: InputDecoration(
                    errorText:
                        _validateDivision ? 'Please choose an option' : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconDisabledColor: Colors.white,
                  iconEnabledColor: Colors.white,
                  iconSize: 24,
                  dropdownColor: Colors.teal,
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
                  items: _divisions.map((location) {
                    return DropdownMenuItem(
                      child: Text(location),
                      value: location,
                    );
                  }).toList(),
                ),
              ),
              InputField(
                controller: _aadharController,
                validate: _validateAadhar,
                errorText: 'Please enter you 12 digit Aadhar Card number',
                textInputType: TextInputType.number,
                labelText: 'Aadhar Card Number',
              ),
              InputField(
                errorText: 'Please enter a valid 10 digit mobile number',
                controller: _phoneController,
                validate: _validatePhoneNumber,
                textInputType: TextInputType.phone,
                labelText: 'Contact Number',
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 64),
                child: Builder(
                  builder: (context) => registerButton(
                    role: 'Submit',
                    context: context,
                    onPressed: () {
                      setState(() {
                        _nameController.text.isEmpty
                            ? _validateName = true
                            : _validateName = false;
                        (_emailController.text.isEmpty ||
                                !validator.email(_emailController.text))
                            ? _validateEmail = true
                            : _validateEmail = false;
                        (_passwordController.text.isEmpty ||
                                !validator.password(_passwordController.text))
                            ? _validatePassword = true
                            : _validatePassword = false;
                        (_passwordReController.text.isEmpty ||
                                !validator.password(_passwordController.text))
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
                        if (_selectedDivision == null) {
                          _validateDivision = true;
                        }
                        if (_selectedGrade == null) {
                          _validateGrade = true;
                        }
                        if (_selectedInstitution == null) {
                          _validateInstitution = true;
                        }
                        if (_passwordController.text !=
                            _passwordReController.text) {
                          _validateRePassword = true;
                        }

                        if (!_validateName &&
                            !_validateEmail &&
                            !_validatePhoneNumber &&
                            !_validateGrade &&
                            _validateInstitution &&
                            _validateDivision &&
                            !_validateAadhar &&
                            !_validatePassword &&
                            !_validateRePassword) {
                          _registerUser();
                          _nameController.clear();
                          _emailController.clear();
                          _passwordController.clear();
                          _passwordReController.clear();

                          _aadharController.clear();
                          _phoneController.clear();
                        }
                      });
                    },
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
