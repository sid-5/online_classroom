import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_classroom/Pages/TestsPage.dart';
import 'package:online_classroom/Services/AuthServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({Key? key}) : super(key: key);

  @override
  _AssignmentsPageState createState() => _AssignmentsPageState();
}





class _AssignmentsPageState extends State<AssignmentsPage> {
  String? pos;
  List<Map<String, dynamic>> list = [];

  submitAssignment(String topic, String name) async{
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null) {
        File fileBytes = File(result.files.first.path!);
        String fileName = result.files.first.name;
        Reference ref =
        FirebaseStorage.instance.ref().child('Assignments/').child('$topic/').child(('uploads/$fileName'));
        print(fileBytes);
        UploadTask uploadTask = ref.putFile(
            fileBytes);

        TaskSnapshot snapshot = await uploadTask;

        String url = await snapshot.ref.getDownloadURL();

        print("url:$url");
        var databaseRef = FirebaseDatabase.instance
            .reference()
            .child("Topic")
            .child(topic).child(name); //database reference object
        await databaseRef.set({
          'Topic': url,
        });
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  uploadAssignmentTeacher(String topic, String topicName) async{
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null) {
        File fileBytes = File(result.files.first.path!);
        String fileName = result.files.first.name;
        Reference ref =
        FirebaseStorage.instance.ref().child('Assignments/').child('Questions/').child('$topicName/').child('$topic/').child(('uploads/$fileName'));
        print(fileBytes);
        UploadTask uploadTask = ref.putFile(
            fileBytes);
        Fluttertoast.showToast(msg: "Uploading");
        TaskSnapshot snapshot = await uploadTask;

        String url = await snapshot.ref.getDownloadURL();
        print("url:$url");
        var databaseRef = FirebaseDatabase.instance
            .reference()
            .child("Topics")
            .child(topicName)
            .child(topic); //database reference object
        await databaseRef.set({
          'Topic': url,
        });
        print("done");
        Fluttertoast.showToast(msg: "Done uploading");
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  getinfo() async{
    pos = await getPosition(context);
    await getAllAssignments();
    return pos;
  }

  Future<List<Map<String, dynamic>>?> getAllAssignments() async {
    try{
      List<Map<String, dynamic>> files = [];
      final ListResult result =
      await FirebaseStorage.instance.ref().child('Assignments/').child('Questions/').child('/uploads').list();
      final List<Reference> allFiles = result.items;
      print(allFiles);
      await Future.forEach<Reference>(allFiles, (file) async {
        final String fileUrl = await file.getDownloadURL();
        final FullMetadata fileMeta = await file.getMetadata();
        files.add({"url": fileUrl, "name": fileMeta.name});
      });
      print(files);
      list = files;
      return files;
    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    getinfo();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Assignments",style: TextStyle(color: Theme.of(context).primaryColorLight,fontSize: 25),),
          ),
          FutureBuilder(
              future: getinfo(),
              builder: (context, AsyncSnapshot snap){
            if(snap.connectionState == ConnectionState.done &&snap.hasData){
              return pos =="student"?ListView.builder(
                shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, int item){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColorLight,
                    ),
                    child:
                    TextButton(
                      child: Text(list[item].values.elementAt(1),style: TextStyle(decoration: TextDecoration.underline),),
                      onPressed: () {
                        launch(list[item].values.elementAt(0));
                      }
                    ),),
                );
              }):
              ListView.builder(
                  shrinkWrap: true,itemBuilder: (context, int item){
                return Container(height: 20,color: Colors.red,);
              });
            }
            return Center(child: CircularProgressIndicator());
          }),
        ],
      ),
    );

  }
}
