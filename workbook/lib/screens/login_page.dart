import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/dash_board.dart';
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
  User user = User();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List _roles = ['Admin', 'Employee', 'Customer', 'Driver'];
  String _selectedRole;
  bool _validateRole = false;
  String fcmToken;
  bool _loading = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
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
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
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
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  @override
  void initState() {
    getFCMToken();
    super.initState();
    registerNotification();
    configLocalNotification();
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

  Future loginUser() async {
    var response = await http
        .post('https://app-workbook.herokuapp.com/$_selectedRole/login', body: {
      "email": _emailController.text,
      "password": _passwordController.text,
      "fcmToken": fcmToken
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() {
      _loading = false;
    });
    var resp = json.decode(response.body)['payload'];
    if (resp['approved'] == true) {
      var tempo = resp[_selectedRole.toLowerCase()];

      setState(() {
        User.userName = tempo['userName'] ?? null;
        User.userID = tempo['_id'] ?? null;
        User.userRole = tempo['role'] ?? null;
        User.userEmail = tempo['userID'] ?? null;
        User.instituteName = tempo['instituteName'] ?? null;
        User.instituteImage = tempo['instituteImage'] ?? null;
        User.userInstituteType = tempo['instituteType'] ?? null;
        User.numberOfMembers = tempo['numberOfMembers'] ?? null;
        User.state = tempo['state'] ?? null;
        User.city = tempo['city'] ?? null;
        User.mailAddress = tempo['mailAddress'] ?? null;
        User.aadharNumber = tempo['adharNumber'] ?? null;
        User.grade = tempo['grade'] ?? null;
        User.division = tempo['division'] ?? null;
        User.contactNumber = tempo['contactNumber'] ?? null;
      });
      Navigator.push(
        context,
        PageTransition(
            child: DashBoard(), type: PageTransitionType.rightToLeft),
      );
    } else {
      popDialog(
        onPress: () {
          Navigator.pop(context);
        },
        context: context,
        title: 'Request Pending',
        content: 'Please wait while the super-admin approves your request',
        buttonTitle: 'Close',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        opacity: 0.5,
        color: Colors.white,
        dismissible: false,
        inAsyncCall: _loading,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [teal1, teal2]),
          ),
          child: ListView(
            children: <Widget>[
              Row(children: <Widget>[
                VerticalText(),
                TextLogin(),
              ]),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputField(
                  captial: TextCapitalization.none,
                  errorText: 'Please enter a valid email ID',
                  controller: _emailController,
                  validate: _validateEmail,
                  labelText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: PasswordInput(
                  errorText: 'This field can\'t be empty',
                  controller: _passwordController,
                  validate: _validatePassword,
                  labelText: 'Password',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: DropdownButtonFormField(
                  onTap: () {
                    setState(() {
                      _validateRole = false;
                    });
                  },
                  decoration: InputDecoration(
                    errorText: _validateRole ? 'Please choose an option' : null,
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
                    'Login as',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _selectedRole,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  items: _roles.map((location) {
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
              Padding(
                padding: const EdgeInsets.only(top: 40, right: 20, left: 250),
                child: Container(
                  alignment: Alignment.bottomRight,
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FlatButton(
                    onPressed: () async {
                      print('working');

                      if (_selectedRole == null) {
                        _validateRole = true;
                      }
                      (_emailController.text.isEmpty ||
                              !validator.email(_emailController.text))
                          ? _validateEmail = true
                          : _validateEmail = false;
                      _passwordController.text.isEmpty
                          ? _validatePassword = true
                          : _validatePassword = false;

                      if (!_validateRole &&
                          !_validatePassword &&
                          !_validateEmail) {
                        setState(() {
                          _loading = true;
                        });
                        await loginUser();
                        _passwordController.clear();
                        _emailController.clear();
                        _selectedRole = null;
                      }
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
              ),
              FirstTime(),
            ],
          ),
        ),
      ),
    );
  }
}
