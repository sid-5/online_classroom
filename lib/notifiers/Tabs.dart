import 'package:flutter/cupertino.dart';
import 'package:online_classroom/Pages/AssignmenstsPage.dart';
import 'package:online_classroom/Pages/CalenderPage.dart';
import 'package:online_classroom/Pages/HomePage.dart';
import 'package:online_classroom/Pages/TestsPage.dart';

class UserTab extends ChangeNotifier {
  int currentIndex = 1;

  List<Widget> pages = [
    CalenderPage(),
    HomePage(),
    AssignmentsPage(),
    TestPage()
  ];

  void setCurrentPage(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Widget currentPage(int index) {
    return pages[index];
  }
}