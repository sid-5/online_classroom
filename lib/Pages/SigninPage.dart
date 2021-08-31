import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_classroom/Models/UsersModel.dart';
import 'package:online_classroom/Services/AuthServices.dart';
import 'package:online_classroom/notifiers/Auth.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'MainPanel.dart';

class InputController {
  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  InputController();
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  InputController inputController = InputController();
  Users _user = Users();
  bool vis = false;
  bool loading = false;
  bool isobscure = true;
  bool _teacherActive = false;
  bool _studentActive = true;
  bool student = false;
  bool _isLoading = false;

  forSignin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  forSignup() async {
    _user.displayName = inputController.name.text;
    _user.email = inputController.email.text;
    _user.password = inputController.password.text;
    print(_user.email! + _user.password!);
    try {
      if (_user.displayName == "")
        throw "[firebase_auth/unknown] Given String is empty or null";
      if (_user.password!.length > 32)
        throw "Password should be within 32 characters";
      vis = true;
      setState(() {});
      AuthNotifier authNotifier =
          Provider.of<AuthNotifier>(context, listen: false);
      await signup(context, _user, authNotifier,_studentActive?"student":"teacher", inputController.name.text);
      setState(() {
        vis = false;
      }
          );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserPanel()));
    } catch (e) {
      AuthNotifier authNotifier =
      Provider.of<AuthNotifier>(context, listen: false);
      signout(authNotifier);
      print("error is $e");
      switch (e.toString()) {
        case "[firebase_auth/unknown] Given String is empty or null":
          Fluttertoast.showToast(
              msg: "Please provide credentials",
              timeInSecForIosWeb: 3,
              fontSize: 16,
              backgroundColor: Colors.redAccent.shade100,
              textColor: Colors.black);
          break;
        case "[firebase_auth/invalid-email] The email address is badly formatted.":
          Fluttertoast.showToast(
              msg: "Please provide a valid email address",
              timeInSecForIosWeb: 3,
              fontSize: 16,
              backgroundColor: Colors.redAccent.shade100,
              textColor: Colors.black);
          break;
        case "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.":
          Fluttertoast.showToast(
              msg: "This email is not registered",
              timeInSecForIosWeb: 5,
              fontSize: 16,
              backgroundColor: Colors.redAccent.shade100,
              textColor: Colors.black);
          break;
        case "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.":
          Fluttertoast.showToast(
              msg: "Wrong password\nTry forgot password? to reset",
              timeInSecForIosWeb: 3,
              fontSize: 16,
              backgroundColor: Colors.redAccent.shade100,
              textColor: Colors.black);
          break;
        case "[firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later.":
          Fluttertoast.showToast(
              msg: "Too many attempts\nPlease come back later",
              timeInSecForIosWeb: 3,
              fontSize: 16,
              backgroundColor: Colors.redAccent.shade100,
              textColor: Colors.black);
          break;
        default:
          Fluttertoast.showToast(
              msg: e.toString(),
              timeInSecForIosWeb: 3,
              fontSize: 16,
              backgroundColor: Colors.redAccent.shade100,
              textColor: Colors.black);
          break;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).primaryColorLight,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 10),
                        child: Text(
                          'Welcome',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Create a new account',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              _studentActive = !_studentActive;
                              _teacherActive = false;
                              setState(() {});
                            },
                            child: Container(
                              width: size.width * 0.225,
                              padding: EdgeInsets.all(10),
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    topLeft: Radius.circular(10)),
                                gradient: _studentActive
                                    ? LinearGradient(
                                        colors: [
                                          Colors.pinkAccent,
                                          Colors.deepOrangeAccent
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        stops: [0, 8],
                                      )
                                    : LinearGradient(colors: [
                                        Theme.of(context).backgroundColor,
                                        Theme.of(context).backgroundColor
                                      ]),
                              ),
                              child: Center(
                                  child: Text(
                                'Student',
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              _teacherActive = !_teacherActive;
                              _studentActive = false;
                              setState(() {});
                            },
                            child: Container(
                              width: size.width * 0.225,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                gradient: _teacherActive
                                    ? LinearGradient(
                                        colors: [
                                          Colors.pinkAccent,
                                          Colors.deepOrangeAccent
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        stops: [0, 8],
                                      )
                                    : LinearGradient(colors: [
                                        Theme.of(context).backgroundColor,
                                        Theme.of(context).backgroundColor
                                      ]),
                              ),
                              child: Center(
                                  child: Text(
                                'Teacher',
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 30, left: 30, right: 30),
                          child: TextField(
                            controller: inputController.name,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(
                                Icons.mail,
                                color: Colors.black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color(0xff07FEC9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 30, left: 30, right: 30),
                          child: TextField(
                            controller: inputController.email,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(
                                Icons.mail,
                                color: Colors.black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color(0xff07FEC9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 30, left: 30, right: 30),
                          child: TextField(
                            controller: inputController.password,
                            obscureText: isobscure,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(
                                Icons.vpn_key,
                                color: Colors.black,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() {
                                  isobscure = !isobscure;
                                }),
                                child: Icon(
                                  isobscure
                                      ? Icons.remove_red_eye_outlined
                                      : Icons.remove_red_eye,
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color(0xff07FEC9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: GestureDetector(
                              onTap: () async {
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await forSignup();
                                } catch (e) {
                                  print(e);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).backgroundColor),
                                child: _isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(
                                            'Sign up',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight),
                                          ),
                                        ),
                                      ),
                              ))),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w300),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SignInScreen()));
                                },
                                child: Text(
                                  "Log in",
                                  style: TextStyle(),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
