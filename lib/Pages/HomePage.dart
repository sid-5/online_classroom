import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_classroom/Models/Assignment.dart';
import 'package:online_classroom/Models/Topics.dart';
import 'package:online_classroom/Pages/AssignmentPage.dart';
import 'package:online_classroom/Pages/LoginPage.dart';
import 'package:online_classroom/Services/AuthServices.dart';
import 'package:online_classroom/notifiers/Auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  List<Topic> topics = [];
  String? name;
  List<String> topicName = [];


  Future getNameData() async{
    AuthNotifier authNotifier =
    Provider.of<AuthNotifier>(context, listen: false);
    if(authNotifier.user!=null){
      print("called");
      name = await getName(authNotifier, context);
    }

  }

  Future<List<Topic>> getTopics() async{
    try{
      print("workingg");
      await getNameData();
      var databaseRef = FirebaseDatabase.instance.reference().child("Topics");
      var data = await databaseRef.get();
      data.value.keys.forEach((val) {
        topicName.add(val.toString());
      });
      topicName.forEach((element) {
        List<Assignment> ll = [];
        int as = 0;
        print(element);
        for (int i = 0; i < data.value[element].keys.toList().length; i++) {
          as += 1;
          Assignment temp = Assignment(data.value[element][data.value[element].keys.toList()[i]]["Topic"],
              data.value[element].keys.toList()[i]);
          ll.add(temp);
        }
        Topic t = Topic(element, 0, as, ll);
        topics.add(t);
      });
      print(topics);
      return topics;
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: "error");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Theme.of(context).backgroundColor,
        actions: [GestureDetector(
          onTap: ()async {
            AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
            await signout(authNotifier);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
            setState(() {
            });
          },
          child: Container(
            height: 40,
            width: 80,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Center(child: Text("Sign Out",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).backgroundColor))),
          ),
        )],
      ),
      body: FutureBuilder(
        future: getTopics(),
        builder: (context, AsyncSnapshot snap){
          if(snap.connectionState == ConnectionState.done && snap.data.length!=0){
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF278EA5),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Class: 5",style: TextStyle(fontWeight: FontWeight.bold, fontSize:20,/* color: Theme.of(context).primaryColorLight*/)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 50,
                            child: Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("User: $name",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,/* color: Theme.of(context).primaryColorLight*/)),
                                Spacer(),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Topics:",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23, color: Theme.of(context).primaryColorLight)),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: topics.length,
                      shrinkWrap: true,
                      itemBuilder: (context,int index){
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> AssignmentPage(assignment: topics[index].assign,topicName: topics[index].title,name: name,)));
                          },
                          child: ExpandableNotifier(
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor
                                    ),
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
                                                headerAlignment: ExpandablePanelHeaderAlignment.center,
                                                tapBodyToCollapse: true,
                                              ),
                                              header: Padding(
                                                padding: EdgeInsets.only(top: 15, left: 10),
                                                child: Text(
                                                    topics[index].title!,
                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white)
                                                ),
                                              ),
                                              collapsed:Text(
                                                'Assignments: ${topics[index].assignments}',
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColorLight),
                                              ),
                                              expanded: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[

                                                  Text('Assignments: ${topics[index].assignments}',
                                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColorLight),
                                                  ),Text("Tests: ${topics[index].test}",
                                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColorLight),
                                                  )],
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
                      }),
                )

              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },

      ),
    ));
  }
}
