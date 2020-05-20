import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Google Directions View'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  String apiKey = "";
  final originController = TextEditingController();
  final destController = TextEditingController();
  RegExp regExp = RegExp(r'#,<b>([A-Z].*?)</b>#', caseSensitive: false, multiLine: false);
  @override
  void dispose() {
    originController.dispose();
    destController.dispose();
    super.dispose();
  }
  
  List list = List();
  List<String> htmlVal = List();

  var isLoading = false;
  _fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get("https://maps.googleapis.com/maps/api/directions/json?origin=${originController.text}&destination=${destController.text}&key=AIzaSyDtwCm5qw7S7ruArmqyZxE-pyIs4b9bNcs", headers: {'Content-Type':'application/json'});
    if (response.statusCode == 200) {
       Map<String, dynamic> values = json.decode(utf8.decode(response.bodyBytes));
       list = values['routes'][0]['legs'][0]['steps'] as List;
       for(var i = 0; i < list.length; i++){
         htmlVal.add(list[i]['html_instructions']);
       }
       for(var j = 0; j < htmlVal.length; j++){
         htmlVal[j] = htmlVal[j].replaceAll('<b>', "");
         htmlVal[j] = htmlVal[j].replaceAll('</b>', "");
         htmlVal[j] = htmlVal[j].replaceAll('/<wbr/>', "");
         htmlVal[j] = htmlVal[j].replaceAll('<div style="font-size:0.9em">', "");
         htmlVal[j] = htmlVal[j].replaceAll('</div>', "");
         htmlVal[j] = htmlVal[j].replaceAll("  ", " ");
       }
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load');
    }
  }
  /*
  Future<String> getRouteCoordinates(String s1, String l2) async {
                  String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${originController.text}&destination=${destController.text}&key=AIzaSyDtwCm5qw7S7ruArmqyZxE-pyIs4b9bNcs";
                  http.Response response = await http.get(url);
                  //print(response);
                  Map values = json.decode(utf8.decode(response.bodyBytes));
                  List htmlVal = values['routes'][0]['legs'][0]['steps'];
                  for (var i = 0; i < htmlVal.length; i++){
                    print(htmlVal[i]['distance']['text'] + "/" + htmlVal[i]['duration']['text']);
                    print(htmlVal[i]['html_instructions']);
                  }
                }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SafeArea(
          minimum: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter origin'
              ),
              controller: originController,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10)
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter destination'
              ),
              controller: destController,
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            FlatButton(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.grey)
              ),
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 100.0),
              splashColor: Colors.grey,
              onPressed: () => _fetchData(),
              child: Text(
                "GET DIRECTIONS",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Row(
              children: <Widget>[
                Expanded(child: SizedBox(
                  height: 500.0,
                  child: Scrollbar(
                    child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      title: Text(list[index]['distance']['text'] + " / " + list[index]['duration']['text']),
                      subtitle: Text(htmlVal[index] , style: TextStyle(fontSize: 14,),),
                      );
                    }),
                  ),
                )),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}


