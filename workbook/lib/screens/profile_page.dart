import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
    request.fields['userID'] = User.userID;
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

  Future _update() async {
    print('update working');
    var res = await _updateImage(
        imagePath, 'https://app-workbook.herokuapp.com/uploadPicture');
    setState(() {
      state = res;
      _isLoading = false;
      print(res);
    });
  }

  String state = "";
  bool _isEdit = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: teal2,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            _isEdit
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: MaterialButton(
                        minWidth: 80,
                        color: teal2,
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
                          await _update();
                        }),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: teal2,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEdit = !_isEdit;
                      });
                    })
          ],
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
                      padding: const EdgeInsets.only(bottom: 20.0, left: 50),
                      child: Center(
                        child: Hero(
                          tag: "profile",
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: User.userPhotoData == null
                                ? AssetImage('images/userPhoto.jpg')
                                : Image.memory(
                                    base64Decode(User.userPhotoData)),
                          ),
                        ),
                      ),
                    ),
                    _isEdit
                        ? IconButton(
                            icon: Icon(Icons.edit),
                            color: teal2,
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
                buildFieldEntry(
                  label: 'Institute Name',
                  value: User.instituteName ?? "-",
                ),
                User.userRole == 'admin'
                    ? buildFieldEntry(
                        label: 'Institute Type',
                        value: User.userInstituteType ?? "-",
                      )
                    : Container(),
                buildFieldEntry(
                  label: 'State',
                  value: User.state ?? "-",
                ),
                buildFieldEntry(
                  label: 'City',
                  value: User.city ?? "-",
                ),
                buildFieldEntry(
                  label: 'Contact Number',
                  value: User.contactNumber.toString() ?? "-",
                ),
                buildFieldEntry(
                  label: 'Aadhar Number',
                  value: User.aadharNumber.toString() ?? "-",
                ),
                buildFieldEntry(
                  label: 'Mail Address',
                  value: User.mailAddress ?? "-",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildFieldEntry({String label, String value}) {
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
                style: TextStyle(fontSize: 20, color: teal2),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                style: TextStyle(color: teal1),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: _isEdit
                        ? BorderSide(width: 2, color: teal2)
                        : BorderSide.none,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: _isEdit
                        ? BorderSide(width: 1, color: teal2)
                        : BorderSide.none,
                  ),
                  hintText: value,
                  hintStyle: TextStyle(color: teal1, fontSize: 18),
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
