import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/screens/registration_page.dart';

class FirstTime extends StatefulWidget {
  @override
  _FirstTimeState createState() => _FirstTimeState();
}

class _FirstTimeState extends State<FirstTime> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 30),
      child: Container(
        alignment: Alignment.topRight,
        //color: Colors.red,
        height: 20,
        child: Row(
          children: <Widget>[
            Text(
              'New User?',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
            FlatButton(
              padding: EdgeInsets.only(left: 10),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: RegistrationPage(),
                        type: PageTransitionType.rightToLeft));
              },
              child: Text(
                'Register here',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
