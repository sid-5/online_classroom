import 'package:flutter/material.dart';
import 'package:online_classroom/notifiers/Tabs.dart';
import 'package:provider/provider.dart';


class UserPanel extends StatefulWidget {
  const UserPanel({Key? key}) : super(key: key);

  @override
  _UserPanelState createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: tabs,
        backgroundColor: Colors.black,
        currentIndex: Provider.of<UserTab>(context, listen: true).currentIndex,
        onTap: (val) {
          Provider.of<UserTab>(context, listen: false).setCurrentPage(val);
        },
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: Colors.blueAccent,
      ),
      body: Consumer<UserTab>(
        builder: (context, model, _) {
          return model.currentPage(model.currentIndex);
        },
      ),
    );
  }
}

List<BottomNavigationBarItem> tabs = [
  BottomNavigationBarItem(
    icon: Icon(
      Icons.calendar_today,
      color: Color(0xFF21E6C1),
    ),
    label: "Calender",
    activeIcon: Icon(
      Icons.calendar_today,
      color: Colors.blueAccent,
    ),
  ),
  BottomNavigationBarItem(
    icon: Icon(
      Icons.home_filled,
      color: Color(0xFF21E6C1),
    ),
    label: "Home",
    activeIcon: Icon(
      Icons.home_filled,
      color: Colors.blueAccent,
    ),
  ),
  BottomNavigationBarItem(
    icon: Icon(
      Icons.topic,
      color: Color(0xFF21E6C1),
    ),
    activeIcon: Icon(
      Icons.topic,
      color: Colors.blueAccent,
    ),
    label: "Assignments",
  ),
  BottomNavigationBarItem(
    icon: Icon(
      Icons.toc,
      color: Color(0xFF21E6C1),
    ),
    label: "Tests",
    activeIcon: Icon(
      Icons.toc,
      color: Colors.blueAccent,
    ),
  ),
];