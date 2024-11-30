import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basic/crud/addnotes.dart';
import 'package:flutter_basic/crud/editnotes.dart';
import 'package:flutter_basic/crud/viewnotes.dart';
import 'package:flutter_basic/test.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  CollectionReference notesref =FirebaseFirestore.instance.collection('notes');
  /*List notes = [
    {
      "note": 'Lorem Ispum Lorem Ispum 1 Lorem Ispum Lorem Ispum ',
      "image": "1.jpg"
    },
    {
      "note": 'Lorem Ispum Lorem Ispum 2 Lorem Ispum Lorem Ispum ',
      "image": "1.jpg"
    },
    {
      "note": 'Lorem Ispum Lorem Ispum 3 Lorem Ispum Lorem Ispum ',
      "image": "1.jpg"
    }
  ];*/

  getUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email;
      print(email);
    }
  }

  var fbm =FirebaseMessaging.instance;

  @override
  void initState() {
    fbm.getToken().then((value){
      print('=================');
      print(value);
      print('====================');
    });
    getUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("HomePage"),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed("login");
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return AddNotes( );
          }));
        },
        child: Icon(Icons.add),
      ),
      body: Container(
          child:FutureBuilder(
              future:notesref.where('userid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
              builder:(context,snapshot){
if(snapshot.hasData){
  return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder:(context,i){
       return Dismissible(
           onDismissed:(val) async{
          await  notesref.doc(snapshot.data!.docs[i].id).delete();
          await FirebaseStorage.instance.refFromURL(snapshot.data!.docs[i]['imageurl']).delete().then((value){
            print('====================');
            print('Delete');
          });
           } ,
           key: UniqueKey(), child: ListNotes(notes: snapshot.data!.docs[i],docid: snapshot.data!.docs[i].id,));
      }


  );
}
        return Text('End');  })

      ),
    );
  }
}

class ListNotes extends StatelessWidget {
  final notes;
final docid;
  ListNotes({this.notes,this.docid});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap:(){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return ViewNotes(notes: notes,);
          }));
        } ,
        child: Card(
        child: Row(children: [
      Expanded(
          flex: 1,
          child: Image.network(
            "${notes['imageurl']}",
          )),
      Expanded(
        flex: 3,
        child: ListTile(
          title: Text("${notes['title']}"),
          subtitle:
             Text("${notes['note']}"),
          trailing: IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder:(context){
                return EditNotes(docid: docid,list: notes,);
              } ));
            },
            icon: Icon(Icons.edit),
          ),
        ),
      )
    ])));
  }
}
