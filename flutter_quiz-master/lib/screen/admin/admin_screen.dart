import 'package:flutter/material.dart';
import 'package:flutterquiz/screen/admin/ExamResultScreen.dart';
import 'package:flutterquiz/screen/admin/question_admin_screen.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:flutterquiz/util/router_path.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9F1FB),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Trang quản lý",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kItemSelectBottomNav),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.notifications,
                    color: kItemSelectBottomNav,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _AdminMenuCard(
                  icon: Icons.category,
                  title: "Quản lý danh mục",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).pushNamed(CategoryManagerScreens);
                  },
                ),
                _AdminMenuCard(
                  icon: Icons.quiz,
                  title: "Quản lý câu hỏi",
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).pushNamed(ManageQuestionScreens);
                  },
                ),
                _AdminMenuCard(
                  icon: Icons.bar_chart,
                  title: "Xem kết quả thi",
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, ResultExamScreens);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _AdminMenuCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
