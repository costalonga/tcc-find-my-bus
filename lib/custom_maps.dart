import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:find_my_bus/dummy_data.dart';
import 'package:http/http.dart' as http;

import 'dart:typed_data';
import 'dart:ui' as ui;

// import 'package:quiver/iterables.dart';


class ResponseObject {
  final LatLng position;
  final String distance;
  final String duration;

  const ResponseObject({
    @required this.position,
    @required this.distance,
    @required this.duration,
  });
}


class MyCustomMap extends StatefulWidget {
  @override
  _SimpleMapState createState() => _SimpleMapState();
}

class _SimpleMapState extends State<MyCustomMap> {

  Completer<GoogleMapController> _controller = Completer();

  // TODO: TESTING HERE
  String _mapStyle;
  GoogleMapController _googleMapController;

  // [TODO-CUSTOM PIN]
  BitmapDescriptor pinLocationIcon;


  // [TODO-2]: TESTING HERE
  Set<Marker> _markers = {};   // [TODO-PERFORMANCE]: CHECK IF SHOULD USE LIST (order) instead of SET (unorder)
  Marker _userMrk;
  Marker _closestBus; // [TODO-DOUBT]: Just one or at least the closest 2 ???
  Marker _closestStopMrk;
  Set<Polyline> _polylines = {};   // [TODO-PERFORMANCE]: CHECK IF SHOULD USE LIST (order) instead of SET (unorder)
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final String apiKey = dotenv.env['GOOGLE_MAPS_KEY']; 
  int markIdCounter = 0;
  int polyIdCounter = 0;

  // Variables of estimated metrics:
  String _estimatedDistance = "";
  String _estimatedTime = "";
  dynamic _responseDM; // todo temp


  //   LatLng(-22.9793,-43.2292),
  //   LatLng(-22.9789,-43.2284),


  // List<LatLng> busStops = [
  //   LatLng(-22.9793,-43.2306),
  //   // LatLng(-22.9794,-43.2304),
  //   // LatLng(-22.9794,-43.2303),
  //   LatLng(-22.9795,-43.2302),
  //   // LatLng(-22.9795,-43.2299),
  //   LatLng(-22.9793,-43.2292),
  //   LatLng(-22.9789,-43.2284),
  //   // LatLng(-22.9786,-43.227),
  //   // LatLng(-22.9785,-43.2266),
  //   // LatLng(-22.9784,-43.2263),
  //   // LatLng(-22.9143,-43.1993),
  //   // LatLng(-22.9162,-43.1963),
  //   // LatLng(-22.9168,-43.1962),
  //   // LatLng(-22.917,-43.1959),
  //   // LatLng(-22.9175,-43.1949),
  //   // LatLng(-22.9178,-43.1949),
  //   // LatLng(-22.9178,-43.1949),
  //   // LatLng(-22.918,-43.195),
  //   // LatLng(-22.9184,-43.1952),
  //   // LatLng(-22.9186,-43.1954),
  //   // LatLng(-22.9193,-43.1958),
  //   // LatLng(-22.9199,-43.1963),
  //   LatLng(-22.963,-43.2164),

  //   LatLng(-22.9212,-43.1734),
  //   LatLng(-22.9205,-43.1967),
  //   LatLng(-22.9226,-43.1975),
  //   // LatLng(-22.9207,-43.2227),
  //   LatLng(-22.9787,-43.2296)
  // ];



  // 350m + 170m   = 520m                                                   [TODO-NEW]: HERE!!!!!!!!
  // [TODO-NEW]: Testing User / Closest Bus Location
  LatLng closestBusStop = LatLng(-22.960762, -43.208245);   // CLOSEST STOP HERE
  LatLng closestBusInTraffic = LatLng(-22.960936, -43.209888);   
  // LatLng userLocation = LatLng(-22.962734, -43.207733);
  LatLng userLocation;
  bool screenLoading;
  //  [TODO-NEW]: Testing User / Closest Bus Location

  
  List<LatLng> busStops = [
    // LatLng(-22.9789,-43.2284),

    // [TODO-CRUCIAL]: REVERSE ORDER ???
    LatLng(-22.9793,-43.2306),  
    LatLng(-22.963,-43.2164),   
    // LatLng(-22.960762, -43.208245),                      // CLOSEST STOP HERE
    LatLng(-22.9199,-43.1963),  
    // LatLng(-22.9212,-43.1734),
    // LatLng(-22.9787,-43.2296)
  ];
  // [TODO-2]: TESTING HERE


