import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/screens/approve_employee.dart';
import 'package:workbook/screens/home_screen.dart';
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
            child: Stack(),
          ),
          buildDrawerItem(
              icon: Icons.home,
              title: "Home",
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: HomeScreen(),
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
          User.userRole == 'admin'
              ? buildDrawerItem(
                  icon: Icons.check,
                  title: 'Approve Employees',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: ApproveEmployees(),
                          type: PageTransitionType.rightToLeft),
                    );
                  })
              : Container(),
          buildDrawerItem(
              icon: Icons.exit_to_app,
              title: 'Logout',
              onTap: () {
                popDialog(
                    buttonTitle: 'Logout',
                    title: 'Logout?',
                    context: context,
                    content: 'Do you want to logout from your profile?',
                    onPress: () {
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
