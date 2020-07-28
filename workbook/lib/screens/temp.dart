import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/screens/google_sign_in.dart';
import 'package:workbook/screens/web_view.dart';
import 'package:simple_auth/simple_auth.dart';

class TempPage extends StatefulWidget {
  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              signInButton(context),
              MaterialButton(
                color: Colors.red,
                onPressed: () async {
                  await googleSignIn.signOut();
                  Fluttertoast.showToast(context, msg: 'Logged out');
                },
                child: Text('logout'),
              ),
              MaterialButton(
                color: Colors.red,
                onPressed: () async {},
                child: Text('Micro'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget signInButton(BuildContext context) {
  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: () async {
      final user = await signInWithGoogle();
      print(user);
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("images/google_logo.png"), height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