  // [TODO-4]: Tests with HardCoded Data
  List<LatLng> _dummy410Points;

  @override
  void initState() {
    // [TODO-IMPROVEMENT]: TESTE INITAL METHODS HERE INSTEAD OF "on mount" (e.g. SetPins, SetMarkers, ...)
    //                     CHECK FOR PERFOMANCE CHANGES
      super.initState();
      rootBundle.loadString('assets/map_style.txt').then((value){
        _mapStyle = value;
      });

      // _dummy410Points = Fake410Points().busStops1;

      // Set loading icon until get user current Location 
      setUserCurrentLocation();
      screenLoading = true;

      // [TODO-CUSTOM PIN]
      setCustomMapPin();

  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }


  // [TODO-CUSTOM PIN]
  // Customize Marker Icon
  void setCustomMapPin() async {
    // pinLocationIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5),
    //     'assets/bus_marker.png');

    final Uint8List markerIcon = await getBytesFromAsset('assets/bus-pin.png', 100);
    pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
    // pinBusIcon = BitmapDescriptor.fromBytes(markerIcon);
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  // Get User's current position
  void setUserCurrentLocation() async {
      Geolocator geolocator = new Geolocator();  
      Position _currentUserPosition = await 
      geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, 
        locationPermissionLevel: GeolocationPermission.location
      );
      setState(() {
        userLocation = LatLng(_currentUserPosition.latitude, _currentUserPosition.longitude);
        screenLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    LatLng myHouse = LatLng(-22.96298, -43.208807);
    // LatLng myHouse = LatLng(-22.9789,-43.2284);
    // LatLng myHouse = LatLng(-22.9199,-43.1963);
    LatLng pucLocation = LatLng(-22.990706, -43.25011);
    LatLng pinPosition = LatLng(-22.915459, -43.2330669);

    // [TODO-TESTE CURRENT LOCATION]
    // CameraPosition _kInitialPosition = CameraPosition(target: myHouse, zoom: 14.0, tilt: 0, bearing: 0);

    double _searchPanelTopDistance = 35.0;
    String dropdownValue = '410';

          
    return 
      Stack( 
        children: screenLoading == true ?  
        <Widget>[
          SafeArea(
            child: Center(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(0.0),
                  width: 60.0,
                  height: 60.0,
                  child: RefreshProgressIndicator()
                )
              )
            )
          )

        ] : 
        <Widget>[
          // screenLoading == true ? 
          // Container(
          //   width: 65.0,
          //   height: 65.0,
          //   child: RefreshProgressIndicator()
          // ) :
          Container(
            width: double.infinity,
            height: double.infinity,
            child: GoogleMap(
              // Basic Map Settings
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              initialCameraPosition: CameraPosition(target: userLocation, zoom: 14.0, tilt: 0, bearing: 0), // Initial Position
              
              onMapCreated: (GoogleMapController controller) {
                if(mounted) {
                  _googleMapController = controller;
                  controller.setMapStyle(_mapStyle);
                }
                // [TODO-POLY-MARKER]: TESTING HERE
                // setMapPins();
                // // drawUserRoute();   // TODO: Change here to draw polylines
                // setPolylines();

              },
              
              markers: _markers,
              polylines: _polylines,  
              // [TODO-2]: TESTING HERE
            )
          ),
          Positioned(
            top: _searchPanelTopDistance,
            right: 95,
            left: 15,
            child:
            // TextField(
            //   // controller: currLocationController,  // Listener of text input
            //   decoration: InputDecoration(
            //     // border: OutlineInputBorder(),
            //     border: UnderlineInputBorder(),
            //     // labelText: 'Enter a your current location: (lat, lon)',
            //     labelText: 'Selecione uma linha de ônibus',
            //     hintText: '410, 315, 461, ...',
            //     // hintText: '-22.915459, -43.208501',
            //   ),
            // ),
            Container(
              color: Colors.white10,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.black,
                      // keyboardType: TextInputType.text,
                      // textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                         borderSide: BorderSide(color: Colors.grey, width: 2.0),
                        ),
                        labelText: 'Selecione uma linha de ônibus:',
                        hintText: '410, 315, 461, ...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          ),
          Positioned(
            top: _searchPanelTopDistance + 65,
            // right: 15,
            left: 25,
            child: Text(
              'Distância: ${_estimatedDistance} | Tempo Estimado: ${_estimatedTime}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              // controller: currLocationController,  // Listener of text input
            ),
          ),

          Positioned(
            bottom: 30,
            left: 7,
            child: FloatingActionButton(
                // backgroundColor: Colors.grey,
                // foregroundColor: Colors.black,
                // child: Icon(Icons.search),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.black,
                child: Icon(Icons.bus_alert),
                onPressed: () => _findMyBus(),
            )
          ),

          // // Test Button 2
          // Positioned(
          //   bottom: 30,
          //   left: 75,
          //   child: FloatingActionButton(
          //       backgroundColor: Colors.amber,
          //       foregroundColor: Colors.black,
          //       // onPressed: () => _changeUserLocation(),  // Move user around
          //       onPressed: () => _detectNearstBusStop(),    // Test Matrix API
          //       child: Icon(Icons.gps_fixed),
          //   )
          // ),


          // // Test Button 3
          // Positioned(
          //   // top: _searchPanelTopDistance - 2,
          //   // left: 265,
          //   // child: 
          //   // DropdownButton<String>(
          //   //   value: dropdownValue,
          //   //   icon: const Icon(Icons.arrow_downward),
          //   //   iconSize: 24,
          //   //   elevation: 16,
          //   //   style: const TextStyle(
          //   //     color: Colors.black
          //   //   ),
          //   //   underline: Container(
          //   //     height: 2,
          //   //     color: Colors.black,
          //   //   ),
          //   //   onChanged: (String newValue) {
          //   //     setState(() {
          //   //       dropdownValue = newValue;
          //   //     });
          //   //     print(dropdownValue);
          //   //   },
          //   //   items: <String>['410', '409', '315', '461']
          //   //     .map<DropdownMenuItem<String>>((String value) {
          //   //       return DropdownMenuItem<String>(
          //   //         value: value,
          //   //         child: Text(value),
          //   //       );
          //   //     })
          //   //     .toList(),
          //   // )
          //   bottom: 30,
          //   left: 145,
          //   child: 
          //   FloatingActionButton(
          //       backgroundColor: Colors.grey,
          //       foregroundColor: Colors.black,
          //       child: Icon(Icons.search),
          //       // backgroundColor: Colors.pink,
          //       // foregroundColor: Colors.black,
          //       // child: Icon(Icons.bus_alert),
          //       onPressed: () {
          //         print('Response DM = ');
          //         // for each...
          //         print(_responseDM['rows'][0]);
          //         print(_responseDM.runtimeType);
          //       },    // Parsing Matrix API
          //   )
          // ),

          // // Test Button 4
          // Positioned(
          //   bottom: 30,
          //   left: 215,
          //   child: FloatingActionButton(
          //       backgroundColor: Colors.lime,
          //       foregroundColor: Colors.black,
          //       onPressed: () {
          //         print("\nTesting Data Structure");
          //         List<LatLng> _lst = [LatLng(-22.9628, -43.2078), LatLng(-22.957552481391353, -43.20702816440822), LatLng(-21.957552481391353, -41.20702816440822)];
          //         List<Map<String, dynamic>> _response = [
          //           {"id": 1, "distance": {'text': '0.3 km', 'value': 343}, "duration": {'text': '4 mins', 'value': 269}},
          //           {"id": 2, "distance": {'text': '0.7 km', 'value': 652}, "duration": {'text': '8 mins', 'value': 477}},
          //           {"id": 3, "distance": {'text': '1.7 km', 'value': 1652}, "duration": {'text': '18 mins', 'value': 1477}},
          //         ];
          //         // List<Map<String, dynamic>> _response = [
          //         //   {"id": 1, "distance": {'text': '0.3 km', 'value': 343}, "duration": {'text': '4 mins', 'value': 269}, "latlng": LatLng(-22.9628, -43.2078)},
          //         //   {"id": 2, "distance": {'text': '0.7 km', 'value': 652}, "duration": {'text': '8 mins', 'value': 477}, "latlng": LatLng(-22.957552481391353, -43.20702816440822)},
          //         //   {"id": 3, "distance": {'text': '1.7 km', 'value': 1652}, "duration": {'text': '18 mins', 'value': 1477}, "latlng": LatLng(-21.957552481391353, -41.20702816440822)},
          //         // ];

          //         List<Map<String, dynamic>> completeObj = [];

          //         if (_response.length == _lst.length) {
          //           for (int i = 0; i < _response.length; i++) {
          //             _response[i]['newPos'] = _lst[i];
          //           }
          //           // for (var newObj in zip([_lst, _response])) {
          //           //   completeObj.add(value)
          //           print(_response);
          //         } else {
          //           print("Something went wrong when calling Google Distance Matrix, missing results");
          //         }
                  

          //         if (_response != null && _response.isNotEmpty) {
          //           _response.sort((a, b) => a['distance']['value'].compareTo(b['distance']['value']));
          //           print(_response.first);

          //           print(_response.fold<int>(10000, (min, e) => e['distance']['value'] < min ? e['distance']['value'] : min));
          //           // print(_response.map<int>((e) => e['age']).reduce(max));
          //         }
          //       },    // Parsing Matrix API
          //       child: Icon(Icons.mail_outline_sharp),
          //   )
          // ),

        ],
      );
  }

  // Map Functions 
  Marker _addNewMarker (String strID, LatLng pos, {double color = BitmapDescriptor.hueGreen, BitmapDescriptor customIcon}) {
    return Marker(
      markerId: new MarkerId(strID),
      infoWindow: new InfoWindow(title: strID),
      onTap: () async {
        double distanceMeters = await 
          Geolocator().distanceBetween(
            userLocation.latitude, userLocation.longitude,   // origin
            pos.latitude, pos.longitude                      // destination
          );
        print("Distance user -> $strID : $pos = $distanceMeters");
      },
      icon:
        // BitmapDescriptor.defaultMarkerWithHue(color), 
        // pinLocationIcon,  // [TODO-CUSTOM PIN]
        customIcon != null ? customIcon : BitmapDescriptor.defaultMarkerWithHue(color),
        position: pos,
    );
  }

  // Pin Markers to show locations on map
  void setMapPins() {
    // [TODO]: TEMP DUMMY 
    // setDummyMarkers();

    setBusStopsMarkers();

    setState(() {
      _markers.add(_addNewMarker('user', userLocation, color: BitmapDescriptor.hueOrange));  // No need marker for user anymore cause current location is displayed
      _markers.add(_addNewMarker('closestBus', closestBusInTraffic, color: BitmapDescriptor.hueRed, customIcon: pinLocationIcon));
      _markers.add(_addNewMarker('closestBusStop', closestBusStop, color: BitmapDescriptor.hueYellow));
      
      // // Add User
      // _markers.add(Marker(
      //   markerId: new MarkerId('user'),
      //   infoWindow: new InfoWindow(title: 'User'),
      //   icon:
      //     BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange), 
      //     position: userLocation,
      // ));     
    });

  }
  
  void setBusStopsMarkers() { 
    
    Set<Marker> _tempList = {}; // [TODO-PERFORMANCE]: CHECK IF SHOULD USE LIST (order) instead of SET (unorder)

    busStops.forEach((LatLng point) {
        String tmp = 'Bus Stop - ' + markIdCounter.toString();

        _tempList.add(Marker(
            markerId: new MarkerId(markIdCounter.toString()),
            // infoWindow: const InfoWindow(title: 'Bus Stop'),  // [TODO-UNCOMMENT]: Just for testing right other of route
            infoWindow: new InfoWindow(title: tmp),
            icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), 
              // BitmapDescriptor.defaultMarkerWithHue(_getPinColor(markIdCounter)),  // [TODO-DELETE]: Just for testing right other of route
              position: point,
          ));     
          markIdCounter += 1;
    });

    setState(() {
      _markers = _tempList;
    });
  }

