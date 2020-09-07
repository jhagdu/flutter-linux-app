//Importing Required Modules
import 'dart:convert';

import 'package:firebase_app/pages/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class LinuxAppLogin extends StatefulWidget {
  @override
  _LinuxAppLoginState createState() => _LinuxAppLoginState();
}

class _LinuxAppLoginState extends State<LinuxAppLogin> {

  var user;
  TextEditingController controllerOfIP;
  TextEditingController controllerOfUser;

  //Functions to get Host Configuration
  getHostConfFromSP(var key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(key);
    return value;
  }

  setHC () async {
    ip = await getHostConfFromSP('hostIP')  ?? "127.0.0.1";
    user = await getHostConfFromSP('User')  ?? "root";
    controllerOfIP = TextEditingController(text: "$ip");
    controllerOfUser = TextEditingController(text: "$user");
  }

  //Initial State of Login Page
  @override
  void initState() {
    setHC();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var passwd, hIP, uname, loginStatus, loginOutput;

    //Function to Login
    appLogin() async {
      var url = "http://$ip/cgi-bin/linuxlogin.py?username=$user&password=$passwd";
      print(url);
      var response = await http.get(url);
      var responseBody = jsonDecode(response.body);
      loginStatus = responseBody["status"];
      loginOutput = responseBody["output"];

      if (loginStatus == 0) {
        Navigator.pushReplacementNamed(context, "/home");
        Toast.show("Login Successfull\n\n$loginOutput", 
          context, 
          duration: Toast.LENGTH_LONG, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.green,
        );
      } else {
        Toast.show("Wrong Username or Password\n\n$loginOutput", 
          context, 
          duration: Toast.LENGTH_LONG, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    }

  //Function to Change Host Configuations
  setHostConfToSP(var key, val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, val);
  }


    //Getting Device Dimensions
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 30),
                    child: Container(
                      height: deviceHeight*0.64,
                      width: deviceWidth*0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border(
                          top: BorderSide(color: Colors.teal, width: 3),
                          right: BorderSide(color: Colors.teal, width: 3),
                          left: BorderSide(color: Colors.teal, width: 3),
                          bottom: BorderSide(color: Colors.teal, width: 3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                            child: Column(
                              children: <Widget>[
                                Card(
                                  elevation: 10,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: TextField(
                                      autofocus: false,
                                      controller: controllerOfIP,
                                      inputFormatters: [BlacklistingTextInputFormatter(RegExp("[ ]")),],
                                      decoration: InputDecoration(
                                        labelText: "Host IP",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red) 
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red) 
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if(value != ""){
                                            hIP = value;
                                        } else {
                                          hIP = ip;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Card(
                                  elevation: 10,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: TextField(
                                      autofocus: false,
                                      controller: controllerOfUser,
                                      decoration: InputDecoration(
                                        labelText: "Username",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red) 
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red) 
                                        ),
                                      ),
                                      onChanged: (value) {
                                        uname = value;
                                      },
                                    ),
                                  ),
                                ),
                                Card(
                                  elevation: 10,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: TextField(
                                      autofocus: true,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red)
                                        ),
                                      ),
                                      onChanged: (value) {
                                        passwd = value;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: RaisedButton(
                              splashColor: Colors.green,
                              child: Text("Login"),
                              onPressed: () {
                                ip = hIP ?? ip;
                                user = uname ?? user;
                                setHostConfToSP('hostIP', ip);
                                setHostConfToSP('User', uname);
                                appLogin();
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border(
                        top: BorderSide(color: Colors.teal, width: 3),
                        right: BorderSide(color: Colors.teal, width: 3),
                        left: BorderSide(color: Colors.teal, width: 3),
                        bottom: BorderSide(color: Colors.teal, width: 3),
                      )
                    ),
                    child: Text("Sign In",textScaleFactor: 3, style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}