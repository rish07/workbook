import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/prefer_universal/io.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/auth/login_page.dart';
import 'package:workbook/screens/auth/otp_verification.dart';
import 'package:workbook/screens/responsive_widget.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/registerButton.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;

import 'package:firebase/firebase.dart' as fb;
import 'dart:io' as io;
import 'package:workbook/user.dart';
import 'dart:math' as math;
import 'package:path/path.dart' as p;

class AdminForm extends StatefulWidget {
  @override
  _AdminFormState createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  final math.Random random = math.Random();
  bool _showEmail = false;
  fb.UploadTask _uploadTask;
  bool _isLoading = false;
  String imageAsB64;
  final picker = ImagePicker();
  String _selectedStateLocation;
  String _selectedCityLocation;
  String _selectedInstitutionType;
  bool _validateCityName = false;
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
  final TextEditingController _cityNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordReController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _organizationNumberController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  String fileType = '';
  io.File _file;
  String fileName = '';
  String mediaUrl = '';
  String imgb64;
  bool imageExists = false;
  String imageUrl;

  // Picks the file from local storage
  Future filePicker(BuildContext context) async {
    try {
      _file = await FilePicker.getFile(type: FileType.image);
      setState(() {
        fileName = p.basename(_file.path);
      });
      print(fileName);
      _uploadFile();
    } catch (e) {
      print(e);
    }
  }

  // Send email verification OTP
  // Future _sendEmailVerification(String email) async {
  //   var response = await http.post('$baseUrl/sendVerification', body: {
  //     "userID": email,
  //     "role": "admin",
  //   });
  //   print(response.body);
  //
  //   if (json.decode(response.body)['statusCode'] == 200) {
  //     Fluttertoast.showToast(context, msg: 'Email sent', gravity: ToastGravity.CENTER);
  //     Navigator.push(
  //       context,
  //       PageTransition(
  //           child: OTPVerification(
  //             role: 'admin',
  //             name: _nameController.text,
  //             password: _passwordController.text,
  //             instituteName: _organizationController.text,
  //             instituteImageUrl: mediaUrl,
  //             instituteType: _selectedInstitutionType,
  //             numberOfMembers: _organizationNumberController.text.toString(),
  //             state: _selectedStateLocation,
  //             city: _selectedCityLocation,
  //             mail: _mailController.text,
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

