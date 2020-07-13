import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart' as place;
import 'package:page_transition/page_transition.dart';
import 'dart:async';
import 'package:workbook/screens/request_profile_page.dart';
import 'package:workbook/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:uuid/uuid.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/popUpDialog.dart';

class GoogleMapScreen extends StatefulWidget {
  final bool isEdit;
  final String routeName;
  final String routeID;
  final String driverID;
  Location location = new Location();

  GoogleMapScreen({Key key, this.routeName, this.driverID, this.isEdit, this.routeID}) : super(key: key);
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final TextEditingController _locationName = TextEditingController();
  void initState() {
    super.initState();
    _getLocation();
    getAllMarkers();
  }

  List _locations = [];
  String address = "";

  final Geolocator _geoLocator = Geolocator();

  Future _getLocationAddress(double latitude, double longitude) async {
    List<Placemark> newPlace = await _geoLocator.placemarkFromCoordinates(latitude, longitude);
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    // String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    // String subAdministrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    // String subThoroughfare = placeMark.subThoroughfare;
    String thoroughfare = placeMark.thoroughfare;
    setState(() {
      address = "$name, $thoroughfare, $locality, $administrativeArea, $postalCode, $country";
    });
  }

  place.GoogleMapsPlaces _places = place.GoogleMapsPlaces(apiKey: "AIzaSyAuAeRHabINV88n4SoqODJbq0QZhCOl5dE");

  Completer<GoogleMapController> _controller = Completer();

  static double latitude;
  static double longitude;

  CameraPosition _kGooglePlex = CameraPosition(target: LatLng(19.07, 72.87));

  List<Marker> markers = <Marker>[];

  List<Circle> circles = <Circle>[];

