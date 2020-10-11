//Importing Modules
import 'package:LinuxCmnd/pages/home.dart';
import 'package:LinuxCmnd/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


//Main Function
main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(LinuxCmndApp());
}

//LinuxCmndApp Class
class LinuxCmndApp extends StatefulWidget {
  @override
  _LinuxCmndAppState createState() => _LinuxCmndAppState();
}

class _LinuxCmndAppState extends State<LinuxCmndApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
        routes: {
          "/": (context) => LinuxAppLogin(),
          "/home": (context) => LinuxAppHome(),
        },
    );
  }
}
