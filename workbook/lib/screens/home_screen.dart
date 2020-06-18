import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/profile_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: CircularProfileAvatar(
              null,
              child: Hero(
                tag: "profile",
                child: User.userPhotoData == null
                    ? Image.asset('images/userPhoto.jpg')
                    : Image.memory(
                        base64Decode(User.userPhotoData),
                      ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                      child: ProfilePage(), type: PageTransitionType.fade),
                );
              },
              borderColor: teal2,
              elevation: 5,
              radius: 22,
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: teal2),
      ),
      drawer: buildDrawer(context),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(
//              'Welcome,\n${User.userName.split(" ")[0]}!',
                'Welcome,\n${User.userName}!',
                maxLines: 2,
                style: TextStyle(color: teal2, fontSize: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
