import 'package:flutter/material.dart';
import 'package:find_my_bus/custom_maps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:geolocator/geolocator.dart';

void main() async {
  // To load the .env file contents into dotenv.
  await dotenv.load(fileName: "assets/env_vars.env");
  runApp(MyApp());  
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find My Bus',
      debugShowCheckedModeBanner: false,
      // home: MapView(),
      // home: MyCustomMap(),
      // home: DumTestClass(),
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            MyCustomMap(),
            // Positioned(
            //   top: 10,
            //   right: 15,
            //   left: 15,
            //   child: TextField(

            //     // controller: currLocationController,  // Listener of text input
            //     decoration: InputDecoration(
            //       // border: OutlineInputBorder(),
            //       border: UnderlineInputBorder(),
            //       labelText: 'Enter a your current location: (lat, lon)',
            //       hintText: '-22.915459, -43.208501',
            //     ),
            //   ),
            // )
          ],
        )
      )
    );
  }
}


/*

class DumTestClass extends StatefulWidget {
  @override
  _DummyState createState() => _DummyState();
}

class _DummyState extends State<DumTestClass> {

  String _text = "hello";
  bool _toogle = true;
  Position _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(15, 50, 0, 30),
            child: Text(
              _text,
            ),
          ),
          
          Container(
            padding: EdgeInsets.fromLTRB(255, 5, 0, 30),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
              onPressed: () => _getCurrentLocation(),
            ),
          )
        ]
      ) 
    );
  }

  // Simple example showing how to change a text when pressing button
  // setState is only used for what is being show on screen
  void _changeText() async {
    Geolocator geolocator = new Geolocator();  
    Position pos;

    String _textVal;
    if (_toogle) {
      _textVal = "hello";
    } else {
      _textVal = "good bye";
    }
    _toogle = !_toogle;

    setState(() {
      _text = _textVal;
    });
    print(_text);
  }


  // TODO: Comment on TCC: https://stackoverflow.com/questions/59480999/flutter-geo-locator-give-wrong-latitude-and-longitude
  void _getCurrentLocation() async {
    Geolocator geolocator = new Geolocator();  

    // TODO check AWAIT x THEN usage here
    // geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, locationPermissionLevel: GeolocationPermission.location)
    //   .then((Position position) {
    //     setState(() {
    //       // _currentPosition = position;
    //       _text = position.toString();
    //     });
    //   }).catchError((e) {
    //     print(e);
    //   });

    Position position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, 
        locationPermissionLevel: GeolocationPermission.location
      );
    setState(() {
      // _currentPosition = position;
      _text = position.toString();
    });

    print(_text);
  }

}

*/




/*

class MyCustomMap extends StatefulWidget {
  @override
  _SimpleMapState createState() => _SimpleMapState();
}

class _SimpleMapState extends State<MyCustomMap> {

  Completer<GoogleMapController> _controller = Completer();

  // TODO: TESTING HERE
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

    LatLng pinPosition = LatLng(-22.915459, -43.208501);
    CameraPosition _kInitialPosition = CameraPosition(target: pinPosition, zoom: 11.0, tilt: 0, bearing: 0);

    return Scaffold(
      body: GoogleMap(
        // liteModeEnabled: true,  // TODO: Test performance improvment here (Why doesn't work ?????)
        myLocationEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        initialCameraPosition: _kInitialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          setState(() {
            _markers.addAll(positions);
          });
        },
        onLongPress: _addMarker,
      )
    );
  }
}

*/


/*

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  // Initial location of the Map view
  // CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  static final LatLng _kMapCenter = LatLng(-22.915459, -43.208501);
  static final CameraPosition _initialLocation = CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  // For controlling the view of the Map
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    // Determining the screen width & height
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[

            GoogleMap(
              // liteModeEnabled: true,  // TODO: Why doesn't work ?????
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),

          ],
        ),
      ),
    );
  }
}

*/