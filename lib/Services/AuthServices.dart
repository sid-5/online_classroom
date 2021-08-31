import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_classroom/Models/UsersModel.dart';
import 'package:online_classroom/Pages/MainPanel.dart';
import 'package:online_classroom/notifiers/Auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

login(Users user, AuthNotifier authNotifier) async {
  UserCredential authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email!, password: user.password!)
      .timeout(Duration(seconds: 10));
  if (authResult != null) {
    User? firebaseUser = authResult.user;

    if (firebaseUser != null) {
      print("Log In: $firebaseUser");
      authNotifier.setUser(firebaseUser);
    }
  }
}

signup(BuildContext context, Users user, AuthNotifier authNotifier,String position, String name) async {
  print("called sign up ${user.email}  ${user.password}");
    UserCredential authResult = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: user.email!, password: user.password!)
        .timeout(Duration(seconds: 10));
    print(authResult);
    if (authResult != null) {
      User? firebaseUser = authResult.user;

      print("Sign up: $firebaseUser");

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        print("Log In: $firebaseUser");
        authNotifier.setUser(firebaseUser);
        await setRecord(context, name, position);
      }
    }
}

signout(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance.signOut().catchError((error) => print(error.code));
  authNotifier.setUser(null);
  authNotifier.setName(null);
}

initializeCurrentUser(AuthNotifier authNotifier) async {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser != null) {
    print("API sending: $firebaseUser");
    authNotifier.setUser(firebaseUser);
  }
  await authNotifier.callGoogle(true);
}

setRecord(BuildContext context, String name, String position) async{
  {
    print("setting name $name");
    AuthNotifier authnotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    var databaseRef = FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(authnotifier.user!.uid); //database reference object
    await databaseRef.set({
      'name': name,
      'position': position,
    });
    print("Name set");
    authnotifier.setName(name);
  }
}


Future<String> getPosition(BuildContext context) async{
  AuthNotifier authnotifier =
  Provider.of<AuthNotifier>(context, listen: false);
  var databaseRef = FirebaseDatabase.instance
      .reference()
      .child("Users")
      .child(authnotifier.user!.uid);
  var data =await  databaseRef.get();
  print("data is :${data.value.values}");
  print(data.value.values.elementAt(1));
  await setPosition(data.value.values.elementAt(1).toString());
  return data.value.values.elementAt(1).toString();
}

Future<String> getName(AuthNotifier authnotifier,BuildContext context) async{
  print(authnotifier.user!.uid);
  var databaseRef = await FirebaseDatabase.instance
      .reference()
      .child("Users")
      .child(authnotifier.user!.uid);
  var data =await databaseRef.get();
  print("ddd ${data.value.values.elementAt(0)}");
  await setPosition(data.value.values.elementAt(1).toString());
  SharedPreferences pr = await SharedPreferences.getInstance();
  await pr.setString("Name",data.value.values.elementAt(0).toString());
  return data.value.values.elementAt(0).toString();
}

setPosition(String pos) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("position", pos);
}

removePosition(String pos) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("position");
}

loginGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!
        .authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken
    );
    //Firebase Sign in
    UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
    print("google name: ${result.user!.displayName}");
    print("google phone: ${result.user!.phoneNumber}");
    print("google email: ${result.user!.email}");

    User? user = result.user;
    print(user!.email);
    print('${result.user!.displayName}');
  } catch (error) {
    print(error);
    Fluttertoast.showToast(msg: "An error occurred");
  }
}
