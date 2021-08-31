import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String? stat;
  int tab = 0;

  getStat() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    stat = pref.getString("position");
  }

  Future<String?> uploadAnswer() async {
    try {
      print("called upload answer");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null) {
        File fileBytes = File(result.files.first.path!);
        String fileName = result.files.first.name;
          Reference ref =
          FirebaseStorage.instance.ref().child('Answer/').child(('uploads/$fileName'));
          print(fileBytes);
          UploadTask uploadTask = ref.putFile(
              fileBytes);

          TaskSnapshot snapshot = await uploadTask;

          String url = await snapshot.ref.getDownloadURL();

          print("url:$url");
          return url;}

    } catch (e) {
      print(e);
      return null;
    }
  }


  Future<String?> uploadQuestion() async {
    try {
      print("called upload question");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null) {
        File fileBytes = File(result.files.first.path!);
        String fileName = result.files.first.name;
          Reference ref =
          FirebaseStorage.instance.ref().child('Paper/').child(('uploads/$fileName'));
          print(fileBytes);
          UploadTask uploadTask = ref.putFile(
              fileBytes);

          TaskSnapshot snapshot = await uploadTask;

          String url = await snapshot.ref.getDownloadURL();

          print("url:$url");
          return url;}
    } catch (e) {
      print(e);
      return null;
    }
  }


  Future<String?> uploadStudents() async {
    try {
      print("called upload Student");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
      );

      if (result != null) {
        File fileBytes = File(result.files.first.path!);
        String fileName = result.files.first.name;
          print("uploading");
          Reference ref = FirebaseStorage.instance.ref().child('Answers/').child(('uploads/$fileName'));
          print(ref);
          print(fileBytes);
          UploadTask uploadTask = ref.putFile(
              fileBytes);

          TaskSnapshot snapshot = await uploadTask;

          String url = await snapshot.ref.getDownloadURL();

          print("url:$url");
          return url;
        }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllTest() async {
    try{
      List<Map<String, dynamic>> files = [];

      final ListResult result =
          await FirebaseStorage.instance.ref().child('Paper/').child('/uploads').list();
      final List<Reference> allFiles = result.items;
      print(allFiles);
      await Future.forEach<Reference>(allFiles, (file) async {
        final String fileUrl = await file.getDownloadURL();
        final FullMetadata fileMeta = await file.getMetadata();
        files.add({"url": fileUrl, "name": fileMeta.name});
      });
      print(files);
      return files;
    }catch(e){
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllAnswers() async {
    try{
      List<Map<String, dynamic>> files = [];

      final ListResult result =
      await FirebaseStorage.instance.ref().child('Answers/').child('/uploads').list();
      final List<Reference> allFiles = result.items;
      print(allFiles);
      await Future.forEach<Reference>(allFiles, (file) async {
        final String fileUrl = await file.getDownloadURL();
        final FullMetadata fileMeta = await file.getMetadata();
        files.add({"url": fileUrl, "name": fileMeta.name});
      });
      print(files);
      return files;
    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    getStat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: DefaultTabController(
            length: 2,
            child: Container(
                child: Column(
                  children: [
                    Material(
                      color:  Theme.of(context).primaryColor,
                      elevation: 12,
                      child: Container(
                        width: size.width,
                        child: TabBar(onTap:(val){
                          setState(() {
                            tab = val;
                          });
                          print(tab);
                        },tabs: [
                          Tab(
                            child: Text(
                              "Tests",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Answers",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          child: TabBarView( physics: NeverScrollableScrollPhysics(),children: [
                            FutureBuilder(
                                future: getAllTest(),
                                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>?> snap){
                                  if(snap.connectionState == ConnectionState.done && snap.hasData){
                                    return ListView.builder(itemCount: snap.data!.length,itemBuilder: (context, int index){
                                      return Padding
                                        (
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: ()async{
                                              print("pressed url");
                                              print(snap.data![index]["url"]);
                                              await launch(snap.data![index]["url"]);
                                            },
                                            child: Container(
                                          height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: Theme.of(context).primaryColorLight,
                                              ),
                                            child: Center(child: Text(snap.data![index]["name"])),
                                        )),
                                      );
                                    });
                                  }
                              return Center(child: CircularProgressIndicator(),);
                            }),
                            FutureBuilder(
                                future: getAllAnswers(),
                                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>?> snap){
                                  if(snap.connectionState == ConnectionState.done && snap.hasData){
                                    return ListView.builder(itemCount: snap.data!.length,itemBuilder: (context, int index){
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: ()async{
                                              print("pressed url");
                                              print(snap.data![index]["url"]);
                                              await launch(snap.data![index]["url"]);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: Theme.of(context).primaryColorLight,
                                              ),
                                              height: 70,
                                              child: Center(child: Text(snap.data![index]["name"])),
                                            )),
                                      );
                                    });
                                  }
                                  return Center(child: CircularProgressIndicator(),);
                                })
                          ])),
                    )
                  ],
                ))),
      ),
      floatingActionButton:(tab == 0 || stat == "teacher")? FloatingActionButton.extended(

        label: Text(stat=="student"?"Submit answer for current test":(tab==0?"Upload test paper":"Upload answer sheet")),
        icon: Icon(Icons.add),
        onPressed: () async{
          String? got = stat=="student"?await uploadStudents():(tab==0?await uploadQuestion():await uploadAnswer());
          print(got??"couldn't upload");
          got!=null?Fluttertoast.showToast(msg: "Uploaded"):Fluttertoast.showToast(msg: "Couldn't Uploaded");
        },
      ):null,
    );
  }
}
