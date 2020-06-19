import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/profile_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  void initState() {
    _setData();
    // TODO: implement initState
    super.initState();
  }

  Future _setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      User.userName = prefs.getString('userName');
      User.userEmail = prefs.getString('userEmail');
      User.userID = prefs.getString('userID');
      User.userRole = prefs.getString('userRole');
      User.instituteImage = prefs.getString('instituteImage');
      User.instituteName = prefs.getString('instituteName');
      User.userInstituteType = prefs.getString('userInstituteType');
      User.numberOfMembers = prefs.getInt('numberOfMembers');
      User.state = prefs.getString('state');
      User.city = prefs.getString('city');
      User.mailAddress = prefs.getString('mailAddress');
      User.aadharNumber = prefs.getInt('aadharNumber');
      User.grade = prefs.getString('grade');
      User.division = prefs.getString('division');
      User.contactNumber = prefs.getInt('contactNumber');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: ProfilePage(),
                        type: PageTransitionType.rightToLeft));
              },
              child: Hero(
                tag: "profile",
                child: CircleAvatar(
                  radius: 23,
                  backgroundImage: User.userPhotoData == null
                      ? AssetImage('images/userPhoto.jpg')
                      : NetworkImage((User.userPhotoData)),
                ),
              ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 64),
              child: AutoSizeText(
//              'Welcome,\n${User.userName.split(" ")[0]}!',
                'Welcome to ${User.instituteName},\n${User.userName?.split(" ")[0]}!',
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
