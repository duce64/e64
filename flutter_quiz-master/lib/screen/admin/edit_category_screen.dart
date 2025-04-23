import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutterquiz/model/categories.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _titleController;
  File? _imageFile;
  String? _base64Image;
  bool _isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.category.name);
    _base64Image = widget.category.image;
  }

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

  Future<void> _updateCategory() async {
    final title = _titleController.text;

    if (title.isEmpty || _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'http://192.168.52.91:3000/api/categories/${widget.category.id}');
    final body = {
      'name': title,
      'image': _base64Image,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thành công')),
        );
        Navigator.pop(context);
      } else {
        print(response.body);
        throw Exception('Lỗi server');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF002856)),
        title: Text(
          'Sửa Danh Mục',
          style: TextStyle(
            color: Color(0xFF002856),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFE9F1FB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tên danh mục',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: _base64Image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.memory(
                                    Uint8List.fromList(
                                        base64Decode(_base64Image!)),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Center(
                                  child: Text('Nhấn để chọn ảnh'),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _updateCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF002856),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'LƯU THAY ĐỔI',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
