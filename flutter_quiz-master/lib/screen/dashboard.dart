import 'package:flutter/material.dart';
import 'package:flutterquiz/screen/admin/admin_screen.dart';
import 'package:flutterquiz/screen/category_screen.dart';
import 'package:flutterquiz/screen/homes_screen.dart';
import 'package:flutterquiz/screen/scorescreen.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:convert' show base64Url, base64Decode;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  List<Widget> listScreen = [];
  List<BottomNavigationBarItem> navItems = [];
  bool isAdmin = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkRoleFromToken();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkRoleFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = base64Url.normalize(parts[1]);
        final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
        final role = decoded['role'] ?? '';

        setState(() {
          isAdmin = role == 'admin';
          listScreen = [
            HomeScreen(),
            if (isAdmin) AdminDashboardScreen(),
            ScoreScreen(),
          ];
          navItems = [
            _buildItemBottomNav(FontAwesomeIcons.home, "Trang chủ"),
            if (isAdmin) _buildItemBottomNav(FontAwesomeIcons.user, "Admin"),
            _buildItemBottomNav(FontAwesomeIcons.history, "Lịch sử kiểm tra"),
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: Offset(1, 0), // trượt từ phải vào
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: listScreen.isNotEmpty ? listScreen[currentIndex] : Container(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: kItemSelectBottomNav,
        elevation: 5.0,
        unselectedItemColor: kItemUnSelectBottomNav,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            _controller.forward(from: 0);
          });
        },
        items: navItems,
      ),
    );
  }

  BottomNavigationBarItem _buildItemBottomNav(IconData icon, String title) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: title,
    );
  }
}
