import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter_connectivity/models/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter connectivity demo test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Connectivity checker app'),
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

  // set connectivity state
  var _connectivityStatus = 'Unknown';
  Connectivity connectivity; // declare connectivity object
  // create a stream subscriber
  StreamSubscription<ConnectivityResult> subscription; // this is to hold the result of the connectivity

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // instantiate connectivity class
    connectivity = Connectivity();
    // register a network change event
    subscription = 
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _connectivityStatus = result.toString();
          });
          print(_connectivityStatus); // display in the console
          if ( result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile) {

          }
        });
  }

  @override
  void dispose() {
    subscription.cancel(); // unregister from listener
    super.dispose();
  }

  Future<User> getData() async {
    var dio = d.Dio();
    try {
      d.Response response = await dio.get("https://jsonplaceholder.typicode.com/posts/");
      if (response.statusCode == 200) {
        print(response);
        var result = jsonDecode(response.data);
        print(result);
        return User.fromJson(result);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if ( snapshot.hasData ) {
            var myData = snapshot.data;

            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                title: myData[index]['title']
              ),
              itemCount: myData.length,
            );
          } else if(snapshot.hasError){
            return Center(
                child:  Text("Error ${snapshot.error}")
            );
          }else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }
}

class Dio {
}