  void setDummyMarkers() { 
    Set<Marker> _tempList = {}; // [TODO-PERFORMANCE]: CHECK IF SHOULD USE LIST (order) instead of SET (unorder)

    _dummy410Points.forEach((LatLng point) {
        String tmp = '410-' + markIdCounter.toString();

        _tempList.add(Marker(
            markerId: new MarkerId('410-' + markIdCounter.toString()),
            // infoWindow: const InfoWindow(title: 'Bus Stop'),  // [TODO-UNCOMMENT]: Just for testing right other of route
            infoWindow: new InfoWindow(title: tmp),
            icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
              // BitmapDescriptor.defaultMarkerWithHue(_getPinColor(markIdCounter)),  // [TODO-DELETE]: Just for testing right other of route
              position: point,
          ));     
          markIdCounter += 1;
    });

    setState(() {
      _markers = _tempList;
    });
  }


  Future<List<LatLng>> _getDirectionPoints(LatLng origin, LatLng destination, {TravelMode mode = TravelMode.transit}) async {
      List<LatLng> coordinatesLst = [];
      
      // Google API Direction's Service 
      PolylineResult polyResult = await PolylinePoints().getRouteBetweenCoordinates(apiKey, 
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: mode,
      );

      if (polyResult.points.isNotEmpty) {
        polyResult.points.forEach((PointLatLng point){
          coordinatesLst.add(
            LatLng(point.latitude, point.longitude));
        });
      } else if (polyResult.errorMessage == null) {
        String _message = "[ERROR] An error ocurred when attempting to call 'getRouteBetweenCoordinates' to calculate a route.";
        _message += " No routes were found to $origin -> $destination";
        print(_message);
      } else {   // TODO CHECK "Error Status: ZERO_RESULTS."
        String _message = "[ERROR] An error ocurred when attempting to call 'getRouteBetweenCoordinates' to calculate a route";
        _message += "\n Please check if you have permission or exceeded limits for Google Maps Directions API";
        _message += "\n Error Status: ${polyResult.status}. Check complete error below:\n";
        _message += "${polyResult.errorMessage} \n \t\t [Error-END]";
        print(_message);
        // Future.error();
      }
      return coordinatesLst;
  }

