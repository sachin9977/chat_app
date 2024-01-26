import 'package:chat_app/screens/AddFriend/add_friend.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/notification.dart';
import 'package:chat_app/screens/setting.dart';
import 'package:flutter/material.dart';

class BottomNavigationExample extends StatefulWidget {
  const BottomNavigationExample({Key? key}) : super(key: key);

  @override
  _BottomNavigationExampleState createState() =>
      _BottomNavigationExampleState();
}

class _BottomNavigationExampleState extends State {
  int _selectedTab = 0;

  List _pages = [
    HomeScreen(),
    AddFriend(),
    NotificationPage(),
    // ProfileScreen()
    SettingScreen()
  ];

  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        elevation: 20,
        backgroundColor: Color.fromARGB(179, 11, 2, 31),
        // landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        showUnselectedLabels: true,

        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "Chat",
              activeIcon: Icon(Icons.chat)),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_add_rounded),
              label: "Connection",
              activeIcon: Icon(Icons.group_add_rounded)),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Notification",
              activeIcon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_suggest),
              label: "Settings",
              activeIcon: Icon(Icons.settings_suggest_outlined)),
        ],
      ),
    );
  }
}
