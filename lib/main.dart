import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
// import 'package:dio/dio.dart' as d;
import 'package:http/http.dart' as http;
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
  List<dynamic> arr = [];

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
            print(_connectivityStatus);
          });
          print(_connectivityStatus); // display in the console
          if ( result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile) {
             getData();
          }
        });
  }

  @override
  void dispose() {
    subscription.cancel(); // unregister from listener
    super.dispose();
  }

  _refreshAction() async {
    getData();
  }

  Future<List<User>> getData() async {

    // https://referbruv.com/blog/posts/flutter-for-beginners-fetch-items-from-api-and-bind-using-futurebuilder
    final res = await http.get("https://jsonplaceholder.typicode.com/posts/");

    if (res.statusCode == 200) {
      var content = res.body;
      arr = json.decode(content) as List;

      return arr.map((user) => new User.fromJson(user)).toList();
    }

    arr = [];
    return List<User>();
    /*try {
      if (response.statusCode == 200) {
        print(response);
        var result = jsonDecode(response.data);*/
        /*print(result);
        return result.map((user) => new User.fromJson(user)).toList();*/
        /* return result;
      }
    } catch (e) {
      print(e);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
     floatingActionButton: new Visibility(
       // ignore: null_aware_before_operator
       visible: arr?.length < 0,
       child: new FloatingActionButton(
         onPressed: _refreshAction,
         tooltip: 'Refresh',
         child: new Icon(Icons.refresh),
       ),
     ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if ( snapshot.hasData ) {
            var myData = snapshot.data;
            print("My Data $myData}");

            if ( myData == null ) {
              return Center(
                child: Text('No data found!'),
              );
            }

            return ListView.builder(
              itemBuilder: (context, index) {
                User user = snapshot.data[index];
                return ListTile(
                    title: Text(user.title)
                );
              },
              itemCount: myData.length,
            );
          } else if(snapshot.hasError){
            return Center(
                child:  snapshot.error.toString().contains("SocketException")
                ? Text("Error in network connection.") : Text("Error ${snapshot.error}")
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
