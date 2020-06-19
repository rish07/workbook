import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:workbook/user.dart';

class AdminForm extends StatefulWidget {
  @override
  _AdminFormState createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  bool _isLoading = false;
  String imageAsB64;
  File _image;
  final picker = ImagePicker();
  String _selectedStateLocation;
  String _selectedCityLocation;
  String _selectedInstitutionType;
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
  bool _validateInstituteType = false;
  String imagePath;
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

  Future<String> _registerUser(filename, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['role'] = 'Admin';
    request.fields['userName'] = _nameController.text;
    request.fields['userID'] = _emailController.text;
    request.fields['password'] = _passwordController.text;
    request.fields['instituteName'] = _organizationController.text;
    request.fields['instituteType'] = _selectedInstitutionType;
    request.fields['numberOfMembers'] = _organizationNumberController.text;
    request.fields['state'] = _selectedStateLocation;
    request.fields['city'] = _selectedCityLocation;
    request.fields['mailAddress'] = _mailController.text;
    request.fields['adharNumber'] = _aadharController.text;
    request.fields['contactNumber'] = _phoneController.text;
    request.fields['fcmToken'] = User.userFcmToken;

    request.files.add(
      await http.MultipartFile.fromPath('instituteImage', filename),
    );

    var res = await request.send();
    if (res.statusCode == 200) {
      String response = await res.stream.bytesToString();
      print(response);
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
          buttonTitle: 'Close',
          content:
              'Your form has been submitted. Please wait for 24 hours for it to get approved');
    } else {
      print('Error: ${res.statusCode}');
    }
    return res.reasonPhrase;
  }

  Future getImage() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage.path);
      imagePath = pickedImage.path;
    });
    List<int> temp = _image.readAsBytesSync();
    imageAsB64 = base64Encode(temp);
    print(imageAsB64);
  }

  Future upload() async {
    var res = await _registerUser(imagePath, '$baseUrl/admin/register');
    setState(() {
      state = res;
      _isLoading = false;
      print(res);
    });
  }

  String state = "";

  @override
  void initState() {
    print(User.userFcmToken);
    super.initState();
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
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(teal2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _isLoading,
        child: Container(
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
                    validate: _validateName,
                    errorText: 'This field can\'t be empty',
                    controller: _nameController,
                    labelText: 'Name',
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
                PasswordInput(
                  validate: _validatePassword,
                  controller: _passwordController,
                  labelText: 'Password',
                  errorText:
                      'Min Length = 8 and Max length = 15,\nShould have atleast 1 number, 1 capital letter\nand 1 Special Character',
                ),
                PasswordInput(
                  validate: _validatePassword,
                  controller: _passwordReController,
                  labelText: 'Re-enter Password',
                  errorText: 'Passwords don\'t match',
                ),
                InputField(
                    validate: _validateOrganization,
                    controller: _organizationController,
                    errorText: 'Max length is 50',
                    labelText: 'Institution Name'),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: DropdownButtonFormField(
                    onTap: () {
                      setState(() {
                        _validateInstituteType = false;
                      });
                    },
                    decoration: InputDecoration(
                      errorText: _validateInstituteType
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
                    dropdownColor: Colors.teal,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                    hint: Text(
                      'Select Institution Type',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _selectedInstitutionType,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedInstitutionType = newValue;
                      });
                    },
                    items: instituteType.map((type) {
                      return DropdownMenuItem(
                        child: Text(type),
                        value: type,
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white70)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Institution Image',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            color: Colors.white,
                            onPressed: () {
                              getImage();
                            },
                            child: _image == null
                                ? Text('Choose a file')
                                : Text('Uploaded!'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InputField(
                  validate: _validateNumberOrganization,
                  errorText: 'Please enter the number of members',
                  controller: _organizationNumberController,
                  labelText: 'Number of members',
                  textInputType: TextInputType.number,
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: DropdownButtonFormField(
                    onTap: () {
                      setState(() {
                        _validateState = false;
                      });
                    },
                    decoration: InputDecoration(
                      errorText:
                          _validateState ? 'Please choose an option' : null,
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
                  padding: EdgeInsets.all(16),
                  child: DropdownButtonFormField(
                    onTap: () {
                      setState(() {
                        _validateCity = false;
                      });
                    },
                    decoration: InputDecoration(
                      errorText:
                          _validateCity ? 'Please choose an option' : null,
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
                  validate: _validateMail,
                  maxLines: 5,
                  controller: _mailController,
                  errorText: 'Please enter your mailing address',
                  labelText: 'Mailing Address',
                ),
                InputField(
                  validate: _validateAadhar,
                  controller: _aadharController,
                  errorText: 'Please enter you 12 digit Aadhar Card number',
                  textInputType: TextInputType.number,
                  labelText: 'Aadhar Card Number',
                ),
                InputField(
                  validate: _validatePhoneNumber,
                  errorText: 'Please enter a valid 10 digit mobile number',
                  controller: _phoneController,
                  textInputType: TextInputType.phone,
                  labelText: 'Contact Number',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 64),
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
                          if (_selectedInstitutionType == null) {
                            _validateInstituteType = true;
                          }
                          if (_selectedCityLocation == null) {
                            _validateCity = true;
                          }
                          if (_passwordController.text !=
                              _passwordReController.text) {
                            _validateRePassword = true;
                          }
                          if (_image == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Please upload the institution image!'),
                              action: SnackBarAction(
                                  label: 'Okay', onPressed: () {}),
                            ));
                          }
                        });
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
                            !_validateRePassword &&
                            _image != null) {
                          setState(() {
                            _isLoading = true;
                          });

                          await upload();

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
