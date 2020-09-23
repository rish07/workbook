import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as p;
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/responsive_widget.dart';
import 'package:workbook/widget/popUpDialog.dart';
import '../../constants.dart';
import 'package:universal_io/io.dart' as uni;
import '../../user.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:firebase/firebase.dart' as fb;

class CreateSchedule extends StatefulWidget {
  @override
  _CreateScheduleState createState() => _CreateScheduleState();
}

class _CreateScheduleState extends State<CreateSchedule> {
  bool _validateGrade = false;
  bool _validateDivision = false;
  bool _isLoading = false;
  String _selectedGrade;
  String _selectedDivision;
  List gradeDivision = [];
  final picker = ImagePicker();
  String mediaUrl = '';
  bool uploaded = false;

  File _file;
  String fileName = '';
  final math.Random random = math.Random();

  Future getGrades() async {
    var response = await http.get("$baseUrl/fetchGrade/${User.instituteName}");
    print('Response status: ${response.statusCode}');
    List temp = json.decode(response.body)['payload']['grades'];
    temp.forEach((resp) {
      grades.add(resp);
    });
    grades = Set.of(grades).toList();
    setState(() {
      _isLoading = false;
    });
  }

  Future getImage() async {
    try {
      _file = await FilePicker.getFile(type: FileType.image);
      setState(() {
        fileName = p.basename(_file.path);
      });
      print(fileName);
      await _uploadFile();
    } catch (e) {
      print(e);
    }
  }

