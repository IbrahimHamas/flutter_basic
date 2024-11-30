import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  addData() async {
    CollectionReference doc = FirebaseFirestore.instance
        .collection("users")
        .doc("12345")
        .collection("address");
    doc.doc("YINRcHLuV9eqAsjzieTL").update({"username": "lewa"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: MaterialButton(
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: () async {
            addData();
          },
          child: Text("AddData"),
        ),
      ),
    );
  }
}
