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
    return address;
  }

  place.GoogleMapsPlaces _places = place.GoogleMapsPlaces(apiKey: "AIzaSyAuAeRHabINV88n4SoqODJbq0QZhCOl5dE");

  Completer<GoogleMapController> _controller = Completer();

  static double latitude;
  static double longitude;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(19.07, 72.87),
  );

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
    if (User.userRole == 'driver') {
      String temp = await _getLocationAddress(loc.latitude, loc.longitude);
      print(temp);
      Map _location = {
        "latitude": loc.latitude,
        "longitude": loc.longitude,
        "locationName": temp,
      };
      await _updateDriverLocation(_location);
    }
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
      Fluttertoast.showToast(context, msg: 'Deleted');
      setState(() {
        getAllMarkers();
      });
    } else {
      Fluttertoast.showToast(context, msg: 'Error');
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
      if (json.decode(response.body)['statusCode'] == 200) {
        Fluttertoast.showToast(context, msg: 'Updated');
      } else {
        Fluttertoast.showToast(context, msg: 'Error');
      }
    });
  }

  Future _updateDriverLocation(Map location) async {
    var response = await http.post('$baseUrl/driver/updateLocation',
        body: json.encode(
          {"userID": User.userEmail, "id": User.userID, "jwtToken": User.userJwtToken, "location": location},
        ),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        });
    print(response.body);
  }

  Future _fetchDriverLocation() async {
    var response = await http.post('$baseUrl/driver/getLocation',
        body: json.encode(
          {
            "userID": User.userEmail,
            "routeName": 'Route X',
            "jwtToken": User.userJwtToken,
          },
        ),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        });
    print(response.body);
  }

  Future<void> getAllMarkers() async {
    markers = [];
    if (widget.isEdit) {
      var response = await http.get('$baseUrl/getRoutes');
      List temp = json.decode(response.body)['payload']['routes'];
      temp.forEach((ele) {
        if (ele['routeName'] == widget.routeName) {
          List tempNew = ele['location'];
          tempNew.forEach((loc) {
            setState(() {
              markers.add(
                Marker(
                  markerId: MarkerId(loc['_id']),
                  position: LatLng(
                    loc['latitude'],
                    loc['longitude'],
                  ),
                  infoWindow: InfoWindow(
                      title: loc['locationName'],
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
                      }),
                  flat: true,
                  draggable: false,
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
        print(element['locationName']);
        markers.add(
          Marker(
            markerId: MarkerId(uuid.v1()),
            position: LatLng(element['latitude'], element['longitude']),
            infoWindow: InfoWindow(title: element['locationName']),
            flat: true,
            draggable: false,
          ),
        );
      });
    });
    markers = Set.of(markers).toList();
  }

  Future<Null> displayPrediction(place.Prediction p) async {
    if (p != null) {
      place.PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);

      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      String add = detail.result.formattedAddress;
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(lat, lng),
          zoom: 17.0,
        ),
      ));
      setState(() {
        _locations.add({
          "latitude": lat,
          "longitude": lng,
          "locationName": add,
        });
        getAllMarkers();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _locationName.dispose();
  }

  bool _mapLoading = true;
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
        body: Stack(children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapLoading = false;
              });
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
                            "locationName": address,
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
          _mapLoading
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
        ]),
        floatingActionButton: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: null,
                onPressed: _getLocation,
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                tooltip: 'Get Location',
                child: Icon(
                  Icons.my_location,
                  color: violet1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  place.Prediction p = await PlacesAutocomplete.show(
                    // offset: (10),
                    overlayBorderRadius: BorderRadius.circular(16),
                    mode: Mode.overlay,
                    language: "en",
                    context: context,
                    components: [new place.Component(place.Component.country, "in")],
                    apiKey: "AIzaSyAuAeRHabINV88n4SoqODJbq0QZhCOl5dE",
                  );
                  displayPrediction(p);
                },
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                tooltip: 'Get Location',
                child: Icon(
                  Icons.search,
                  color: violet1,
                ),
              ),
            ),
            (User.userRole == 'customer' || User.userRole == 'employee')
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      heroTag: null,
                      onPressed: () async {
                        await _fetchDriverLocation();
                      },
                      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                      tooltip: 'Get Driver Location',
                      child: Icon(
                        Icons.directions_car,
                        color: violet1,
                      ),
                    ),
                  )
                : Container(
                    height: 0,
                    width: 0,
                  ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
