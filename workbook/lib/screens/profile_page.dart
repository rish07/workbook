import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image/network.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/widget/popUpDialog.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  String imagePath;
  final picker = ImagePicker();
  String imageAsB64;
  File _image;

  Future getImage() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage.path);
      imagePath = pickedImage.path;
    });
    List<int> temp = _image.readAsBytesSync();
    imageAsB64 = base64Encode(temp);
    print(imageAsB64);
  }

  Future<String> _updateImage(filename, url) async {
    print('update image');
    print(User.userID);
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['userID'] = User.userEmail;
    request.files.add(
      await http.MultipartFile.fromPath('profilePicture', filename),
    );
    var res = await request.send();
    String response = await res.stream.bytesToString();
    print(response);
    if (res.statusCode == 200) {
      print('worked');
    } else {
      print(res.statusCode);
    }
    return res.reasonPhrase;
  }

  Future _updatePhoto() async {
    print('update working');
    var res = await _updateImage(imagePath, '$baseUrl/uploadPicture');
    setState(() {
      state = res;
      _isLoading = false;
      print(res);
    });
  }

  Future _updateProfile() async {
    print('working');
    print(User.userRole);
    var response = await http.post('$baseUrl/${User.userRole}/update',
        body: (User.userRole == 'admin')
            ? {
                "jwtToken": User.userJwtToken,
                "id": User.userID,
                "userName": User.userName,
                "instituteType": User.userInstituteType,
                "state": User.state,
                "city": User.city,
                "mailAddress": User.mailAddress,
                "adharNumber": User.aadharNumber.toString(),
                "contactNumber": User.contactNumber.toString(),
                "fcmToken": User.userFcmToken,
              }
            : (User.userRole == 'customer')
                ? {
                    "jwtToken": User.userJwtToken,
                    "userName": User.userName,
                    "state": User.state,
                    "grade": User.grade,
                    "division": User.division,
                    "adharNumber": User.aadharNumber.toString(),
                    "contactNumber": User.contactNumber.toString(),
                    "fcmToken": User.userFcmToken
                  }
                : (User.userRole == 'driver')
                    ? {
                        "jwtToken": User.userJwtToken,
                        "userName": User.userName,
                        'carNumber': User.carNumber,
                        "adharNumber": User.aadharNumber.toString(),
                        "contactNumber": User.contactNumber.toString(),
                        "fcmToken": User.userFcmToken,
                      }
                    : {
                        "jwtToken": User.userJwtToken,
                        "userName": User.userName,
                        "grade": User.grade,
                        "division": User.division,
                        "adharNumber": User.aadharNumber.toString(),
                        "contactNumber": User.contactNumber.toString(),
                        "fcmToken": User.userFcmToken
                      });
    setState(() {
      _isLoading = false;
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      popDialog(
          onPress: () {
            Navigator.push(
              context,
              PageTransition(child: DashBoard(), type: PageTransitionType.rightToLeft),
            );
          },
          title: 'Update Successful',
          context: context,
          buttonTitle: 'Close',
          content: 'Your details have been updated');
    }
  }

  String state = "";
  bool _isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(User.profilePicExists);

    print(User.userID);
    print(User.userPhotoData);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: violet2,
          ),
          backgroundColor: Colors.transparent,
          actions: User.userRole != 'superAdmin'
              ? [
                  _isEdit
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: MaterialButton(
                              minWidth: 80,
                              color: violet2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                  _isEdit = false;
                                });
                                if (_image != null) {
                                  await _updatePhoto();
                                }
                                await _updateProfile();
                              }),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: violet2,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEdit = !_isEdit;
                            });
                          })
                ]
              : null,
          elevation: 0,
        ),
        drawer: buildDrawer(context),
        body: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0, left: _isEdit ? 50 : 0),
                      child: Center(
                        child: Hero(
                          tag: "profile",
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: !User.profilePicExists ? AssetImage('images/userPhoto.jpg') : NetworkImage((User.userPhotoData)),
                          ),
                        ),
                      ),
                    ),
                    _isEdit
                        ? IconButton(
                            icon: Icon(Icons.edit),
                            color: violet2,
                            onPressed: () {
                              getImage();
                            },
                            iconSize: 25,
                          )
                        : Container(),
                  ],
                ),
                buildFieldEntry(
                  label: 'Name',
                  value: User.userName ?? "-",
                ),
                buildFieldEntry(
                  label: 'Email ID',
                  value: User.userEmail ?? "-",
                ),
                User.userRole != 'superAdmin'
                    ? buildFieldEntry(
                        label: 'Institute Name',
                        value: User.instituteName ?? "-",
                      )
                    : Container(),
                User.userRole == 'admin'
                    ? buildFieldEntry(
                        label: 'Institute Type',
                        value: User.userInstituteType ?? "-",
                      )
                    : Container(),
                (_isEdit
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                              child: Text(
                                'State: ',
                                style: TextStyle(fontSize: 20, color: violet2),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Theme(
                              data: Theme.of(context).copyWith(canvasColor: violet1),
                              child: DropdownButtonFormField(
                                hint: Text(
                                  'Select State',
                                  style: TextStyle(color: violet1, fontSize: 18),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white70),
                                  ),
                                ),
                                items: cities[User.state].map((location) {
                                  return DropdownMenuItem(
                                    child: AutoSizeText(
                                      location,
                                      maxLines: 1,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: location,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    User.state = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : (User.userRole != 'superAdmin')
                        ? buildFieldEntry(
                            label: 'State',
                            value: User.state ?? "-",
                          )
                        : Container()),
                (_isEdit
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                              child: Text(
                                User.city,
                                style: TextStyle(fontSize: 20, color: violet2),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Theme(
                              data: Theme.of(context).copyWith(canvasColor: violet1),
                              child: DropdownButtonFormField(
                                hint: Text(
                                  User.state,
                                  style: TextStyle(color: violet1, fontSize: 18),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white70),
                                  ),
                                ),
                                items: cities[User.state].map((location) {
                                  return DropdownMenuItem(
                                    child: AutoSizeText(
                                      location,
                                      maxLines: 1,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: location,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    User.city = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : (User.userRole != 'superAdmin')
                        ? buildFieldEntry(
                            label: 'City',
                            value: User.city ?? "-",
                          )
                        : Container()),
                User.userRole != 'superAdmin'
                    ? buildFieldEntry(
                        label: 'Contact Number',
                        value: User.contactNumber.toString() ?? "-",
                      )
                    : Container(),
                User.userRole != 'superAdmin'
                    ? buildFieldEntry(
                        label: 'Aadhar Number',
                        value: User.aadharNumber.toString() ?? "-",
                      )
                    : Container(),
                User.userRole != 'superAdmin'
                    ? buildFieldEntry(
                        label: 'Institute Mail Address',
                        value: User.mailAddress ?? "-",
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildFieldEntry({String label, String value, Function onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 20, color: violet2),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: TextFormField(
                onSaved: onSaved,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: violet1),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: _isEdit ? BorderSide(width: 2, color: violet2) : BorderSide.none,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: _isEdit ? BorderSide(width: 1, color: violet2) : BorderSide.none,
                  ),
                  hintText: value,
                  hintStyle: TextStyle(color: violet1, fontSize: 18),
                ),
                readOnly: !_isEdit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
