import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

class MyCustomInputPanel extends StatefulWidget {
  @override
  _InputPanelFormState createState() => _InputPanelFormState();
}

class _InputPanelFormState extends State<MyCustomInputPanel> {

  // Controllers to listen text field input
  final currLocationController = TextEditingController();
  final busLineInputController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    currLocationController.dispose();
    busLineInputController.dispose();
    super.dispose();
  }

  // Use to make request to AWS API GATEWAY
  // void findMyBus() async {
    
  //   var headers = {
  //     'x-api-key': '',
  //     'X-Amz-Date': '',
  //     'Authorization': ''
  //   };
  //   var request = http.Request('GET', Uri.parse(''));
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //   }
  //   else {
  //     print(response.reasonPhrase);
  //   }
  // }
  
  void _findMyBus() async {
    print('Finding closest bus...');
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
    print('\nCurrLocation: ${currLocationController.text} | BusLine: ${busLineInputController.text} \n\n');
  }


  // Every time flutter uses "Hot Reload" is loads/runs "build" method again
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: currLocationController,  // Listener of text input
            decoration: InputDecoration(
              // border: OutlineInputBorder(),
              border: UnderlineInputBorder(),
              labelText: 'Enter a your current location: (lat, lon)',
              hintText: '-22.915459, -43.208501',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            controller: busLineInputController,  // Listener of text input
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter the bus line of your interest',
              hintText: '315',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: ElevatedButton(
            onPressed: _findMyBus, 
            child: Text(
              'Find My Bus!', 
            ),  

            // [BUTTON STYLE]          
            // style: ElevatedButton.styleFrom(
            //   primary: Colors.teal,
            //   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            //   textStyle: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.w500
            //   )
            // ),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal)),
            // style: ButtonStyle(backgroundColor: MaterialStateProperty<Colors.teal>) HOW TO DO IT??
          ),
        ),
      ],
    );
  }
}