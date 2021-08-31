import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_classroom/Pages/MainPanel.dart';
import 'package:online_classroom/Services/AuthServices.dart';
import 'package:provider/provider.dart';

import 'Pages/HomePage.dart';
import 'Pages/LoginPage.dart';
import 'notifiers/Auth.dart';
import 'notifiers/Tabs.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AuthNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => UserTab(),
      ),
    ],
    child: MyApp(),));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF1F4287),
        primaryColorLight: Color(0xFF21E6C1),
        accentColor: Color(0xFF278EA5),
        backgroundColor: Color(0xFF071E3D),

      ),
      home: Consumer<AuthNotifier>(
      builder: (context, notifier, child) {
    print("User is ${notifier.user} in Main name is ${notifier.name}");
    return (notifier.user != null)?UserPanel():SignInScreen();
      },
      ),
    );
  }
}

