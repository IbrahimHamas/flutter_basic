import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_basic/component/alert.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  CollectionReference notesref =FirebaseFirestore.instance.collection('notes');

  var title, note, imageurl;
  File? file;
  Reference? ref;

  GlobalKey<FormState> formstate = new GlobalKey<FormState>();

  addNotes(context) async {
    if(file==null) return AwesomeDialog(context: context,body: Text('please choose photo'),
dialogType: DialogType.error
    )..show();
var formdata= formstate.currentState;
if(formdata!.validate()){
  showLoading(context);
formdata.save();
await ref!.putFile(file!);
 imageurl=await ref!.getDownloadURL();
await notesref.add({
  'title':title,
  'note':note,
  'imageurl':imageurl,
  'userid': FirebaseAuth.instance.currentUser!.uid
});
Navigator.of(context).pushNamed('homepage');
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Add Notes"),
        ),
      ),
      body: Container(
          child: Column(children: [
        Form(
          key: formstate,
          child: Column(
            children: [
              TextFormField(
                validator: (val) {
                  if (val!.length > 30) {
                    return "title can't be larger than 30";
                  }
                  if (val.length < 2) {
                    return "title can't be less than 2";
                  }
                },
                onSaved: (val) {
                  title = val;
                },
                maxLength: 30,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Note Title",
                    prefixIcon: Icon(Icons.note)),
              ),
              TextFormField(
                validator: (val) {
                  if (val!.length > 255) {
                    return "note can't be larger than 255";
                  }
                  if (val.length < 10) {
                    return "note can't be less than 10";
                  }
                },
                onSaved: (val) {
                  note = val;
                },
                minLines: 1,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Note",
                    prefixIcon: Icon(Icons.note)),
              ),
              MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: (() {
                    showBottomSheet(context);
                  }),
                  child: Text("Add Image for notes")),
              MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: (() async{
                    await addNotes(context);
                  }),
                  child: Text("Add  note"))
            ],
          ),
        )
      ])),
    );
  }

  showBottomSheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: ((context) {
          return Container(
            padding: EdgeInsets.all(20),
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "please choose image",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () async{
                    var picked = await ImagePicker().pickImage(source: ImageSource.gallery);

                    if(picked !=null){
                      file=File(picked.path);
                      var ran =Random().nextInt(10000);
                      var imgname= '$ran' +basename(picked.path);
                       ref= FirebaseStorage.instance.ref('images').child('$imgname');
Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_outlined,
                          size: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'from galary',
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                   var picked = await ImagePicker().pickImage(source: ImageSource.camera);

                   if(picked !=null){
                     file=File(picked.path);
                     var ran =Random().nextInt(10000);
                     var imgname= '$ran' +basename(picked.path);
                      ref= FirebaseStorage.instance.ref('images').child('$imgname');
                     Navigator.of(context).pop();
                   }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera,
                          size: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'from camera',
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }
}

