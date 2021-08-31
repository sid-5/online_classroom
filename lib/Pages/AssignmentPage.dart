import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_classroom/Models/Assignment.dart';
import 'package:online_classroom/notifiers/Auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentPage extends StatefulWidget {
  final String? name;
  final String? topicName;
  final List<Assignment>? assignment;
  const AssignmentPage({Key? key, this.assignment, this.topicName, this.name}) : super(key: key);

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

uploadAssignment(String topic, String name, String topicName) async{
  try{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );

    if (result != null) {
      File fileBytes = File(result.files.first.path!);
      String fileName = result.files.first.name;
      Reference ref =
      FirebaseStorage.instance.ref().child('Assignments/').child('Submissions/').child('$topicName/').child('$topic/').child(('uploads/$fileName'));
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
          .child(topic).child("Submission").child(name); //database reference object
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

class _AssignmentPageState extends State<AssignmentPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_outlined, color: Theme.of(context).primaryColorLight,size: 30,)),
                  Text("Assignments:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Theme.of(context).primaryColorLight)),
                ],
              ),
            ),
            widget.assignment != null
                ? ListView.builder(
                    itemCount: widget.assignment!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child: ExpandableNotifier(
                            child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ScrollOnExpand(
                                      scrollOnExpand: true,
                                      scrollOnCollapse: false,
                                      child: ExpandablePanel(
                                        theme: const ExpandableThemeData(
                                          tapBodyToExpand: false,
                                          tapHeaderToExpand: false,
                                          headerAlignment:
                                              ExpandablePanelHeaderAlignment
                                                  .center,
                                          tapBodyToCollapse: true,
                                        ),
                                        header: Padding(
                                          padding: EdgeInsets.only(
                                              top: 15, left: 10),
                                          child: Text(
                                              widget.assignment![index]
                                                  .topicName!,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        collapsed: TextButton(
                                          onPressed: (){
                                            launch(widget.assignment![index].topicLink!);
                                          },
                                          child: Text(widget.assignment![index].topicLink!,style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context)
                                                  .primaryColorLight),
                                          ),),
                                        expanded: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Submission: ',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
                                            ),
                                            FlatButton(
                                                color: Theme.of(context)
                                                    .accentColor,
                                                onPressed: () async{
                                                  await uploadAssignment(widget.assignment![index]
                                                      .topicName!, widget.name!, widget.topicName!);
                                                },
                                                child: Container(
                                                  width: 100,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.upload_sharp),
                                                      Text(
                                                        "upload file",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w400),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                          ],
                                        ),
                                        builder: (_, collapsed, expanded) {
                                          return Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Expandable(
                                              collapsed: collapsed,
                                              expanded: expanded,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                      );
                    })
                : Text("No assignments"),
          ],
        ),
      ),
    );
  }
}
