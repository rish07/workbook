import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/widget/popUpDialog.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: teal2),
        title: Text(
          'Settings',
          style: TextStyle(color: teal2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                'Help Center',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
              title: Text(
                'Privacy Policy',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
              title: Text(
                'User Agreement',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
              title: Text(
                'End User License Agreement',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
              title: Text(
                'Sign Out',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
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
              },
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
              title: Text(
                'Version: 0.0.1',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              thickness: 2,
            ),
          ],
        ),
      ),
    );
  }
}
