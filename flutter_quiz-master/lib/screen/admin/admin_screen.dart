import 'package:flutter/material.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:flutterquiz/util/router_path.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFE9F1FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "📋 Trang quản trị",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTitleColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: kItemSelectBottomNav),
            onPressed: () {},
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: GridView.count(
              crossAxisCount: isWideScreen ? 3 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.2,
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
                  title: "Kết quả thi",
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.pushNamed(context, ResultExamScreens);
                  },
                ),
                _AdminMenuCard(
                  icon: Icons.people,
                  title: "Người dùng",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, ManageUserScreenss);
                  },
                ),
              ],
            ),
          ),
        ),
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
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: kTitleColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
