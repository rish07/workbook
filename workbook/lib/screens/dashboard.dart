import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_image/network.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/add_GD.dart';
import 'package:workbook/screens/add_post.dart';
import 'package:workbook/screens/approve_user.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/screens/profile_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'package:workbook/widget/popUpDialog.dart';

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
      User.userPhotoData = prefs.getString('userPhotoData');
      User.profilePicExists = prefs.getBool('profilePicExists');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feed',
          style: TextStyle(
              color: teal2, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
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
                  backgroundImage: !User.profilePicExists
                      ? AssetImage('images/userPhoto.jpg')
                      : NetworkImageWithRetry((User.userPhotoData)),
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: teal2),
      ),
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
                User.userRole != "superAdmin"
                    ? 'Welcome to ${User.instituteName},\n${User.userName?.split(" ")[0]}!'
                    : "Welcome,\n${User.userName}",
                maxLines: 2,
                style: TextStyle(color: teal2, fontSize: 50),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal2,
        child: User.userRole == 'superAdmin'
            ? Icon(Icons.add)
            : Icon(Icons.refresh),
        onPressed: User.userRole == 'superAdmin'
            ? () {
                Navigator.push(
                  context,
                  PageTransition(
                      child: AddPost(), type: PageTransitionType.downToUp),
                );
              }
            : () {},
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  return showModalBottomSheet<Null>(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) =>
                        openBottomDrawer(context),
                  );
                }),
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

Widget openBottomDrawer(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.4,
    child: Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 8),
            children: [
              buildDrawerItemDashboard(
                  icon: Icons.home,
                  title: "Home",
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: DashBoard(),
                            type: PageTransitionType.rightToLeft));
                  }),
              User.userRole != 'superAdmin'
                  ? buildDrawerItemDashboard(
                      icon: Icons.account_circle,
                      title: "Profile",
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: ProfilePage(),
                                type: PageTransitionType.rightToLeft));
                      })
                  : Container(),
              User.userRole == 'admin'
                  ? buildDrawerItemDashboard(
                      icon: Icons.arrow_downward,
                      title: 'Grades and Divisions',
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: AddGD(),
                                type: PageTransitionType.rightToLeft));
                      })
                  : Container(),
              buildDrawerItemDashboard(
                  icon: Icons.person,
                  title: User.userRole == 'admin'
                      ? "Employees"
                      : (User.userRole == 'employee') ? 'Customers' : 'Admins',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: ApproveUser(
                            isDriver: false,
                          ),
                          type: PageTransitionType.rightToLeft),
                    );
                  }),
              User.userRole == 'admin'
                  ? buildDrawerItemDashboard(
                      icon: Icons.directions_car,
                      title: 'Drivers',
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: ApproveUser(
                                isDriver: true,
                              ),
                              type: PageTransitionType.rightToLeft),
                        );
                      })
                  : Container(),
              buildDrawerItemDashboard(
                  icon: Icons.exit_to_app,
                  title: 'Logout',
                  onTap: () {
                    popDialog(
                        buttonTitle: 'Logout',
                        title: 'Logout?',
                        context: context,
                        content: 'Do you want to logout from your profile?',
                        onPress: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.remove('userName');
                          prefs.remove('userEmail');
                          prefs.remove('userID');
                          prefs.remove('userRole');
                          prefs.remove('instituteName');
                          prefs.remove('instituteImage');
                          prefs.remove('userInstituteType');
                          prefs.remove('numberOfMembers');
                          prefs.remove('state');
                          prefs.remove('city');
                          prefs.remove('mailAddress');
                          prefs.remove('aadharNumber');
                          prefs.remove('grade');
                          prefs.remove('division');
                          prefs.remove('contactNumber');
                          prefs.remove('userPhotoData');

                          Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                  child: LoginPage(),
                                  type: PageTransitionType.rightToLeft),
                              (route) => false);
                        });
                  })
            ],
          ),
        ),
      ),
    ),
  );
}

ListTile buildDrawerItemDashboard(
    {IconData icon, String title, Function onTap}) {
  return ListTile(
    onTap: onTap,
    title: Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: teal2,
        ),
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            title,
            style: TextStyle(color: teal2, fontSize: 18),
          ),
        ),
      ],
    ),
  );
}
