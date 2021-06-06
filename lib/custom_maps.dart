import 'dart:async';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:find_my_bus/dummy_data.dart';


// Almost Working Styled Map!!!!!!


class MyCustomMap extends StatefulWidget {
  @override
  _SimpleMapState createState() => _SimpleMapState();
}

class _SimpleMapState extends State<MyCustomMap> {

  Completer<GoogleMapController> _controller = Completer();

  // TODO: TESTING HERE
  String _mapStyle;
  GoogleMapController _googleMapController;

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



  //                                                      [TODO-NEW]: HERE!!!!!!!!
  // [TODO-NEW]: Testing User / Closest Bus Location
  LatLng closestBusStop = LatLng(-22.960762, -43.208245);   // CLOSEST STOP HERE
  LatLng closestBusInTraffic = LatLng(-22.960936, -43.209888);   
  LatLng userLocation = LatLng(-22.962734, -43.207733);
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
  


  // List<LatLng> _dummy410Points;

  @override
  void initState() {
    // [TODO-IMPROVEMENT]: TESTE INITAL METHODS HERE INSTEAD OF "on mount" (e.g. SetPins, SetMarkers, ...)
    //                     CHECK FOR PERFOMANCE CHANGES
      super.initState();
      rootBundle.loadString('assets/map_style.txt').then((value){
        _mapStyle = value;
      });
      
      // _dummy410Points = Fake410Points().busStops;

      // setCustomMapPin();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }


  // Customize Marker Icon
  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/bus_marker.png');
  }


  void _addMarker(LatLng pos) {
    print(_markers);
    print("Length: ${_markers.length}");
    print("Counter: ${markIdCounter}");
  }


  // Adds a marker on the map
  // void _addMarker(LatLng pos) {

  //   // positions.add(
  //   //   Marker(
  //   //     markerId: MarkerId('Marker2'),
  //   //     position: LatLng(-18.919459, -46.208431),
  //   //     infoWindow: InfoWindow(title: 'Business 3'),
  //   //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
  //   //   )
  //   // );

  //   if (_origin == null || (_origin != null && _destination != null)) {
  //     setState(() {
  //       _origin = Marker(
  //         markerId: const MarkerId('origin'),
  //         infoWindow: const InfoWindow(title: 'Origin'),
  //         icon:
  //           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //           position: pos,
  //       );
  //     });
  //   } else { 
  //     setState(() {
  //       _destination = Marker(
  //         markerId: const MarkerId('destination'),
  //         infoWindow: const InfoWindow(title: 'destination'),
  //         icon:
  //           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //           position: pos,
  //       );
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    LatLng myHouse = LatLng(-22.96298, -43.208807);
    // LatLng myHouse = LatLng(-22.9789,-43.2284);
    // LatLng myHouse = LatLng(-22.9199,-43.1963);
    LatLng pucLocation = LatLng(-22.990706, -43.25011);
    LatLng pinPosition = LatLng(-22.915459, -43.2330669);
    CameraPosition _kInitialPosition = CameraPosition(target: myHouse, zoom: 14.0, tilt: 0, bearing: 0);

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GoogleMap(
        myLocationEnabled: true,
        // buildingsEnabled: false,
        // indoorViewEnabled: false,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        initialCameraPosition: _kInitialPosition,
        
        onMapCreated: (GoogleMapController controller) {
          if(mounted) {
            _googleMapController = controller;
            controller.setMapStyle(_mapStyle);
          }
          // [TODO-POLY-MARKER]: TESTING HERE
          setMapPins();
          // drawUserRoute();   // TODO: Change here to draw polylines
          setPolylines();

        },
        markers: _markers,
        polylines: _polylines,  
        // [TODO-2]: TESTING HERE

        onLongPress: _addMarker,
      )
    );
  }



  // void setMapPins() { 
  //   LatLng myHouse = LatLng(-22.9793,-43.2306);
  //   LatLng pucLocation = LatLng(-22.9784,-43.2263);
  //   setState(() {
  //       _markers.add(Marker(
  //           markerId: const MarkerId('origin'),
  //           icon:
  //             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //             position: myHouse,
  //         ));     
  //       _markers.add(Marker(
  //           markerId: MarkerId('destination'),
  //           icon:
  //             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //             position: pucLocation,
  //         ));   
  //     });
  // }
  


  Marker _addNewMarker (String strID, LatLng pos, {double color = BitmapDescriptor.hueGreen}) {
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
        BitmapDescriptor.defaultMarkerWithHue(color), 
        position: pos,
    );
  }

  // Pin Markers to show locations on map
  void setMapPins() {
    setBusStopsMarkers();


    setState(() {
      _markers.add(_addNewMarker('user', userLocation, color: BitmapDescriptor.hueOrange));
      _markers.add(_addNewMarker('closestBus', closestBusInTraffic, color: BitmapDescriptor.hueRed));
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
      } else {
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

      List<LatLng> coordinates = await _getDirectionPoints(origin, destination, mode: mode);
      if (coordinates.isNotEmpty) {

        int _width;
        List<PatternItem> _pattern;

        if (mode == TravelMode.walking) {
          _width = 2;
          _pattern = [PatternItem.dash(10), PatternItem.gap(10)];

        } else {
          _width = 3;
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
      mode: TravelMode.walking, color: Colors.indigo[200]);

    // all bus stops
    for (int i = 1; i < busStops.length; i++, polyIdCounter++) {
      LatLng _orig = busStops[i-1];
      LatLng _dest = busStops[i];

      drawSimpleRoute(_orig, _dest, polyIdCounter.toString());
    }
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

}
