import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthNotifier with ChangeNotifier {
  GoogleSignInAccount? _userObj;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  String? _name;

  User? get user => _user;

  GoogleSignInAccount? get userObj => _userObj;

  String? get name => _name;

  void setUser(User? user) {
    _user = user;
    print("user is $_user");
    notifyListeners();
  }

  void setName(String? name){
    _name = name;
    notifyListeners();
  }


  callGoogle(bool b) async {
    if (_googleSignIn.currentUser != null) {
      _userObj = _googleSignIn.currentUser!;
      return;
    }
    if (b) return;
    await _googleSignIn.signIn().then((userData) {
      _userObj = userData!;
    }).catchError((e) {
      print(e);
    });
    notifyListeners();
  }
}