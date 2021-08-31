import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_classroom/Models/UsersModel.dart';
import 'package:online_classroom/Pages/HomePage.dart';
import 'package:online_classroom/Pages/MainPanel.dart';
import 'package:online_classroom/Services/AuthServices.dart';
import 'package:online_classroom/notifiers/Auth.dart';
import 'package:provider/provider.dart';

import 'SigninPage.dart';

class InputController {
  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  InputController();
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  InputController inputController = InputController();
  Users _user = Users();
  bool isobscure = true;
  bool _teacherActive = false;
  bool _studentActive = true;
  bool student = false;
  bool _isLoading = false;

  forSignin() async {
    _user.email = inputController.email.text;
    _user.password = inputController.password.text;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    await login(_user, authNotifier);
    getPosition(context);
  }


  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier);
    /*if(authNotifier.user!=null){
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) => List_Page()));
    }*/
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
                        'Log in to your account',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 20,),
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
                        padding: const EdgeInsets.only(top:20.0),
                        child: GestureDetector(
                          onTap: ()async{
                            if(inputController.password.text!="" &&inputController.email.text!=""){
                              try{
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await forSignin();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UserPanel()));
                                  }catch(e){
                                print(e);
                                setState(() {
                                  _isLoading = false;
                                });
                                }}else{
                              Fluttertoast.showToast(msg: "Please enter app details first");
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).backgroundColor
                            ),
                            child: _isLoading?Center(child: CircularProgressIndicator(),):Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text('Sign in', style: TextStyle(color: Theme.of(context).primaryColorLight),
                          ),
                              ),
                            ),
                        )
                      )),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w300),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SignUpScreen()));
                                },
                                child: Text(
                                  "Sign up",
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
