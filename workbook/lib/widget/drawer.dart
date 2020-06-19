import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:page_transition/page_transition.dart';

import 'package:workbook/screens/approve_user.dart';
import 'package:workbook/screens/approved_users.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/screens/profile_page.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/popUpDialog.dart';

Theme buildDrawer(BuildContext context) {
  return Theme(
    data: Theme.of(context).copyWith(canvasColor: teal1),
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      'images/company.jpg',
                    ),
                  ),
                ),
              ),
            ),
          ),
          buildDrawerItem(
              icon: Icons.home,
              title: "Home",
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: DashBoard(),
                        type: PageTransitionType.rightToLeft));
              }),
          buildDrawerItem(
              icon: Icons.account_circle,
              title: "Profile",
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: ProfilePage(),
                        type: PageTransitionType.rightToLeft));
              }),
          buildDrawerItem(
              icon: Icons.check,
              title: User.userRole == 'admin'
                  ? "Approve Employees"
                  : 'Approve Customers',
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                      child: ApproveUser(),
                      type: PageTransitionType.rightToLeft),
                );
              }),
          buildDrawerItem(
              icon: Icons.visibility,
              title: User.userRole == 'admin'
                  ? 'Active Employees'
                  : "Active Customers",
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                      child: AllUsers(), type: PageTransitionType.rightToLeft),
                );
              }),
          buildDrawerItem(
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
  );
}

ListTile buildDrawerItem({IconData icon, String title, Function onTap}) {
  return ListTile(
    onTap: onTap,
    title: Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ),
  );
}
