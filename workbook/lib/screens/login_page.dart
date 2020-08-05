import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/coming_soon.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/guest_ticket.dart';
import 'package:workbook/screens/otp_verification.dart';
import 'dart:convert';
import 'package:workbook/widget/first.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/widget/password.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:workbook/widget/textLogin.dart';
import 'package:workbook/widget/verticalText.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  final _formKey = GlobalKey<FormState>();
  User user = User();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmToken;
  bool _loading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);

      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      '91512',
      'Workbook',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics, payload: json.encode(message));
  }

  @override
  void initState() {
    getFCMToken();
    getInstitutes();
    super.initState();
    registerNotification();
    configLocalNotification();
    connectivity = new Connectivity();
    subscription = connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      } else {
        popDialog(
            title: 'No Network!',
            context: context,
            content: 'Please recheck your internet connection and try again!',
            buttonTitle: 'Okay',
            onPress: () {
              SystemChannels.platform.invokeListMethod('SystemNavigator.pop');
            });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void getFCMToken() async {
    fcmToken = await _firebaseMessaging.getToken();
    setState(() {
      User.userFcmToken = fcmToken;
    });
    print('fcm');
    print(fcmToken);
  }

  Future getInstitutes() async {
    print('working ins');
    var response = await http.get("$baseUrl/superAdmin/viewAllAdmin");
    print('Response status: ${response.statusCode}');
    List temp = json.decode(response.body)['payload']['admin'];
    temp.forEach((resp) {
      if (resp['approved'] == true) {
        institutes.add(resp['instituteName']);
      }
    });
    institutes = Set.of(institutes).toList();
    print(institutes);
  }

  Future _resetPassword(String email) async {
    var response = await http.get('$baseUrl/forgot/$email');
    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      Fluttertoast.showToast(context, msg: 'Email sent', gravity: ToastGravity.CENTER);
      Navigator.push(
        context,
        PageTransition(
            child: OTPVerification(
              email: email,
            ),
            type: PageTransitionType.fade),
      );
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
    }
  }

  Future _loginUser() async {
    print('working');
    var response = await http.post('$baseUrl/login', body: {"userID": _emailController.text, "password": _passwordController.text, "fcmToken": fcmToken});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() {
      _loading = false;
    });
    var resp = json.decode(response.body)['payload'];
    if (resp['approved'] == true) {
      var tempo = resp['user'];

      setState(() {
        User.userRoute = resp['user']['route'] != null ? resp['user']['route'][0]['routeName'] : null;
        User.userJwtToken = resp['jwtToken'];
        User.userName = tempo['userName'] ?? null;
        User.userID = tempo['_id'] ?? null;
        User.userRole = tempo['role'] ?? null;
        User.userEmail = tempo['userID'] ?? null;
        User.instituteName = tempo['instituteName'] ?? null;
        User.instituteImage = tempo['instituteImageUrl'];
        User.userInstituteType = tempo['instituteType'] ?? null;
        User.numberOfMembers = tempo['numberOfMembers'] ?? null;
        User.state = tempo['state'] ?? null;
        User.city = tempo['city'] ?? null;
        User.mailAddress = tempo['mailAddress'] ?? null;
        User.aadharNumber = tempo['adharNumber'] ?? null;
        User.grade = tempo['grade'] ?? null;
        User.division = tempo['division'] ?? null;
        User.contactNumber = tempo['contactNumber'] ?? null;
        User.userPhotoData = tempo['profilePictureUrl'] ?? null;
        User.profilePicExists = tempo['profilePictureUrl'] == null ? false : true;
        User.carNumber = tempo['carNumber'] ?? null;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', User.userName);
      prefs.setString('userEmail', User.userEmail);
      prefs.setString('userID', User.userID);
      prefs.setString('userRole', User.userRole);
      prefs.setString('instituteImage', User.instituteImage);
      prefs.setString('instituteName', User.instituteName);
      prefs.setString('userInstituteType', User.userInstituteType);
      prefs.setInt('numberOfMembers', User.numberOfMembers);
      prefs.setString('state', User.state);
      prefs.setString('city', User.city);
      prefs.setString('mailAddress', User.mailAddress);
      prefs.setInt('aadharNumber', User.aadharNumber);
      prefs.setString('grade', User.grade);
      prefs.setString('division', User.division);
      prefs.setInt('contactNumber', User.contactNumber);
      prefs.setString('userPhotoData', User.userPhotoData);
      prefs.setString('userJwtToken', User.userJwtToken);
      prefs.setBool('profilePicExists', User.profilePicExists);

      Navigator.push(
        context,
        PageTransition(child: User.userRole == 'customer' ? ComingSoon() : DashBoard(), type: PageTransitionType.rightToLeft),
      );
    } else if (json.decode(response.body)['statusCode'] == 401) {
      popDialog(
        onPress: () {
          Navigator.pop(context);
        },
        context: context,
        title: 'Incorrect Password',
        content: 'Please re-check your password and try again',
        buttonTitle: 'Close',
      );
    } else if (json.decode(response.body)['statusCode'] == 500) {
      popDialog(
        onPress: () {
          Navigator.pop(context);
        },
        context: context,
        title: "User Not Found",
        content: 'Please register first and try again.',
        buttonTitle: 'Close',
      );
    } else {
      popDialog(
        onPress: () {
          Navigator.pop(context);
        },
        context: context,
        title: 'Request Pending',
        content: 'Please wait while the request is approved',
        buttonTitle: 'Close',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
      onWillPop: () async => false,
      child: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet2),
          backgroundColor: Colors.transparent,
        ),
        opacity: 0.5,
        color: Colors.white,
        dismissible: false,
        inAsyncCall: _loading,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [violet1, violet2]),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(children: <Widget>[
                    VerticalText(),
                    TextLogin(),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InputField(
                      validate: false,
                      validation: (String arg) {
                        if (arg.isEmpty) {
                          return "This field can't  be empty";
                        } else if (!validator.email(arg)) {
                          return "Please enter a valid email ID";
                        } else
                          return null;
                      },
                      capital: TextCapitalization.none,
                      controller: _emailController,
                      labelText: 'Email',
                      textInputType: TextInputType.emailAddress,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: PasswordInput(
                      validate: false,
                      controller: _passwordController,
                      validation: (String arg) {
                        if (arg.isEmpty) {
                          return "This field can't be empty";
                        } else
                          return null;
                      },
                      labelText: 'Password',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: GestureDetector(
                      onTap: () {
                        final TextEditingController _controller = TextEditingController();
                        bool _validate = false;
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              title: Center(
                                  child: Text(
                                'Trouble Logging in? ',
                                style: TextStyle(color: violet1),
                              )),
                              content: TextFormField(
                                cursorColor: Colors.black,
                                controller: _controller,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: violet1),
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(color: Colors.red),
                                  errorText: _validate ? 'Please enter a valid email ID' : null,
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: violet2)),
                                  hintText: 'Enter your email ID',
                                  hintStyle: TextStyle(
                                    color: violet1,
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new MaterialButton(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    color: violet2,
                                    child: new Text(
                                      'Reset',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _loading = true;
                                        validator.email(_controller.text) && _controller.text.isNotEmpty ? _validate = false : _validate = true;
                                      });
                                      if (!_validate) {
                                        await _resetPassword(_controller.text);
                                      } else {
                                        Fluttertoast.showToast(context, msg: 'Please enter a valid email ID', gravity: ToastGravity.CENTER);
                                      }
                                      setState(() {
                                        _loading = false;
                                      });
                                    }),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Trouble logging in? Click here',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(child: GenerateTicket(), type: PageTransitionType.rightToLeft),
                              );
                            },
                            child: Text(
                              'Guest user?',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )),
                        Container(
                          alignment: Alignment.bottomRight,
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: FlatButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                print('working');
                                setState(() {
                                  _loading = true;
                                });
                                await _loginUser();
                              }
//                        setState(() {
//                          (_emailController.text.isEmpty ||
//                                  !validator.email(_emailController.text))
//                              ? _validateEmail = true
//                              : _validateEmail = false;
//                          _passwordController.text.isEmpty
//                              ? _validatePassword = true
//                              : _validatePassword = false;
//                        });
//
//                        if (!_validatePassword && !_validateEmail) {
//                          setState(() {
//                            _loading = true;
//                          });
//                          await loginUser();
//                          _passwordController.clear();
//                          _emailController.clear();
//                          _selectedRole = null;
//                        }
                            },
                            child: Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FirstTime(),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
