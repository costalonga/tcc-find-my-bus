import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


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
  Marker _origin;
  Marker _destination;


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

  void _addMarker(LatLng pos) {

    // positions.add(
    //   Marker(
    //     markerId: MarkerId('Marker2'),
    //     position: LatLng(-18.919459, -46.208431),
    //     infoWindow: InfoWindow(title: 'Business 3'),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    //   )
    // );

    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            position: pos,
        );
      });
    } else { 
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'destination'),
          icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng myHouse = LatLng(-22.96298, -43.208807);
    LatLng pucLocation = LatLng(-22.990706, -43.25011);
    LatLng pinPosition = LatLng(-22.915459, -43.2330669);
    CameraPosition _kInitialPosition = CameraPosition(target: myHouse, zoom: 15.0, tilt: 0, bearing: 0);

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
        markers: {
          if (_origin != null) _origin,
          if (_destination!= null) _destination
        },
        onMapCreated: (GoogleMapController controller) {
          if(mounted) {
            _googleMapController = controller;
            controller.setMapStyle(_mapStyle);
          }
        },
        onLongPress: _addMarker,
      )
    );
  }
}
