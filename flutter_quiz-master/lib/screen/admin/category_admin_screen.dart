import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterquiz/model/categories.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:flutterquiz/util/router_path.dart';
import 'package:http/http.dart' as http;

class ManageCategoryScreen extends StatefulWidget {
  const ManageCategoryScreen({Key? key}) : super(key: key);

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.52.91:3000/api/categories'),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          _categories = data.map((e) => Category.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Lỗi khi tải category: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá danh mục này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.delete(
        Uri.parse('http://192.168.52.91:3000/api/categories/$id'),
      );

      if (response.statusCode == 200) {
        _loadCategories();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xoá danh mục")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xoá thất bại")),
        );
      }
    }
  }

  void _navigateToEdit(Category category) {
    Navigator.pushNamed(
      context,
      EditCategoryScreens,
      arguments: category,
    ).then((_) => _loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F1FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: kItemSelectBottomNav),
        title: Text(
          "Quản lý danh mục",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kItemSelectBottomNav,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundImage:
                          MemoryImage(base64Decode(category.image)),
                      radius: 24,
                      backgroundColor: kItemSelectBottomNav.withOpacity(0.1),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _navigateToEdit(category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddCategoryScreens).then((_) {
            _loadCategories();
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
