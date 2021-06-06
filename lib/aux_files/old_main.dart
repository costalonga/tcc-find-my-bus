import 'dart:async';
import 'package:find_my_bus/aux_files/directions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'directions_model.dart';

class MyCustomMap extends StatefulWidget {
  @override
  _SimpleMapState createState() => _SimpleMapState();
}

class _SimpleMapState extends State<MyCustomMap> {

  Completer<GoogleMapController> _controller = Completer();

  // TODO: TESTING HERE
  String _mapStyle;  // Will storage google map's configuration style from file '../assets/map_style.txt'
  GoogleMapController _googleMapController;  // Controller for google map

  // [TODO-3]: Trying to draw route
  // Markers
  Marker _userLocationMrk;
  Marker _originMrk;
  Marker _destinationMrk;

  // Directions to draw routes
  Directions _infoDrct;


  // [TODO-Others]: Check if its necessary 
  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};

  List<Marker> positions = [
    Marker(
      markerId: MarkerId('Marker1'),
      position: LatLng(-22.915459, -43.208501),
      infoWindow: InfoWindow(title: 'Business 1'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
    Marker(
      markerId: MarkerId('Marker2'),
      position: LatLng(-20.915459, -45.208501),
      infoWindow: InfoWindow(title: 'Business 2'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    )
  ];

  @override
  void initState() {
      super.initState();
      rootBundle.loadString('assets/map_style.txt').then((value){
        _mapStyle = value;
      });
      // setCustomMapPin();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/bus_marker.png');
  }


  void _markCurrentLocation(LatLng userLocation) {
    setState(() {
        _userLocationMrk = Marker(
          markerId: const MarkerId('user'),
          infoWindow: const InfoWindow(title: 'user'),
          icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: userLocation,
        );
      });
  }

  // [TODO-3]: Trying to draw route (added 'async')
  void _addMarker(LatLng pos) async {

    // positions.add(
    //   Marker(
    //     markerId: MarkerId('Marker2'),
    //     position: LatLng(-18.919459, -46.208431),
    //     infoWindow: InfoWindow(title: 'Business 3'),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    //   )
    // );

    if (_originMrk == null || (_originMrk != null && _destinationMrk != null)) {
      setState(() {
        _originMrk = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            position: pos,
        );

        // [TODO-3]: Trying to draw route
        // Reset destination and description info
        _destinationMrk = null;
        _infoDrct = null;

      });
    } else { 
      setState(() {
        _destinationMrk = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'destination'),
          icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos,
        );
      });

      // [TODO-3]: Trying to draw route
      // Get directions from Origin to Destination
      final directions = await DirectionsRepository().getDirections(origin: _originMrk.position, destination: pos);
      setState(() {
        _infoDrct = directions;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng myHouse = LatLng(-22.96298, -43.208807);
    LatLng pucLocation = LatLng(-22.990706, -43.25011);
    LatLng pinPosition = LatLng(-22.915459, -43.2330669);
    CameraPosition _kInitialPosition = CameraPosition(target: myHouse, zoom: 15.0, tilt: 0, bearing: 0);

    // return Container(
    //   width: double.infinity,
    //   height: double.infinity,
    //   child: GoogleMap(
    //     // liteModeEnabled: true,  // TODO: Test performance improvment here (Why doesn't work ?????)
    //     myLocationEnabled: true,
    //     buildingsEnabled: false,
    //     indoorViewEnabled: false,
    //     compassEnabled: true,
    //     tiltGesturesEnabled: false,
    //     initialCameraPosition: _kInitialPosition,
    //     // onMapCreated: (controller) => _googleMapController = controller,  // new way of using google map controller
    //     markers: {
    //       if (_userLocationMrk != null) _userLocationMrk,
    //       if (_originMrk != null) _originMrk,
    //       if (_destinationMrk!= null) _destinationMrk
    //     },

    //     onMapCreated: (GoogleMapController controller) {
          
    //       if(mounted) {
    //         _googleMapController = controller;
    //         controller.setMapStyle(_mapStyle);
    //         _markCurrentLocation(myHouse); // TODO: Instead of using 'myHouse' use user's current location
    //       }

    //       // controller.setMapStyle(
    //       //   '[{"featureType": "all","stylers": [{ "color": "#C0C0C0" }]},{"featureType": "road.arterial","elementType": "geometry","stylers": [{ "color": "#CCFFFF" }]},{"featureType": "landscape","elementType": "labels","stylers": [{ "visibility": "off" }]}]'
    //       // );


    //       // _controller.complete(controller);
    //       // setState(() {
    //       //   _markers.addAll(positions);
    //       // });
    //     },
    //     onLongPress: _addMarker,
    //   )
    // );


    // [TODO-3]: Trying to draw route
    return Container(
      alignment: Alignment.center,  // [TODO-4] Check here
      width: double.infinity,
      height: double.infinity,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              buildingsEnabled: false,
              indoorViewEnabled: false,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              initialCameraPosition: _kInitialPosition,
              markers: {
                if (_userLocationMrk != null) _userLocationMrk,
                if (_originMrk != null) _originMrk,
                if (_destinationMrk!= null) _destinationMrk
              },

              // [TODO-5 STR] Polylines 
              polylines: {
                if (_infoDrct != null) 
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _infoDrct.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                  ),
              },
              // [TODO-5 END] Polylines 

              onMapCreated: (GoogleMapController controller) {
                // As soon as widget if mounted, after initial state
                if(mounted) {
                  _googleMapController = controller;
                  controller.setMapStyle(_mapStyle);
                  _markCurrentLocation(myHouse); // TODO: Instead of using 'myHouse' use user's current location
                }
              },
              onLongPress: _addMarker,
            ),

            // [TODO-4] Check here
            if (_infoDrct != null)
              Positioned(
                top: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Text(
                    '${_infoDrct.totalDistance}, ${_infoDrct.totalDuration}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ),
            // [TODO-4 END] Check here


            // [TODO-3]: Trying to draw route
            FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
              onPressed: () => _googleMapController.animateCamera(
                _infoDrct != null
                ? CameraUpdate.newLatLngBounds(_infoDrct.bounds, 100.0)
                : CameraUpdate.newCameraPosition(_kInitialPosition),
              ),
              child: const Icon(Icons.center_focus_strong),
            )

          ],
        ),
      ),


    );


    
// child: Scaffold(
//         body: Stack(
//           children: <Widget>[



    // return Container(
    //   width: double.infinity,
    //   height: double.infinity,
    //   child: GoogleMap(
    //     // liteModeEnabled: true,  // TODO: Test performance improvment here (Why doesn't work ?????)
    //     myLocationEnabled: true,
    //     compassEnabled: true,
    //     tiltGesturesEnabled: false,
    //     markers: _markers,
    //     initialCameraPosition: _kInitialPosition,
    //     onMapCreated: (GoogleMapController controller) {
    //       // controller.setMapStyle(Utils.mapStyles);
    //       _controller.complete(controller);
    //       setState(() {
    //         _markers.add(
    //             Marker(
    //               markerId: MarkerId('<MARKER_ID>'),
    //               position: pinPosition,
    //               icon: pinLocationIcon
    //             )
    //         );
    //       });
    //     },
    //   )
    // );
  }
}