  // Upload the files to firebase storage
  Future<void> _uploadFile() async {
    setState(() {
      _isLoading = true;
    });
    StorageReference storageReference;
    int rand = random.nextInt(1000);
    storageReference = FirebaseStorage.instance.ref().child("images/$rand");

    final StorageUploadTask uploadTask = storageReference.putFile(_file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    setState(() {
      mediaUrl = url;
      _isLoading = false;
      Fluttertoast.showToast(context, msg: 'File attached successfully');
    });
    print("URL is $url");
  }

  // For the website
  File imageFile;

  uploadImage() async {
    // HTML input element
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen(
      (changeEvent) {
        final file = uploadInput.files.first;
        final reader = html.FileReader();

        reader.readAsDataUrl(file);

        reader.onLoadEnd.listen(
          (loadEndEvent) async {
            uploadImageFile(file, imageName: _organizationController.text.toString());
          },
        );
      },
    );
  }

  Future<Uri> uploadImageFile(html.File image, {String imageName}) async {
    setState(() {
      _isLoading = true;
    });
    fb.StorageReference storageRef = fb.app().storage().ref('images/$imageName');
    fb.UploadTaskSnapshot uploadTaskSnapshot = await storageRef.put(image).future;

    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    print(imageUri);
    setState(() {
      imageUrl = imageUri.toString();
      mediaUrl = imageUrl;
      _isLoading = false;
      Fluttertoast.showToast(context, msg: 'Uploaded successfully');
    });
    return imageUri;
  }

  Future _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    var response = await http.post("$baseUrl/admin/register", body: {
      "userName": _nameController.text.toString(),
      "userID": _emailController.text.toString(),
      "password": _passwordController.text,
      "instituteName": _organizationController.text,
      "instituteType": _selectedInstitutionType,
      "instituteImageUrl": mediaUrl,
      "numberOfMembers": _organizationNumberController.text,
      "state": _selectedStateLocation,
      "city": _selectedCityLocation,
      "mailAddress": _mailController.text.toString(),
      "adharNumber": _aadharController.text,
      "contactNumber": _phoneController.text,
      "fcmToken": User.userFcmToken == null ? 'fcmToken' : User.userFcmToken,
    });
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

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _passwordReController.clear();
      _organizationController.clear();
      _cityNameController.clear();
      _selectedCityLocation = null;
      _selectedStateLocation = null;
      _organizationNumberController.clear();
      _mailController.clear();
      _aadharController.clear();
      _phoneController.clear();
    } else if (json.decode(response.body)['payload']['err']['keyValue'] != null) {
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
                                ? size.width * 0.3
                                : ResponsiveWidget.isLargeScreen(context)
                                    ? size.width * 0.4
                                    : 20)
                        : Container(),
                    Text(
                      'Admin Registration',
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
                    onChange: () {
                      setState(() {
                        _showEmail = true;
                      });
                    },
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
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: ResponsiveWidget.isMediumScreen(context)
                              ? size.width * 0.15
                              : ResponsiveWidget.isLargeScreen(context)
                                  ? size.width * 0.27
                                  : 0),
                  child: InputField(validate: _validateOrganization, controller: _organizationController, errorText: 'Max length is 50', labelText: 'Institution Name'),
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
                          _validateInstituteType = false;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: _validateInstituteType ? 'Please choose an option' : null,
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
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.white70)),
                    child: Row(
                      mainAxisAlignment: Platform.isAndroid ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: Platform.isAndroid ? EdgeInsets.zero : EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Institution Image',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, right: Platform.isAndroid ? 0 : 5),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            color: Colors.white,
                            onPressed: () async {
                              if (Platform.isAndroid) {
                                filePicker(context);
                              } else {
                                await uploadImage();
                              }
                            },
                            child: _file != null || imageUrl != null ? Text('Uploaded!') : Text('Choose a file'),
                          ),
                        ),
                      ],
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
                    validate: _validateNumberOrganization,
                    errorText: 'Please enter the number of members',
                    controller: _organizationNumberController,
                    labelText: 'Number of members',
                    textInputType: TextInputType.number,
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
                          _validateState = false;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: _validateState ? 'Please choose an option' : null,
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
                          _validateCity = false;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: _validateCity ? 'Please choose an option' : null,
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
                        'Select City',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _selectedCityLocation,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCityLocation = newValue;
                        });
                      },
                      items: cities[_selectedStateLocation ?? 'Madhya Pradesh'].map((location) {
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
                ),
                _selectedCityLocation == 'Others'
                    ? Padding(
                        padding: Platform.isAndroid
                            ? EdgeInsets.zero
                            : EdgeInsets.symmetric(
                                horizontal: ResponsiveWidget.isMediumScreen(context)
                                    ? size.width * 0.15
                                    : ResponsiveWidget.isLargeScreen(context)
                                        ? size.width * 0.27
                                        : 0),
                        child: InputField(
                          validate: _validateCityName,
                          controller: _cityNameController,
                          errorText: 'Please enter your city name',
                          labelText: 'City Name',
                        ),
                      )
                    : Container(),
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
                    validate: _validateMail,
                    maxLines: 5,
                    controller: _mailController,
                    errorText: 'Please enter your institute\'s mailing address',
                    labelText: 'Institute Mailing Address',
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
                          _selectedCityLocation == 'Others'
                              ? _cityNameController.text.isEmpty
                                  ? _validateCityName = true
                                  : _validateCityName = false
                              : Container();
                          (_emailController.text.isEmpty || !validator.email(_emailController.text)) ? _validateEmail = true : _validateEmail = false;
                          (_passwordController.text.isEmpty || !validator.password(_passwordController.text)) ? _validatePassword = true : _validatePassword = false;
                          (_passwordReController.text.isEmpty || !validator.password(_passwordController.text)) ? _validateRePassword = true : _validateRePassword = false;
                          (_organizationController.text.isEmpty || _organizationController.text.length > 50) ? _validateOrganization = true : _validateOrganization = false;
                          _organizationNumberController.text.isEmpty ? _validateNumberOrganization = true : _validateNumberOrganization = false;
                          _mailController.text.isEmpty ? _validateMail = true : _validateMail = false;
                          (_aadharController.text.isEmpty || _aadharController.text.length != 12) ? _validateAadhar = true : _validateAadhar = false;
                          (_phoneController.text.isEmpty || _phoneController.text.length != 10) ? _validatePhoneNumber = true : _validatePhoneNumber = false;
                          if (_selectedStateLocation == null) {
                            _validateState = true;
                          }
                          if (_selectedInstitutionType == null) {
                            _validateInstituteType = true;
                          }
                          if (_selectedCityLocation == null) {
                            _validateCity = true;
                          }
                          if (_passwordController.text != _passwordReController.text) {
                            _validateRePassword = true;
                          }
                          if (_file == null && imageUrl == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Please upload the institution image!'),
                              action: SnackBarAction(label: 'Okay', onPressed: () {}),
                            ));
                          }
                        });
                        if (!_validateName && !_validateEmail && !_validatePhoneNumber && !_validateNumberOrganization && !_validateMail && _selectedCityLocation == 'Other'
                            ? _validateCityName
                            : true &&
                                !_validateCity &&
                                !_validateState &&
                                !_validateAadhar &&
                                !_validateOrganization &&
                                !_validatePassword &&
                                !_validateMail &&
                                !_validateRePassword &&
                                (_file != null || imageUrl != null)) {
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