  void _getLocation() async {
    LocationData loc = await widget.location.getLocation();
    //getAllMarkers();
    print(loc);
    latitude = loc.latitude;
    longitude = loc.longitude;

    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 13,
      );
      final circle = Circle(
        circleId: CircleId("curr_loc"),
        center: LatLng(loc.latitude, loc.longitude),
        fillColor: Colors.blueAccent,
        strokeColor: Colors.blueAccent,
        radius: 5,
        zIndex: 100,
      );
      final circleBackground = Circle(
        circleId: CircleId("curr_loc_bg"),
        center: LatLng(loc.latitude, loc.longitude),
        strokeColor: Color.fromRGBO(230, 230, 230, 1),
        radius: 18,
        zIndex: 10,
      );
      circles.add(circle);
      circles.add(circleBackground);
    });
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(loc.latitude, loc.longitude),
        zoom: 17.0,
      ),
    ));
  }

  Future _createRoute() async {
    print('creating route');
    var body = json.encode({
      "driverID": widget.driverID,
      "location": _locations,
      "routeName": widget.routeName,
      "userID": User.userEmail,
      "jwtToken": User.userJwtToken,
    });
    print(body);
    var response = await http.post(
      '$baseUrl/admin/createRoute',
      body: body,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    print('--------------------------------------------------------');
    print(response.body);
  }

  Future _deleteLocation({String locationID}) async {
    print('delete');
    var body = json.encode(
      {
        "routeID": widget.routeID,
        "locationID": locationID,
        "userID": User.userEmail,
        "jwtToken": User.userJwtToken,
      },
    );
    print(body);
    var response = await http.post(
      '$baseUrl/admin/deleteLocation',
      body: body,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      FlutterToast.showToast(msg: 'Deleted');
    } else {
      FlutterToast.showToast(msg: 'Error');
    }
    Navigator.pop(context);
  }

  Future _updateLocation() async {
    print('updating route');
    _locations.forEach((element) async {
      var body = json.encode(
        {
          "id": widget.routeID,
          "location": element,
          "routeName": widget.routeName,
          "userID": User.userEmail,
          "jwtToken": User.userJwtToken,
        },
      );
      print(body);
      print('--------------------------------------------------------');
      var response = await http.post(
        '$baseUrl/admin/updateRoute',
        body: body,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
      print(response.body);
    });
    FlutterToast.showToast(msg: 'Updated');
  }

  Future<void> getAllMarkers() async {
    if (widget.isEdit) {
      var response = await http.get('$baseUrl/getRoutes');
      List temp = json.decode(response.body)['payload']['routes'];
      temp.forEach((ele) {
        if (ele['routeName'] == widget.routeName) {
          List tempNew = ele['location'];
          tempNew.forEach((loc) {
            print(loc['name']);
            print('hereeeeeeeeeeeeeeeeee');
            setState(() {
              markers.add(
                Marker(
                  markerId: MarkerId(loc['_id']),
                  position: LatLng(
                    loc['latitude'],
                    loc['longitude'],
                  ),
                  infoWindow: InfoWindow(
                    title: loc['name'],
                    snippet: 'dcisb',
                  ),
                  flat: false,
                  draggable: false,
                  consumeTapEvents: true,
                  onTap: () {
                    popDialog(
                      title: 'Delete Route?',
                      content: 'Do you want to delete this location from the route?',
                      context: context,
                      onPress: () {
                        _deleteLocation(locationID: loc['_id']);
                      },
                      buttonTitle: 'Delete',
                    );
                  },
                ),
              );
            });
          });
        }
      });
    }

    print("Getting marker data");
    var uuid = Uuid();
    setState(() {
      _locations.forEach((element) {
        markers.add(
          Marker(
            markerId: MarkerId(uuid.v1()),
            position: LatLng(element['latitude'], element['longitude']),
            infoWindow: InfoWindow(title: element['name']),
            flat: false,
            draggable: false,
            consumeTapEvents: true,
            onTap: () {
              popDialog(
                title: 'Delete Route?',
                content: 'Do you want to delete this location from the route?',
                context: context,
                buttonTitle: 'Delete',
                onPress: () {},
              );
            },
          ),
        );
      });
    });
  }

  Future<Null> displayPrediction(place.Prediction p) async {
    if (p != null) {
      place.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      print(lat);
      print(lng);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _locationName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                color: violet1,
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: <Widget>[
              Container(
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
                      print('working');
                      if (widget.isEdit) {
                        await _updateLocation();
                      } else {
                        await _createRoute();
                      }
                    }),
              )
            ],
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              'Set Route',
              style: TextStyle(color: violet2),
            )),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              circles: Set<Circle>.of(circles),
              markers: Set<Marker>.of(markers),
              myLocationButtonEnabled: true,
              onTap: (LatLng location) async {
                await _getLocationAddress(location.latitude, location.longitude);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Add location?"),
                      content: Text("Are you sure you want to add the tapped location $address to ${widget.routeName}"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(
                            "Add",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            _locations.add({
                              "latitude": location.latitude,
                              "longitude": location.longitude,
                              "name": address,
                            });
                            print('here11111111111111111111111111111111111111111111111111');
                            print(_locations);
                            getAllMarkers();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.02,
              right: 15.0,
              left: 15.0,
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey, offset: Offset(1.0, 5.0), blurRadius: 10, spreadRadius: 3),
                  ],
                ),
                child: TextFormField(
                  controller: _locationName,
                  onTap: () async {
                    place.Prediction p = await PlacesAutocomplete.show(
                      mode: Mode.overlay,
                      language: "en",
                      context: context,
                      components: [new place.Component(place.Component.country, "in")],
                      apiKey: "AIzaSyAuAeRHabINV88n4SoqODJbq0QZhCOl5dE",
                    );
                    displayPrediction(p);
                  },
                  textCapitalization: TextCapitalization.words,
                  cursorColor: Colors.black,
                  style: TextStyle(color: violet1, fontSize: 16),
                  decoration: InputDecoration(
                    icon: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5, left: 16),
                      child: Icon(
                        Icons.not_listed_location,
                        color: Colors.black,
                      ),
                    ),
                    hintText: "Destination?",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _getLocation,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          tooltip: 'Get Location',
          label: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.gps_fixed, color: violet1),
              ),
              Text(
                'Get my Location',
                style: TextStyle(color: violet1),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