  Future _updateSchedule(url) async {
    print('update schedule');
    print(User.userID);
    var body = {
      "userID": User.userEmail,
      "jwtToken": User.userJwtToken,
      "schedule": mediaUrl,
      "grade": _selectedGrade,
      "division": _selectedDivision,
      "instituteName": User.instituteName,
    };
    var request = await http.post(url, body: body);
    print(body);
    print(request.body);
    setState(() {
      _isLoading = false;
    });
    if (json.decode(request.body)['statusCode'] == 200) {
      popDialog(
          title: 'Upload Successful',
          buttonTitle: 'Okay',
          context: context,
          content: 'The schedule was updated successfully',
          onPress: () {
            Navigator.pop(context);
          });
    } else {
      print('Error');
    }
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isLoading = true;
    });
    StorageReference storageReference;
    int rand = random.nextInt(1000);
    storageReference = FirebaseStorage.instance.ref().child("schedules/$rand");

    final StorageUploadTask uploadTask = storageReference.putFile(_file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    setState(() {
      mediaUrl = url;
      _isLoading = false;
      Fluttertoast.showToast(context, msg: 'File attached successfully');
    });
    print("URL is $url");
  }

  uploadImage() async {
    // HTML input element
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen(
      (changeEvent) {
        final file = uploadInput.files.first;
        final reader = html.FileReader();

        reader.readAsDataUrl(file);

        reader.onLoadEnd.listen(
          (loadEndEvent) async {
            uploadImageFile(file, imageName: (_selectedGrade + _selectedDivision).toString());
          },
        );
      },
    );
  }

  Future<Uri> uploadImageFile(html.File image, {String imageName}) async {
    setState(() {
      _isLoading = true;
    });
    fb.StorageReference storageRef = fb.app().storage().ref('images/$imageName');
    fb.UploadTaskSnapshot uploadTaskSnapshot = await storageRef.put(image).future;

    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    print(imageUri);
    setState(() {
      mediaUrl = imageUri.toString();
      _isLoading = false;
      Fluttertoast.showToast(context, msg: 'Uploaded successfully');
    });
    return imageUri;
  }

  Future getDivision() async {
    var response = await http.get("$baseUrl/fetchDivision/${User.instituteName}");
    print('Response status: ${response.statusCode}');
    setState(() {
      divisionData = json.decode(response.body)['payload']['divisions'];
    });
  }

  Future _div() async {
    await getDivision();
    gradeDivision.clear();
    print(divisionData);
    divisionData.forEach((element) {
      if (element['grade'] == _selectedGrade) {
        gradeDivision.add(element['division']);
      }
    });
    gradeDivision = Set.of(gradeDivision).toList();
    print(gradeDivision);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGrades();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: violet1,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(child: DashBoard(), type: PageTransitionType.rightToLeft),
                );
              }),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Set Schedule',
            style: TextStyle(color: violet1),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(
                          left: uni.Platform.isAndroid
                              ? MediaQuery.of(context).size.width * 0.04
                              : ResponsiveWidget.isMediumScreen(context)
                                  ? MediaQuery.of(context).size.width * 0.15
                                  : ResponsiveWidget.isLargeScreen(context)
                                      ? MediaQuery.of(context).size.width * 0.32
                                      : 0),
                      child: Text(
                        'Grade: ',
                        style: TextStyle(fontSize: 20, color: violet2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: !uni.Platform.isAndroid
                        ? ResponsiveWidget.isMediumScreen(context)
                            ? 2
                            : 1
                        : 2,
                    child: Container(
                      padding: uni.Platform.isAndroid
                          ? EdgeInsets.zero
                          : EdgeInsets.only(
                              left: 0,
                              right: ResponsiveWidget.isMediumScreen(context)
                                  ? size.width * 0.15
                                  : ResponsiveWidget.isLargeScreen(context)
                                      ? size.width * 0.32
                                      : 0),
                      child: DropdownButtonFormField(
                        hint: Text(
                          'Select Grade',
                          style: TextStyle(color: violet1, fontSize: 18),
                        ),
                        decoration: InputDecoration(
                          errorText: _validateGrade ? 'Please choose an option' : null,
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: violet1),
                          ),
                        ),
                        items: grades.map((location) {
                          return DropdownMenuItem(
                            child: AutoSizeText(
                              location,
                              maxLines: 1,
                              style: TextStyle(color: violet1),
                            ),
                            value: location,
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedGrade = value;
                          });
                          await _div();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(
                          left: uni.Platform.isAndroid
                              ? MediaQuery.of(context).size.width * 0.04
                              : ResponsiveWidget.isMediumScreen(context)
                                  ? MediaQuery.of(context).size.width * 0.15
                                  : ResponsiveWidget.isLargeScreen(context)
                                      ? MediaQuery.of(context).size.width * 0.32
                                      : 0),
                      child: Text(
                        'Division: ',
                        style: TextStyle(fontSize: 20, color: violet2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: !uni.Platform.isAndroid
                        ? ResponsiveWidget.isMediumScreen(context)
                            ? 2
                            : 1
                        : 2,
                    child: Container(
                      padding: uni.Platform.isAndroid
                          ? EdgeInsets.zero
                          : EdgeInsets.only(
                              left: 0,
                              right: ResponsiveWidget.isMediumScreen(context)
                                  ? size.width * 0.15
                                  : ResponsiveWidget.isLargeScreen(context)
                                      ? size.width * 0.32
                                      : 0),
                      child: DropdownButtonFormField(
                        hint: Text(
                          'Select Division',
                          style: TextStyle(color: violet1, fontSize: 18),
                        ),
                        decoration: InputDecoration(
                          errorText: _validateDivision ? 'Please choose an option' : null,
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: violet1),
                          ),
                        ),
                        items: gradeDivision.map((location) {
                          return DropdownMenuItem(
                            child: AutoSizeText(
                              location,
                              maxLines: 1,
                              style: TextStyle(color: violet1),
                            ),
                            value: location,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDivision = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                padding: uni.Platform.isAndroid
                    ? EdgeInsets.all(16)
                    : EdgeInsets.only(
                        right: ResponsiveWidget.isMediumScreen(context)
                            ? MediaQuery.of(context).size.width * 0.14
                            : ResponsiveWidget.isLargeScreen(context)
                                ? MediaQuery.of(context).size.width * 0.32
                                : 0,
                        left: ResponsiveWidget.isMediumScreen(context)
                            ? MediaQuery.of(context).size.width * 0.15
                            : ResponsiveWidget.isLargeScreen(context)
                                ? MediaQuery.of(context).size.width * 0.32
                                : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload Schedule:',
                      style: TextStyle(fontSize: 20, color: violet2),
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      onPressed: () async {
                        if (uni.Platform.isAndroid) {
                          await getImage();
                        } else {
                          await uploadImage();
                        }
                      },
                      color: violet1,
                      child: Text(
                        uploaded ? 'Uploaded!' : 'Select File',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
              ),
              Padding(
                padding: uni.Platform.isAndroid
                    ? EdgeInsets.symmetric(horizontal: 100.0)
                    : EdgeInsets.symmetric(
                        horizontal: ResponsiveWidget.isMediumScreen(context)
                            ? size.width * 0.35
                            : ResponsiveWidget.isLargeScreen(context)
                                ? size.width * 0.4
                                : 100),
                child: MaterialButton(
                  padding: EdgeInsets.all(16),
                  color: violet2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  onPressed: () async {
                    setState(() {
                      _selectedGrade == null ? _validateGrade = true : _validateGrade = false;
                      _selectedDivision == null ? _validateDivision = true : _validateDivision = false;
                    });
                    if (!_validateGrade && !_validateDivision) {
                      await _updateSchedule('$baseUrl/admin/createSchedule');
                    }
                  },
                  child: Text(
                    User.userRole == 'admin' ? 'Send to all' : 'Send to Customer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
