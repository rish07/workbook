import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/user.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String fileType = '';
  File file;
  String fileName = '';
  List notificationList = [];
  String mediaUrl = '';

  // Get all the roles available
  Future getRoles() async {
    var response = await http.get('$baseUrl/getRoles');
    print(response.body);
    List temp = json.decode(response.body)['payload']['roles'];
    temp.forEach((element) {
      if (element['approved'] == true) {
        notificationList.add(element['fcmToken']);
      }
    });
    print(notificationList);
  }

  // Send Notification
  Future sendNotification() async {
    notificationList.forEach((element) async {
      var response = await http.post('$baseUrl/sendNotification', body: {
        "title": "New Post!",
        "message": "Click here to check out the latest post.",
        "fcmToken": element.toString(),
      });
      print(response.body);
    });
  }

  // Create a new post
  Future createPost() async {
    if (_controller.text.isEmpty && mediaUrl.isEmpty) {
      Fluttertoast.showToast(context, msg: 'The post can not be empty!');
      setState(() {
        _loading = false;
      });
    } else {
      var response = await http.post(
        '$baseUrl/post/createPost',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(
          {"createdBy": User.userRole, "mediaUrl": mediaUrl.isEmpty ? 'null' : mediaUrl, "content": _controller.text, "mediaType": fileType},
        ),
      );

      print(response.statusCode);
      print(response.body);

      if (json.decode(response.body)['statusCode'] == 200) {
        Fluttertoast.showToast(context, msg: 'Post uploaded successfully');
        sendNotification();
        Navigator.push(
          context,
          PageTransition(child: DashBoard(), type: PageTransitionType.rightToLeft),
        );
      } else {
        Fluttertoast.showToast(context, msg: 'Error');
      }
      setState(() {
        _loading = false;
      });
    }
  }

  // Choosing the file from phone storage
  Future filePicker(BuildContext context) async {
    try {
      if (fileType == 'image') {
        file = await FilePicker.getFile(type: FileType.image);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        _uploadFile(file, fileName);
      }

      if (fileType == 'pdf') {
        file = await FilePicker.getFile(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);
        fileName = p.basename(file.path);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        _uploadFile(file, fileName);
      }
    } catch (e) {
      print(e);
    }
  }

  // Upload the image/doc to firebase storage
  Future<void> _uploadFile(File file, String filename) async {
    setState(() {
      _loading = true;
    });
    StorageReference storageReference;
    if (fileType == 'image') {
      storageReference = FirebaseStorage.instance.ref().child("images/something");
    }

    if (fileType == 'pdf') {
      storageReference = FirebaseStorage.instance.ref().child("pdf/$filename");
    }
    if (fileType == 'others') {
      storageReference = FirebaseStorage.instance.ref().child("others/$filename");
    }
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    setState(() {
      mediaUrl = url;
      _loading = false;
      Fluttertoast.showToast(context, msg: 'File attached successfully');
    });
    print("URL is $url");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRoles();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  //UI Block
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Share post',
            style: TextStyle(color: violet2, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.clear,
                color: violet2,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: MaterialButton(
                  minWidth: 80,
                  color: violet2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    'Share',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    await createPost();
                  }),
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              ListTile(
                subtitle: Text(""),
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('images/userPhoto.jpg'),
                ),
                title: Text(
                  'Super Admin',
                  style: TextStyle(color: violet2, fontSize: 18),
                ),
              ),
              TextFormField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: Colors.black, fontSize: 18),
                cursorColor: violet2,
                cursorRadius: Radius.circular(8),
                maxLines: 25,
                decoration: InputDecoration(
                  hintText: 'What is on your mind?',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.collections,
                    color: violet2,
                  ),
                  onPressed: () {
                    setState(() {
                      fileType = 'image';
                    });
                    filePicker(context);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.description,
                    color: violet2,
                  ),
                  onPressed: () {
                    setState(() {
                      fileType = 'pdf';
                    });
                    filePicker(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