  void drawSimpleRoute(
    LatLng origin, LatLng destination, String strID, 
    {TravelMode mode = TravelMode.transit, Color color=Colors.red}) async {

      // [TODO-PERFORMANCE]: Check if should use Future -> .then() here
      // [TODO-FUTURE]: Future.then() EXAMPLE HERE
      // await _getDirectionPoints(origin, destination, mode: mode).then((coordinates) {
      //   if (coordinates.isNotEmpty) {
      //     setState(() {
      //       Polyline polyline = Polyline(
      //         polylineId: new PolylineId(strID),
      //         color: color,  
      //         points: coordinates,
      //         patterns: [PatternItem.dash(10), PatternItem.gap(10)], // dash/dot line style
      //         width: 3,
      //       );
      //       _polylines.add(polyline);   
      //     });
          
      //   }
      // });


      print("Drawing Polyline!!!");
      
      
      List<LatLng> coordinates = await _getDirectionPoints(origin, destination, mode: mode);
      if (coordinates.isNotEmpty) {

        int _width;
        List<PatternItem> _pattern;

        if (mode == TravelMode.walking) {
          _width = 3;
          _pattern = [PatternItem.dash(10), PatternItem.gap(10)];

        } else {
          _width = 4;
          _pattern = [];
        }

        setState(() {
          Polyline polyline = Polyline(
            polylineId: new PolylineId(strID),
            color: color,  
            points: coordinates,
            patterns: _pattern, // dash/dot line style
            width: _width,
          );
          _polylines.add(polyline);   
        });

      }
  }

