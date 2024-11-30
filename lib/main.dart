import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_basic/auth/login.dart';
import 'package:flutter_basic/auth/signup.dart';
import 'package:flutter_basic/crud/addnotes.dart';
import 'package:flutter_basic/home/homepage.dart';
import 'package:flutter_basic/test.dart';

bool? islogin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    islogin = false;
  } else {
    islogin = true;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: islogin == false ? Login() : Homepage(),
      routes: {
        "login": (context) => Login(),
        "signup": (context) => Signup(),
        "homepage": (context) => Homepage(),
        "addnotes": (context) => AddNotes()
      },
    );
  }
}
