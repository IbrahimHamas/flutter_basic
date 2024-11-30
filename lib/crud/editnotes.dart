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

class EditNotes extends StatefulWidget {
  final docid;
  final list;
  const EditNotes({super.key,this.docid,this.list});

  @override
  State<EditNotes> createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  CollectionReference notesref =FirebaseFirestore.instance.collection('notes');

  var title, note, imageurl;
  File? file;
  Reference? ref;

  GlobalKey<FormState> formstate = new GlobalKey<FormState>();

  editNotes(context) async {
    var formdata= formstate.currentState;
    if(file==null){
      if(formdata!.validate()){
        showLoading(context);
        formdata.save();
        await notesref.doc(widget.docid).update({
          'title':title,
          'note':note,
          'userid': FirebaseAuth.instance.currentUser!.uid
        }).then((value){
          Navigator.of(context).pushNamed('homepage');
        });

      }
    }else{
      if(formdata!.validate()){
        showLoading(context);
        formdata.save();
        await ref!.putFile(file!);
        imageurl=await ref!.getDownloadURL();
        await notesref.doc(widget.docid).update({
          'title':title,
          'note':note,
          'imageurl':imageurl,
          'userid': FirebaseAuth.instance.currentUser!.uid
        });
        Navigator.of(context).pushNamed('homepage');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Edit Notes"),
        ),
      ),
      body: Container(
          child: Column(children: [
            Form(
              key: formstate,
              child: Column(
                children: [
                  TextFormField(
                    initialValue:widget.list['title'],
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
                    initialValue:widget.list['note'],
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
                      child: Text("Edit Image for notes")),
                  MaterialButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: (() async{
                        await editNotes(context);
                      }),
                      child: Text("Edit  note"))
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