  void setPolylines() {

    // user -> nearst bus stop
    drawSimpleRoute(userLocation, closestBusStop, 'user-closesStop', 
      mode: TravelMode.walking, color: Colors.indigo[500]);


    LatLng _orig = closestBusInTraffic;
    LatLng _dest = closestBusStop;
    drawSimpleRoute(_orig, _dest, polyIdCounter.toString());


    // [TODO 24/06 & 18/06]: UNCOMMENT HERE
    // all bus stops

    // TODO NOW
    // _polylines.clear();
    for (int i = 1; i < busStops.length; i++, polyIdCounter++) {
      LatLng _orig = busStops[i-1];
      LatLng _dest = busStops[i];
      drawSimpleRoute(_orig, _dest, polyIdCounter.toString());
    }

    // [TODO]: TEMP DUMMY 
    // for (int i = 1, polyIdCounter=0; i < _dummy410Points.length; i++, polyIdCounter++) {
    //   LatLng _orig = _dummy410Points[i-1];
    //   LatLng _dest = _dummy410Points[i];
    //   // drawSimpleRoute(_orig, _dest, polyIdCounter.toString());
    //   drawSimpleRoute(_orig, _dest, '410-' + polyIdCounter.toString(), color: Colors.purpleAccent);
    // }

  } 


  
  // [TODO]: Adicionar explicação sobre porque método para calcular distancia entre dois pontos do Geolocator não funciona.
  //            Follow here: https://blog.codemagic.io/creating-a-route-calculator-using-google-maps/
  //            Investigate 'Haversine' formula
  //              https://www.geeksforgeeks.org/program-distance-two-points-earth/


