import 'package:flutter/material.dart';
import 'package:flutterquiz/animation/fade_animation.dart';
import 'package:flutterquiz/model/categories.dart';
import 'package:flutterquiz/provider/question_provider.dart';
import 'package:flutterquiz/screen/QuestionPackageListScreenH.dart';
import 'package:flutterquiz/screen/quiz_bottomsheet.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:flutterquiz/util/router_path.dart';
import 'package:flutterquiz/widget/card.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:convert' show base64Url, base64Decode;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String _userName = '';
  String _department = '';
  String _detail = '';

  @override
  void initState() {
    super.initState();
    _loadUserFromToken();
    _loadCategories();
    _loadNotifications();
    Provider.of<QuestionProvider>(context, listen: false).initValue();
  }

  Future<void> _loadUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = base64Url.normalize(parts[1]);
        final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));

        final exp = decoded['exp'];
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (exp != null && exp < now) {
          await _logoutExpired();
          return;
        }

        setState(() {
          _userName = decoded['fullname'] ?? '';
          _department = decoded['department'] ?? '';
          _detail = decoded['role'] ?? '';
        });
      }
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final payload = base64Url.normalize(token.split('.')[1]);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final userId = decoded['userId'] ?? '';

      final response = await http.get(
        Uri.parse('http://192.168.52.91:3000/api/notifications/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Lỗi khi tải thông báo: $e");
    }
  }

  Future<void> _logoutExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginScreen, (route) => false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen, (route) => false);
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://192.168.52.91:3000/api/categories'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  Future<void> _loadCategories() async {
    try {
      List<Category> fetched = await fetchCategories();
      setState(() {
        _categories = fetched;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải category: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStyledItem(Category category) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kItemSelectBottomNav.withOpacity(0.1),
            backgroundImage: MemoryImage(base64Decode(category.image)),
            radius: 28,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002856),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Mã danh mục: ${category.id}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[500])
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔔 Thông báo",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kItemSelectBottomNav,
              ),
            ),
            const Divider(height: 24),
            if (_notifications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Không có thông báo mới.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return InkWell(
                      onTap: () {
                        print("Clicked notification: ${notif['idCategory']}");
                        print("Clicked notification: ${notif['idQuestion']}");
                        Navigator.pushNamed(
                          context,
                          QuizScreenH,
                          arguments: {
                            'categoryId': notif['categoryId'],
                            'questionId': notif['questionId'],
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_none,
                                color: kItemSelectBottomNav),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notif['content'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif['date'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      color: Color(0xFFE9F1FB),
      child: Column(
        children: <Widget>[
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Xin chào, $_userName",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kItemSelectBottomNav,
                      ),
                    ),
                    Text(
                      "Phòng ban: $_department | Vai trò: $_detail",
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.blue),
                      tooltip: 'Thông báo',
                      onPressed: _showNotifications,
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.red),
                      tooltip: 'Đăng xuất',
                      onPressed: _logout,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: kItemSelectBottomNav,
                            strokeWidth: 3.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Đang tải dữ liệu...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: _categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuestionPackageListScreen(
                                categoryId: _categories[index].id,
                                categoryName: _categories[index].name,
                              ),
                            ),
                          );
                        },
                        child: _buildStyledItem(_categories[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    ));
  }

  _buildBottomSheet(BuildContext context, String title, int id) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        context: context,
        builder: (_) {
          return QuizBottomSheet(
            title: title,
            id: id,
          );
        });
  }
}
