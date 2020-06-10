import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:http/http.dart' as http;

class AdminForm extends StatefulWidget {
  @override
  _AdminFormState createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  String _selectedStateLocation;
  String _selectedCityLocation;

  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateRePassword = false;
  bool _validateOrganization = false;
  bool _validateNumberOrganization = false;
  bool _validateAadhar = false;
  bool _validatePhoneNumber = false;
  bool _validateMail = false;
  bool _validateState = false;
  bool _validateCity = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordReController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _organizationNumberController =
      TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  Future registerUser() async {
    var response = await http
        .post('https://app-workbook.herokuapp.com/admin/register', body: {
      "role": "Admin",
      "userName": _nameController.text,
      "userID": _emailController.text,
      "password": _passwordController.text,
      "instituteName": _organizationController.text,
      "instituteType": "Chapter",
      "instituteImage": "sample.jpeg",
      "numberOfMembers": _organizationNumberController.text,
      "state": _selectedStateLocation,
      "district": "Vellore",
      "city": _selectedCityLocation,
      "mailAddress": _mailController.text,
      "adharNumber": _aadharController.text,
      "contactNumber": _phoneController.text
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  @override
  void dispose() {
    _mailController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordReController.dispose();
    _organizationController.dispose();
    _organizationNumberController.dispose();
    _aadharController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                'Admin Registration',
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
              InputField(
                  controller: _organizationController,
                  validate: _validateOrganization,
                  errorText: 'Max length is 50',
                  labelText: 'Organization Name'),
              InputField(
                errorText: 'Please enter the number of members',
                validate: _validateNumberOrganization,
                controller: _organizationNumberController,
                labelText: 'Number of organization\nmembers',
                textInputType: TextInputType.number,
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 16.0,
                    left: 16,
                    bottom: 16,
                    right: MediaQuery.of(context).size.width * 0.2),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    errorText:
                        _validateState ? 'Please choose an option' : null,
                    enabledBorder: UnderlineInputBorder(
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
                    'Select State',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _selectedStateLocation,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStateLocation = newValue;
                    });
                  },
                  items: states.map((location) {
                    return DropdownMenuItem(
                      child: Text(location),
                      value: location,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 16.0,
                    left: 16,
                    bottom: 16,
                    right: MediaQuery.of(context).size.width * 0.2),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    errorText: _validateCity ? 'Please choose an option' : null,
                    enabledBorder: UnderlineInputBorder(
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
                    'Select City',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _selectedCityLocation,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCityLocation = newValue;
                    });
                  },
                  items: cities[_selectedStateLocation ?? 'Madhya Pradesh']
                      .map((location) {
                    return DropdownMenuItem(
                      child: AutoSizeText(
                        location,
                        maxLines: 1,
                      ),
                      value: location,
                    );
                  }).toList(),
                ),
              ),
              InputField(
                controller: _mailController,
                errorText: 'Please enter your mailing address',
                validate: _validateMail,
                labelText: 'Mailing Address',
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
                child: registerButton(
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
                      (_organizationController.text.isEmpty ||
                              _organizationController.text.length > 50)
                          ? _validateOrganization = true
                          : _validateOrganization = false;
                      _organizationNumberController.text.isEmpty
                          ? _validateNumberOrganization = true
                          : _validateNumberOrganization = false;
                      _mailController.text.isEmpty
                          ? _validateMail = true
                          : _validateMail = false;
                      (_aadharController.text.isEmpty ||
                              _aadharController.text.length != 12)
                          ? _validateAadhar = true
                          : _validateAadhar = false;
                      (_phoneController.text.isEmpty ||
                              _phoneController.text.length != 10)
                          ? _validatePhoneNumber = true
                          : _validatePhoneNumber = false;
                      if (_selectedStateLocation == null) {
                        _validateState = true;
                      }
                      if (_selectedCityLocation == null) {
                        _validateCity = true;
                      }
                      if (_passwordController.text !=
                          _passwordReController.text) {
                        _validateRePassword = true;
                      }
                      if (!_validateName &&
                          !_validateEmail &&
                          !_validatePhoneNumber &&
                          !_validateNumberOrganization &&
                          !_validateMail &&
                          !_validateCity &&
                          !_validateState &&
                          !_validateAadhar &&
                          !_validateOrganization &&
                          !_validatePassword &&
                          !_validateRePassword) {
                        registerUser();
                        _nameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                        _passwordReController.clear();
                        _organizationController.clear();
                        _selectedCityLocation = null;
                        _selectedStateLocation = null;
                        _organizationNumberController.clear();
                        _mailController.clear();
                        _aadharController.clear();
                        _phoneController.clear();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