  // [TODO: URGENT!!!!!!]
  // Calculate route distance between two LatLng points
  // GOOGLE API: MATRIX DISTANCE: 
  //    https://developers.google.com/maps/documentation/distance-matrix/overview
  //      (Retorna a distancia entre dois pontos, considerando rotas ?)

  // GOOGLE API: ELEVATION SERVICE: 
  //    https://stackoverflow.com/questions/12299875/finding-intermediate-lattitude-longitude-between-two-given-points
  //    https://developers.google.com/maps/documentation/javascript/elevation
  //      (Pega varios pontos intermediarios entre 2 pts de Lat&Lon -> Soma ponto a ponto com a lib de flutter para descobrir distancia)



  void _detectNearstBusStop() async {


    print('Finding Closest Bus Stop...');
    // // POSTMAN
    var request = http.Request('GET', Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?mode=walking&origins=-22.9628, -43.2078 | -22.957552481391353, -43.20702816440822&destinations=-22.96054514205402, -43.207136435812984&key=$apiKey'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      String _resp = await response.stream.bytesToString();
      final body = jsonDecode(_resp);

      setState(() {
        _responseDM = body;
      });
      print(body);
    }
    else {
      print(response.reasonPhrase);
    }

  // Future<String> getDuration(LatLng l1, List<LatLng> l2) async {

  //   var destinations = await _getwaypoints(l2);
  //   String url =
  //        "https://maps.googleapis.com/maps/api/distancematrix/json? 
  //    origin=${l1.latitude},${l1.longitude}&destination=$destinations&departure_time=now&key=$apiKey";
  //   http.Response response = await http.get(url);
  //   Map values = jsonDecode(response.body);

  //   return values.toString();

  }

  // Future<ResponseObject> _detectNearstBusStop() async {


  //   print('Finding Closest Bus Stop...');
  //   await for (Stream<int> i = 0; i < count; i++) async {
      
  //   }

  //   ResponseObject closestBusStop = new ResponseObject(distance: '10', duration: '10', position: LatLng(-22.915459, -43.2330669));
  //   return closestBusStop;


  //   // // POSTMAN
  //   // var request = http.Request('GET', Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?mode=walking&origins=-22.9628, -43.2078 | -22.957552481391353, -43.20702816440822&destinations=-22.96054514205402, -43.207136435812984&key=apiKey'));
  //   // http.StreamedResponse response = await request.send();
  //   // if (response.statusCode == 200) {
  //   //   print(await response.stream.bytesToString());
  //   // }
  //   // else {
  //   //   print(response.reasonPhrase);
  //   // }


  //   // for (int i = 1; i < busStops.length; i++, polyIdCounter++) {
  //   //   LatLng _orig = busStops[i-1];
  //   //   LatLng _dest = busStops[i];
  //   //   drawSimpleRoute(_orig, _dest, polyIdCounter.toString());
  //   // }

  //   // setState(() {
  //   //   userLocation = LatLng(-22.915459, -43.2330669);
  //   //   screenLoading = false;
  //   // });


  // }


  // // TODO JUST FOR TESTING:
  void _changeUserLocation() async {
    print('Changing user location...');
    setState(() {
      userLocation = LatLng(-22.915459, -43.2330669);
      screenLoading = false;
    });
  }


