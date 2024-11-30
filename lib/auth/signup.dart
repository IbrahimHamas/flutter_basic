import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/alert.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var myusername, myemail, mypassword;
  GlobalKey<FormState> formstate = new GlobalKey<FormState>();

  signUp() async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      formdata.save();
      try {
        showLoading(context);
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: myemail,
          password: mypassword,
        );
        return credential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
              context: context,
              title: "Error",
              body: Text("password is too weak"))
            ..show();
        } else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();
          AwesomeDialog(
              context: context,
              title: "Error",
              body: Text("The account already exists for that email"))
            ..show();
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("Not valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        SizedBox(
          height: 100,
        ),
        Center(
          child: Image.asset("images/1.jpeg"),
        ),
        Container(
            padding: EdgeInsets.all(10),
            child: Form(
                key: formstate,
                child: Column(
                  children: [
                    TextFormField(
                      onSaved: (val) {
                        myusername = val;
                      },
                      validator: (val) {
                        if (val!.length > 100) {
                          return "username can't be larger than 100";
                        }
                        if (val.length < 2) {
                          return "username can't be smaller than 2";
                        }
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          hintText: "username",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onSaved: (val) {
                        myemail = val;
                      },
                      validator: (val) {
                        if (val!.length > 100) {
                          return "e-mail can't be larger than 100";
                        }
                        if (val.length < 2) {
                          return "e-mail can't be less than 2";
                        }
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: "e-mail",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onSaved: (val) {
                        mypassword = val;
                      },
                      validator: (val) {
                        if (val!.length > 100) {
                          return "password can't be larger than 100";
                        }
                        if (val.length < 4) {
                          return "password can't be less than 4";
                        }
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          hintText: "password",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1))),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text('If you have account ?'),
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed("login");
                            },
                            child: Text(
                              "Click Here",
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () async {
                            var response = await signUp();
                            print("================");
                            if (response != null) {
                              await FirebaseFirestore.instance.collection('players').add({
                                'username': myusername,
                                'email': myemail
                              }) ;
                              Navigator.of(context).pushNamed("homepage");
                            } else {
                              print("sign up failed");
                            }
                          },
                          child: Text("Sign Up ")),
                    )
                  ],
                )))
      ],
    ));
  }
}
