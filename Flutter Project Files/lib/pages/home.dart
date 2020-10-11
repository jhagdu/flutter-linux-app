//Importing Required Modules
import 'dart:convert';
import 'dart:math';

import 'package:LinuxCmnd/pages/global_variables.dart';
import 'package:LinuxCmnd/pages/side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



//Linux App Class
class LinuxAppHome extends StatefulWidget {
  @override
  _LinuxAppHomeState createState() => _LinuxAppHomeState();
}

class _LinuxAppHomeState extends State<LinuxAppHome> {

  //Variables Local to Class
  var command, status, output, showHere, id=0;

  //Function to get Command Output from Linux and Store it in Firestore
  storeOutput() async {
  
    var ids=[0];
    var d = await fsconnect.collection("LinuxCommands").get();
    for (var i in d.docs) {
      ids.add(i.data()['id']);
    }
    id = ids.reduce(max) + 1;

    var url = "http://$ip/cgi-bin/linuxcmnd.py?command=$command";
    var response = await http.get(url);
    var responseBody = jsonDecode(response.body);
    status = responseBody["status"];
    output = responseBody["output"];

    if (status == 0 ) {
      setState(() {
        showHere = "Command Sucessfull and Output Stored";  
      });
    } else {
      setState(() {
        showHere = "Command Failed but Output Stored";          
      });
    }
  }

  //Function to Retrive Data from Firestore
  retriveOutput() async {
    var datas=[];
    var d = await fsconnect.collection("LinuxCommands").orderBy('id', descending: true).get();
    for (var i in d.docs) {
      setState(() {
        datas.add(i.data());
        showHere = datas;
      });
    }
  }

  //Function to Change Host Configuations
  changeHostConfToSP(var key, val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, val);
  }

  //Function to Create IP dialog Box
  Future ipDialog() async {

    var newIP;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Host IP'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Enter New IP"),
                TextField(
                  onChanged: (value) {
                    newIP = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Change'),
              onPressed: () {
                changeHostConfToSP('hostIP', newIP);
                ip = newIP;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  //Function to Create Help dialog Box
  Future helpDialog() async {

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("1) Open Side Drawer to see History and to see output of any command in history Click on it\n"),
                Text("2) Default IP is 127.0.0.1, to change the IP of Linux Host Press button behind help\n"),
                Text("3) Not Liking Light Theme, Turn on dark Mode in you mobile"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: SafeArea(child: HistoryDrawer()),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('Linux Command', style: TextStyle(color: Colors.amber),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.laptop_mac, color: Colors.greenAccent,), 
            onPressed: ipDialog, 
            splashColor: Colors.red,
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.redAccent,), 
            onPressed: helpDialog,
            splashColor: Colors.green,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: deviceWidth,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 2, color: Colors.teal),
                    left: BorderSide(width: 2, color: Colors.teal),
                    right: BorderSide(width: 2, color: Colors.teal),
                    bottom: BorderSide(width: 2, color: Colors.teal),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        prefixIconConstraints: BoxConstraints(),
                        hintText: "Enter Command",
                        prefixIcon: Icon(Icons.arrow_forward_ios),
                      ),
                      maxLines: 1,
                      enableSuggestions: true,
                      onChanged: (value) {
                        command = value;
                      },
                    ),
                    RaisedButton(
                      splashColor: Colors.green,
                      child: Text('Store Output'),
                      onPressed: () async {
                        await storeOutput();
                        fsconnect.collection("LinuxCommands").add({
                          'id' : id,
                          'command': command,
                          'status': status,
                          'output': output,
                        });
                      },
                    ),
                  ],
                ),
              ),

              Container(
                width: deviceWidth,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 2, color: Colors.tealAccent),
                    left: BorderSide(width: 2, color: Colors.tealAccent),
                    right: BorderSide(width: 2, color: Colors.tealAccent),
                    bottom: BorderSide(width: 2, color: Colors.tealAccent),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      splashColor: Colors.lightGreenAccent,
                      child: Text('Retrive Output'),
                      onPressed: () {
                        retriveOutput();
                        print(showHere);
                      },
                    ),
                    Text("${showHere ?? " "}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
