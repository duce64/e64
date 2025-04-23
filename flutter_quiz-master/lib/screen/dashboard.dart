import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterquiz/screen/ExamResultScreenUser.dart';
import 'package:flutterquiz/screen/admin/admin_screen.dart';
import 'package:flutterquiz/screen/category_screen.dart';
import 'package:flutterquiz/screen/homes_screen.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;
  bool isAdmin = false;
  List<Widget> screens = [];

  final List<String> menuTitles = [
    'Trang chủ',
    'Quản trị',
    'Lịch sử thi',
  ];

  final List<IconData> menuIcons = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.userGear,
    FontAwesomeIcons.clockRotateLeft,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = base64.normalize(parts[1]);
        final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
        final role = decoded['role'] ?? '';
        setState(() {
          isAdmin = role == 'admin';
          screens = [
            HomeScreen(),
            if (isAdmin) const AdminDashboardScreen(),
            const UserExamResultScreen(),
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            selectedIconTheme: IconThemeData(color: kItemSelectBottomNav),
            selectedLabelTextStyle: TextStyle(
              color: kItemSelectBottomNav,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
            destinations: [
              NavigationRailDestination(
                icon: Icon(menuIcons[0]),
                label: Text(menuTitles[0]),
              ),
              if (isAdmin)
                NavigationRailDestination(
                  icon: Icon(menuIcons[1]),
                  label: Text(menuTitles[1]),
                ),
              NavigationRailDestination(
                icon: Icon(menuIcons[2]),
                label: Text(menuTitles[2]),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Content
          Expanded(
            child: screens.isNotEmpty
                ? screens[currentIndex]
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
