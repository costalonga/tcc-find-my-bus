// import 'package:flutter/material.dart';
// // import 'package:find_my_bus/custom_maps.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:geolocator/geolocator.dart';


// class DumTestClass extends StatefulWidget {
//   @override
//   _DummyState createState() => _DummyState();
// }

// class _DummyState extends State<DumTestClass> {

//   String _text = "hello";
//   bool _toogle = true;
//   Position _currentPosition;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           Container(
//             padding: EdgeInsets.fromLTRB(15, 50, 0, 30),
//             child: Text(
//               _text,
//             ),
//           ),
          
//           Container(
//             padding: EdgeInsets.fromLTRB(255, 5, 0, 30),
//             child: FloatingActionButton(
//               backgroundColor: Theme.of(context).primaryColor,
//               foregroundColor: Colors.black,
//               onPressed: () => _getCurrentLocation(),
//             ),
//           )
//         ]
//       ) 
//     );
//   }

//   // Simple example showing how to change a text when pressing button
//   // setState is only used for what is being show on screen
//   void _changeText() async {
//     Geolocator geolocator = new Geolocator();  
//     Position pos;

//     String _textVal;
//     if (_toogle) {
//       _textVal = "hello";
//     } else {
//       _textVal = "good bye";
//     }
//     _toogle = !_toogle;

//     setState(() {
//       _text = _textVal;
//     });
//     print(_text);
//   }


//   // TODO: Comment on TCC: https://stackoverflow.com/questions/59480999/flutter-geo-locator-give-wrong-latitude-and-longitude
//   void _getCurrentLocation() async {
//     Geolocator geolocator = new Geolocator();  

//     // TODO check AWAIT x THEN usage here
//     // geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, locationPermissionLevel: GeolocationPermission.location)
//     //   .then((Position position) {
//     //     setState(() {
//     //       // _currentPosition = position;
//     //       _text = position.toString();
//     //     });
//     //   }).catchError((e) {
//     //     print(e);
//     //   });

//     Position position = await 
//       geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best, 
//         locationPermissionLevel: GeolocationPermission.location
//       );
//     setState(() {
//       // _currentPosition = position;
//       _text = position.toString();
//     });

//     print(_text);
//   }

// }