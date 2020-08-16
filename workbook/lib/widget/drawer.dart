import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/screens/add_grade.dart';

import 'package:workbook/screens/approve_user.dart';

import 'package:workbook/screens/coming_soon.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/screens/profile_page.dart';
import 'package:workbook/screens/query_data.dart';
import 'package:workbook/screens/settings.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/popUpDialog.dart';

Theme buildDrawer(BuildContext context) {
  return Theme(
    data: Theme.of(context).copyWith(canvasColor: violet1),
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          User.userRole != 'superAdmin'
              ? DrawerHeader(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: User.instituteImage != null
                              ? NetworkImage(
                                  User.instituteImage,
                                )
                              : AssetImage('images/userPhoto.jpg'),
                        ),
                      ),
                    ),
                  ),
                )
              : DrawerHeader(
                  child: Container(
                    height: 0,
                  ),
                ),
          buildDrawerItem(
              icon: Icons.home,
              title: "Home",
              onTap: () {
                Navigator.push(context, PageTransition(child: DashBoard(), type: PageTransitionType.rightToLeft));
              }),
          User.userRole != 'superAdmin'
              ? buildDrawerItem(
                  icon: Icons.account_circle,
                  title: "Profile",
                  onTap: () {
                    Navigator.push(context, PageTransition(child: ProfilePage(), type: PageTransitionType.rightToLeft));
                  })
              : Container(),
          User.userRole == 'admin'
              ? buildDrawerItem(
                  icon: Icons.arrow_downward,
                  title: 'Grades and Divisions',
                  onTap: () {
                    Navigator.push(context, PageTransition(child: AddGrade(), type: PageTransitionType.rightToLeft));
                  })
              : Container(),
          buildDrawerItem(
              icon: Icons.person,
              title: User.userRole == 'admin' ? "Employees" : (User.userRole == 'employee') ? 'Customers' : 'Admins',
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
              ? buildDrawerItem(
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
          User.userRole == 'admin'
              ? buildDrawerItem(
                  icon: Icons.question_answer,
                  title: 'Queries',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(child: QueryData(), type: PageTransitionType.rightToLeft),
                    );
                  })
              : Container(),
          User.userRole == 'employee' || User.userRole == 'customer'
              ? buildDrawerItem(
                  icon: Icons.map,
                  title: 'Travel',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: ComingSoon(),
//                          child: GoogleMapScreen(
//                            routeName: User.userRoute,
//                            isEdit: false,
//                          ),
                          type: PageTransitionType.rightToLeft),
                    );
                  })
              : Container(),
          buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(child: Settings(), type: PageTransitionType.rightToLeft),
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
                      SharedPreferences prefs = await SharedPreferences.getInstance();
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

                      Navigator.pushAndRemoveUntil(context, PageTransition(child: LoginPage(), type: PageTransitionType.rightToLeft), (route) => false);
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
