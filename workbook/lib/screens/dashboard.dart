import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';

import 'dart:math';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/grade_and_divisions/add_grade.dart';
import 'package:workbook/screens/leave_attendance/holiday_calendar/create_holiday.dart';
import 'package:workbook/screens/leave_attendance/holiday_calendar/view_holidays.dart';
import 'package:workbook/screens/posts/add_post.dart';
import 'package:workbook/screens/auth/approve_user.dart';
import 'package:workbook/screens/coming_soon.dart';
import 'package:workbook/screens/schedule/create_schedule.dart';
import 'package:workbook/screens/schedule/view_schedule.dart';
import 'package:workbook/screens/tasks/create_tasks.dart';
import 'package:workbook/screens/profile_page.dart';
import 'package:workbook/screens/queries/query_data.dart';
import 'package:workbook/screens/settings.dart';
import 'package:workbook/screens/schedule/view_schedules_admin.dart';
import 'package:workbook/screens/tasks/view_tasks.dart';
import 'package:workbook/user.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatefulWidget {
  final TargetPlatform platform;

  const DashBoard({Key key, this.platform}) : super(key: key);
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); // ADD THIS LINE

  static final Random random = Random();
  bool _isLoading = false;
  List posts = [];
  String dirloc;

  @override
  void initState() {
    _setData();

    _getAllPosts();
    print(User.instituteName);
    // TODO: implement initState
    super.initState();
  }

  //Make local copies of the response from JSON
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
      User.userJwtToken = prefs.getString('userJwtToken');
      User.profilePicExists = prefs.getBool('profilePicExists');
    });
  }

  // Fetch all posts
  Future _getAllPosts() async {
    var response = await http.get('$baseUrl/post/viewAllPost');
    print(response.statusCode);
    print(response.body);
    setState(() {
      posts = json.decode(response.body)['payload']['post'];
      posts = posts.reversed.toList();
    });
  }

  // Like Post
  Future _likePost({String postId, String userName}) async {
    var response = await http.post("$baseUrl/post/like", body: {"id": postId, "userName": User.userName, "userID": User.userEmail});
    print(json.decode(response.body)['statusCode']);
    print(response.body);
  }

  //Open end drawer
  void onTabTapped() {
    setState(() {
      _scaffoldKey.currentState.openEndDrawer(); // CHANGE THIS LINE
    });
  }

  //UI Block
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet2),
          backgroundColor: Colors.transparent,
        ),
        inAsyncCall: _isLoading,
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: Drawer(
            child: Column(
              children: [
                Flexible(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: !User.profilePicExists ? AssetImage('images/userPhoto.jpg') : NetworkImage((User.userPhotoData)),
                        ),
                        title: Text(
                          User.userName,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          User.userEmail,
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: IconButton(
                            icon: Icon(Icons.navigate_next),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(child: ProfilePage(), type: PageTransitionType.rightToLeft),
                              );
                            }),
                      ),
                      Divider(),
                      User.userRole == 'admin'
                          ? ListTile(
                              leading: Icon(
                                Icons.arrow_downward,
                                color: violet2,
                              ),
                              title: Text(
                                'Grades and Divisions',
                                style: TextStyle(fontSize: 16, color: violet2, fontWeight: FontWeight.w600),
                              ),
                              onTap: () {
                                Navigator.push(context, PageTransition(child: AddGrade(), type: PageTransitionType.rightToLeft));
                              },
                              trailing: Icon(Icons.navigate_next),
                            )
                          : Container(),
                      User.userRole == 'admin'
                          ? ListTile(
                              leading: Icon(
                                Icons.directions_car,
                                color: violet2,
                              ),
                              title: Text(
                                'Drivers',
                                style: TextStyle(fontSize: 16, color: violet2, fontWeight: FontWeight.w600),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      child: ApproveUser(
                                        isDriver: true,
                                      ),
                                      type: PageTransitionType.rightToLeft),
                                );
                              },
                              trailing: Icon(Icons.navigate_next),
                            )
                          : Container(),
                      ListTile(
                        leading: Icon(
                          Icons.meeting_room,
                          color: violet2,
                        ),
                        title: Text(
                          'Tasks/Meetings',
                          style: TextStyle(fontSize: 16, color: violet2, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                                child: User.userRole == 'admin' || User.userRole == 'employee'
                                    ? CreateTask(
                                        isAdmin: User.userRole == 'admin' ? true : false,
                                      )
                                    : ViewTasks(),
                                type: PageTransitionType.rightToLeft),
                          );
                        },
                        trailing: Icon(Icons.navigate_next),
                      ),
                      User.userRole == 'admin'
                          ? ListTile(
                              leading: Icon(
                                Icons.access_time,
                                color: violet2,
                              ),
                              title: Text(
                                'Create Schedules',
                                style: TextStyle(fontSize: 16, color: violet2, fontWeight: FontWeight.w600),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: CreateSchedule(),
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              },
                              trailing: Icon(Icons.navigate_next),
                            )
                          : Container(),
                      ListTile(
                        leading: Icon(
                          Icons.access_time,
                          color: violet2,
                        ),
                        title: Text(
                          'View Schedules',
                          style: TextStyle(fontSize: 16, color: violet2, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: User.userRole != 'admin' ? ViewSchedule() : ViewScheduleAdmin(),
                              type: PageTransitionType.rightToLeft,
                            ),
                          );
                        },
                        trailing: Icon(Icons.navigate_next),
                      ),
                      User.userRole == 'employee' || User.userRole == 'customer' || User.userRole == 'driver'
                          ? ListTile(
                              leading: Icon(
                                Icons.map,
                                color: violet2,
                              ),
                              title: Text(
                                'Travel',
                                style: TextStyle(fontSize: 16, color: violet2, fontWeight: FontWeight.w600),
                              ),
                              onTap: () {
                                Navigator.push(context, PageTransition(child: ComingSoon(), type: PageTransitionType.rightToLeft));
                              },
                              trailing: Icon(Icons.navigate_next),
                            )
                          : Container(),
                      ListTile(
                        leading: Icon(
                          Icons.fingerprint,
                          color: violet2,
                        ),
                        title: Text(
                          'Leave and Attendance',
                          style: TextStyle(fontSize: 16, color: violet2, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.push(context, PageTransition(child: ViewHolidays(), type: PageTransitionType.rightToLeft));
                        },
                        trailing: Icon(Icons.navigate_next),
                      )
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(child: Settings(), type: PageTransitionType.rightToLeft),
                    );
                  },
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ],
            ),
          ),
          backgroundColor: Color(0xFFF5F5F5),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.07,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.012),
                    child: MaterialButton(
                      minWidth: 1,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(child: DashBoard(), type: PageTransitionType.fade),
                        );
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.home,
                            size: 25,
                            color: violet2,
                          ),
                          Text(
                            'Home',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.012),
                    child: MaterialButton(
                      minWidth: 1,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(child: ComingSoon(), type: PageTransitionType.rightToLeft),
                        );
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 25,
                          ),
                          Text(
                            'Mail',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.012),
                    child: MaterialButton(
                      minWidth: 1,
                      onPressed: () {
                        if (User.userRole == 'superAdmin') {
                          Navigator.push(
                            context,
                            PageTransition(child: AddPost(), type: PageTransitionType.fade),
                          );
                        } else if (User.userRole == 'admin') {
                          Navigator.push(
                            context,
                            PageTransition(child: QueryData(), type: PageTransitionType.rightToLeft),
                          );
                        } else {
                          Fluttertoast.showToast(context, msg: 'Only Superadmin can post for now!');
                        }
                      },
                      child: Column(
                        children: [
                          Icon(
                            User.userRole != 'admin' ? Icons.add_circle_outline : Icons.chat_bubble_outline,
                            size: 25,
                          ),
                          Text(
                            User.userRole != 'admin' ? 'Post' : 'Queries',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.012),
                    child: MaterialButton(
                      minWidth: 1,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: User.userRole != 'driver' && User.userRole != 'customer'
                                  ? ApproveUser(
                                      isDriver: false,
                                    )
                                  : ComingSoon(),
                              type: PageTransitionType.rightToLeft),
                        );
                      },
                      child: Column(
                        children: [
                          Icon(
                            User.userRole == 'driver' ? Icons.map : Icons.people_outline,
                            size: 25,
                          ),
                          Text(
                            User.userRole == 'superAdmin' ? 'Admins' : (User.userRole == 'admin') ? 'Emp' : (User.userRole == 'employee') ? 'Cust' : 'Travel',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.012),
                    child: MaterialButton(
                      minWidth: 1,
                      onPressed: () {
                        onTabTapped();
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.menu,
                            size: 25,
                          ),
                          Text(
                            'More',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            title: Text(
              'Feed',
              style: TextStyle(color: violet2, fontSize: 30, fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
            elevation: 0,
            actions: [
              Container(),
            ],
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: violet2),
          ),
          body: RefreshIndicator(
            onRefresh: () {
              return _getAllPosts();
            },
            child: Container(
              child: _isLoading || posts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 64),
                            child: AutoSizeText(
                              User.userRole != "superAdmin" ? 'Welcome to ${User.instituteName},\n${User.userName?.split(" ")[0]}!' : "Welcome,\n${User.userName}",
                              maxLines: 2,
                              style: TextStyle(color: violet2, fontSize: 50),
                            ),
                          ),
                          posts.isEmpty
                              ? Text('No Posts')
                              : TyperAnimatedTextKit(
                                  speed: Duration(milliseconds: 200),
                                  text: ['Loading...'],
                                  textStyle: TextStyle(fontSize: 25, color: violet1),
                                  onFinished: () {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: ((context, index) {
                        var randid = random.nextInt(10000);
                        if (posts[index]['mediaType'] == 'pdf') {}
                        final TextEditingController contro = TextEditingController();
                        List temp = [];
                        posts[index]['likedBy'].forEach((element) {
                          temp.add(element['userID']);
                        });
                        return (posts[index]['enabled'] == true || User.userRole == 'superAdmin')
                            ? VisibilityDetector(
                                onVisibilityChanged: (visibilityInfo) async {
                                  if (visibilityInfo.visibleFraction == 1.0) {
                                    var response = await http.post('$baseUrl/post/updateViews', body: {"id": posts[index]['_id']});
                                    print(response.body);
                                  }
                                },
                                key: Key(index.toString()),
                                child: Stack(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            (posts[index]['mediaUrl'] != "null" && posts[index]['mediaType'] == 'image')
                                                ? GestureDetector(
                                                    onLongPress: () async {
                                                      await launch(posts[index]['mediaUrl']);
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(8),
                                                      child: Image.network(posts[index]['mediaUrl']),
                                                    ),
                                                  )
                                                : (posts[index]['mediaUrl'] != "null" && posts[index]['mediaType'] == 'pdf')
                                                    ? Container(
                                                        padding: EdgeInsets.all(8),
                                                        child: ListTile(
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                child: Image.asset(
                                                                  'images/pdf.png',
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  icon: Icon(Icons.file_download),
                                                                  color: violet2,
                                                                  onPressed: () async {
                                                                    await launch(posts[index]['mediaUrl']);
                                                                  })
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                posts[index]['content'],
                                                style: TextStyle(fontSize: 14),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 16.0, top: 32, right: 16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Likes: '),
                                                      Text(posts[index]['likes'].toString()),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.show_chart,
                                                        color: violet2,
                                                      ),
                                                      Text(
                                                        posts[index]['views'].toString(),
                                                        style: TextStyle(color: violet1),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              height: 0,
                                              color: Colors.grey,
                                            ),
                                            Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              icon: Transform(
                                                                alignment: Alignment.center,
                                                                transform: Matrix4.rotationY(math.pi),
                                                                child: Icon(
                                                                  Icons.thumb_up,
                                                                  color: temp.contains(User.userEmail) ? violet2 : Colors.grey,
                                                                ),
                                                              ),
                                                              onPressed: () async {
                                                                if (temp.contains(User.userEmail)) {
                                                                  Fluttertoast.showToast(context, msg: 'Liked already!');
                                                                } else {
                                                                  await _likePost(postId: posts[index]['_id'], userName: User.userName);
                                                                  await _getAllPosts();
                                                                  setState(() {});
                                                                }
                                                              },
                                                            ),
                                                            Text('Like'),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  MaterialButton(
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.comment,
                                                            color: violet2,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(left: 8.0),
                                                            child: Text('Comment'),
                                                          ),
                                                        ],
                                                      ),
                                                      onPressed: () {}),
                                                  MaterialButton(
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.share,
                                                            color: violet2,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(left: 8.0),
                                                            child: Text('Share'),
                                                          ),
                                                        ],
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          _isLoading = true;
                                                        });
                                                        final String text = posts[index]['content'];
                                                        var req = await HttpClient().getUrl(
                                                          Uri.parse(
                                                            posts[index]['mediaUrl'],
                                                          ),
                                                        );
                                                        var response = await req.close();

                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                        Uint8List bytes = await consolidateHttpClientResponseBytes(response);
                                                        await ImagePickerSaver.saveFile(fileData: bytes).whenComplete(() {
                                                          WcFlutterShare.share(
                                                              sharePopupTitle: 'Share',
                                                              text: text,
                                                              fileName: 'share.png',
                                                              mimeType: 'image/png',
                                                              bytesOfFile: bytes.buffer.asUint8List());
                                                        });
                                                      })
                                                ],
                                              ),
                                            ),
                                            posts[index]['commentEnabled']
                                                ? Container(
                                                    height: posts[index]['comments'].length != 0 ? 200 : 0,
                                                    width: MediaQuery.of(context).size.width * 0.8,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                        Text(posts[index]['comments'].length != 0 ? 'Comments' : ''),
                                                        posts[index]['comments'].length != 0
                                                            ? Container(
                                                                height: 180,
                                                                child: ListView.builder(
                                                                  shrinkWrap: true,
                                                                  itemCount: posts[index]['comments'].length,
                                                                  itemBuilder: (context, i) {
                                                                    return Column(
                                                                      children: [
                                                                        ListTile(
                                                                          title: Text(
                                                                            posts[index]['comments'][i]['userName'],
                                                                            style: TextStyle(color: violet2, fontWeight: FontWeight.bold),
                                                                          ),
                                                                          subtitle: Text(
                                                                            posts[index]['comments'][i]['comment'],
                                                                            style: TextStyle(color: Colors.black),
                                                                          ),
                                                                        ),
                                                                        Divider(),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            posts[index]['commentEnabled']
                                                ? TextFormField(
                                                    style: TextStyle(color: Colors.black),
                                                    maxLines: 1,
                                                    controller: contro,
                                                    cursorRadius: Radius.circular(8),
                                                    cursorColor: Colors.black,
                                                    decoration: InputDecoration(
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                        color: Colors.grey,
                                                      )),
                                                      isDense: true,
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey, width: 2),
                                                      ),
                                                      hintText: 'Add a comment',
                                                      suffixIcon: IconButton(
                                                          icon: Icon(Icons.send),
                                                          color: violet2,
                                                          onPressed: () async {
                                                            print(contro.text);
                                                            if (contro.text.isNotEmpty) {
                                                              var response = await http.post('$baseUrl/post/comment',
                                                                  body: {"id": posts[index]['_id'], "comment": contro.text.toString(), "userName": User.userName});

                                                              print(response.body);
                                                              if (json.decode(response.body)['statusCode'] == 200) {
                                                                Fluttertoast.showToast(context, msg: 'Comment posted');
                                                                setState(() {
                                                                  _getAllPosts();
                                                                });
                                                              }
                                                            } else {
                                                              Fluttertoast.showToast(context, msg: 'Comment can\'t be empty');
                                                            }
                                                          }),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    User.userRole == 'superAdmin'
                                        ? Padding(
                                            padding: EdgeInsets.only(top: 8.0, left: MediaQuery.of(context).size.width * 0.83),
                                            child: PopupMenuButton(
                                              onSelected: (value) async {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                if (value == 1) {
                                                  var response = await http.post(posts[index]['enabled'] == true ? '$baseUrl/post/disablePost' : '$baseUrl/post/enablePost', body: {
                                                    "id": posts[index]['_id'],
                                                  });
                                                  print(response.body);
                                                  setState(() {
                                                    _getAllPosts();
                                                    _isLoading = false;
                                                  });
                                                } else if (value == 2) {
                                                  var response = await http
                                                      .post(posts[index]['commentEnabled'] == true ? '$baseUrl/post/disableComment' : '$baseUrl/post/enableComment', body: {
                                                    "id": posts[index]['_id'],
                                                  });
                                                  print(response.body);
                                                  setState(() {
                                                    _getAllPosts();
                                                    _isLoading = false;
                                                  });
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Text(posts[index]['enabled'] == true ? 'Disable Post' : 'Enable Post'),
                                                ),
                                                PopupMenuItem(
                                                  value: 2,
                                                  child: Text(posts[index]['commentEnabled'] == true ? 'Disable Comments' : 'Enable Comments'),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    posts[index]['enabled']
                                        ? Container()
                                        : Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 2,
                                                ),
                                              ],
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'DISABLED',
                                              style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                                            ),
                                            padding: EdgeInsets.all(8),
                                          ),
                                  ],
                                ),
                              )
                            : Container();
                      }),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