  void _findMyBus() async {
    print('Finding closest bus...');

    // Distance Matrix Mocked Response:
    print("\n\tReceiving Response from Distance Matrix - Finding Closest Bus Stop");
    List<LatLng> _busStopsLst = [
      // LatLng(-22.9628, -43.2078), 
      // LatLng(-22.957552481391353, -43.20702816440822), 
      // LatLng(-21.957552481391353, -41.20702816440822)
      LatLng(-22.9793,-43.2306),  
      LatLng(-22.960762, -43.208245),  // closest
      LatLng(-22.9602,-43.2043),   // 2nd closest
      LatLng(-22.963,-43.2164)  
    ];
    
    
    // TODO: Refactor variable '_response' to a better name | Use function to call and return this
    List<Map<String, dynamic>> _response = [
      {"id": 1, "distance": {'text': '0.7 km', 'value': 652}, "duration": {'text': '8 mins', 'value': 477}},
      // {"id": 2, "distance": {'text': '0.3 km', 'value': 343}, "duration": {'text': '4 mins', 'value': 269}},
      {"id": 2, "distance": {'text': '2.6 km', 'value': 343}, "duration": {'text': '7 mins', 'value': 269}},
      {"id": 3, "distance": {'text': '0.5 km', 'value': 400}, "duration": {'text': '5 mins', 'value': 290}},
      {"id": 4, "distance": {'text': '1.7 km', 'value': 1652}, "duration": {'text': '18 mins', 'value': 1477}},
    ];
    if (_response.length == _busStopsLst.length) {
      for (int i = 0; i < _response.length; i++) {
        _response[i]['latlng'] = _busStopsLst[i];
      }
      print(_response);
    } else {
      print("Something went wrong when calling Google Distance Matrix, missing results. \nMaybe one of the addresses used does not have a route to the destination.");
    }

    if (_response != null && _response.isNotEmpty) {
      // Sort item's list by the smallest distance 
      _response.sort((a, b) => a['distance']['value'].compareTo(b['distance']['value']));
      print(_response.first);
    }




    // LatLng _tempClosestBus = LatLng(-22.96169870408114, -43.21490796908142);
    // LatLng _tempClosestBus = LatLng(-22.969409260910265, -43.22195362031163);
    LatLng _tempClosestBus = LatLng(-22.9750724384346, -43.22582457792264);
    // TODO: Change and Call -> setMapPins(); with this:
    // TODO: Before adding new markers, delete old ones.
    _markers.clear();
    setState(() {
      // _markers.add(_addNewMarker('closestBus', closestBusInTraffic, color: BitmapDescriptor.hueRed, customIcon: pinLocationIcon));
      _markers.add(_addNewMarker('closestBus', _tempClosestBus, color: BitmapDescriptor.hueRed, customIcon: pinLocationIcon));
      _markers.add(_addNewMarker('closestBusStop', _response.first['latlng'], color: BitmapDescriptor.hueOrange));
    });


    // TODO: Before Drawning new routes. Clear the old ones
    _polylines.clear();

    // TODO: Change and Call -> setPolylines(); with this:
    drawSimpleRoute(userLocation, closestBusStop, 'user-closesStop', mode: TravelMode.walking, color: Colors.indigo[500]);
    
    // LatLng _orig = closestBusInTraffic;
    LatLng _orig = _tempClosestBus;
    LatLng _dest =  _response.first['latlng'];
    drawSimpleRoute(_orig, _dest, 'bus-closestStop', mode: TravelMode.driving);

    setState(() {
      _estimatedDistance = _response.first['distance']['text'];
      _estimatedTime = _response.first['duration']['text'];
    });


    // var url = Uri.parse('http://10.0.2.2:5000/get_line/315');
    // // NOTE: Por algum motivo quando esse request é feito para o cliente Web, ele não recebe a resposta de volta
    // // var url = Uri.parse('http://localhost:5000/get_line/315');
    // var client = http.Client();
    // try {
    //   var uriResponse = await client.get(url);
    //   print('Response status: ${uriResponse.statusCode}');
    //   print('Response body: ${uriResponse.body}');
    // } finally {
    //   client.close();
    // }
    // print('\nCurrLocation: ${currLocationController.text} | BusLine: ${busLineInputController.text} \n\n');
  }


}



