import 'package:flutter/material.dart';
import 'package:intermission_project/common/const/tabs.dart';
import 'package:intermission_project/common/const/colors.dart';
import 'package:intermission_project/views/home/home_appbar.dart';
import 'package:intermission_project/user/interview_collection_screen.dart';
import 'package:intermission_project/views/login/login_screen.dart';
import 'package:intermission_project/user/matching_screen.dart';
import 'package:intermission_project/views/home/home_main_screen.dart';

class TabBarController extends StatefulWidget {
  @override
  _TabBarControllerState createState() => _TabBarControllerState();
}

class _TabBarControllerState extends State<TabBarController>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 2; // Set the initial selected tab index to 2 (the "홈" tab)
  int pointNumber = 1000;

  @override
  void initState() {
    _tabController = TabController(
      length: tabItems.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(tabListener);
    super.initState();
  }

  //tap 위치도 스크린 따라가게끔
  void tabListener() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void navigateToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(pointNumber: pointNumber),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // Disable swiping between tabs
        children: <Widget>[
          TabContentWidget(label: '쇼핑몰'),
          MatchingScreen(),
          HomeScreen(tabController: _tabController),
          InterviewCollectionScreen(),
          LoginScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 4) {
            navigateToLoginScreen();
          } else {
            setState(() {
              _currentIndex = index;
              _tabController.animateTo(index);
            });
          }
        },
        unselectedItemColor: Colors.grey[600], // Set unselected item color
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        items: tabItems.map((tab) {
          return BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == tabItems.indexOf(tab)
                  ? tab.selectedPath ?? tab.iconPath
                  : tab.iconPath,
              width: 24,
              height: 24,
            ),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

class TabContentWidget extends StatelessWidget {
  final String label;

  const TabContentWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    // Replace this with the content you want to display for each tab
    return Center(
      child: Text(label),
    );
  }
}
