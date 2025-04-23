import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutterquiz/util/constant.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _titleController = TextEditingController();
  File? _imageFile;
  String? _base64Image;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _submitCategory() async {
    final title = _titleController.text;

    if (title.isEmpty || _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.52.91:3000/api/categories/add');
    final body = {
      'name': title,
      'image': _base64Image,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm category thành công')),
        );
        Navigator.pop(context); // quay lại sau khi thêm
      } else {
        print(response.body);
        throw Exception('Lỗi server');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm thất bại')),
      );
    }
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
          "Thêm danh mục",
          style: TextStyle(
            color: kItemSelectBottomNav,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "THÊM DANH MỤC",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tên danh mục',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: _base64Image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.memory(
                              Uint8List.fromList(base64Decode(_base64Image!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Center(
                            child:
                                Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      backgroundColor: kItemSelectBottomNav,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Thêm danh mục",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _submitCategory,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
