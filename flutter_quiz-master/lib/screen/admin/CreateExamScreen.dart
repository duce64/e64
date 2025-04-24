import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({Key? key}) : super(key: key);

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  List<dynamic> questionPackages = [];
  List<dynamic> users = [];
  bool isLoadingPackages = true;
  bool isLoadingUsers = false;

  int? selectedPackage;
  List<String> selectedUsers = [];
  String? selectedDepartment;

  final List<String> departments = [
    'Ban Tham Mưu',
    'Ban Chính Trị',
    'Ban HC-KT'
  ];

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    try {
      final res = await Dio().get('http://192.168.52.91:3000/api/questions');
      if (res.statusCode == 200) {
        setState(() {
          questionPackages = res.data;
          isLoadingPackages = false;
        });
      }
    } catch (e) {
      print("Lỗi khi load packages: $e");
    }
  }

  Future<void> fetchUsersByDepartment(String department) async {
    setState(() {
      isLoadingUsers = true;
    });
    try {
      final res = await Dio().get(
        'http://192.168.52.91:3000/by-department',
        queryParameters: {'department': department},
      );
      if (res.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(res.data);
          isLoadingUsers = false;
        });
      }
    } catch (e) {
      print('Lỗi load user: $e');
      setState(() {
        isLoadingUsers = false;
      });
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        deadlineController.text = picked.toIso8601String();
      });
    }
  }

  Future<void> createTest() async {
    if (titleController.text.isEmpty ||
        selectedPackage == null ||
        selectedUsers.isEmpty ||
        deadlineController.text.isEmpty ||
        selectedDepartment == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    String? creatorId;
    if (token != null) {
      final payload = base64Url.normalize(token.split('.')[1]);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      creatorId = decoded['userId'];
    }

    final data = {
      "title": titleController.text,
      "questionPackageId": selectedPackage,
      "selectedUsers": selectedUsers,
      "expiredDate": deadlineController.text,
      "department": selectedDepartment,
      "userId": creatorId,
    };
    print("Data: $data");
    try {
      final res = await Dio().post(
        'http://192.168.52.91:3000/api/exams/create',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo bài kiểm tra thành công')),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Tạo thất bại");
      }
    } catch (e) {
      print("Tạo kiểm tra thất bại: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo kiểm tra thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo bài kiểm tra"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề bài kiểm tra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              items: departments
                  .map((dep) => DropdownMenuItem(
                        value: dep,
                        child: Text(dep),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedDepartment = val;
                  selectedUsers.clear();
                });
                if (val != null) fetchUsersByDepartment(val);
              },
              decoration: const InputDecoration(
                labelText: 'Chọn ban',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            isLoadingUsers
                ? const CircularProgressIndicator()
                : MultiSelectDialogField(
                    items: users
                        .map((user) =>
                            MultiSelectItem(user['_id'], user['fullname']))
                        .toList(),
                    title: const Text("Người cần kiểm tra"),
                    buttonText: const Text("Chọn người cần kiểm tra"),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    listType: MultiSelectListType.LIST,
                    onConfirm: (values) {
                      setState(() {
                        selectedUsers =
                            values.map((e) => e.toString()).toList();
                      });
                    },
                    chipDisplay: MultiSelectChipDisplay.none(),
                  ),
            const SizedBox(height: 16),
            isLoadingPackages
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: selectedPackage,
                    items: questionPackages
                        .map((pkg) => DropdownMenuItem<int>(
                              value: pkg['idQuestion'],
                              child: Text(pkg['name']),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedPackage = val),
                    decoration: const InputDecoration(
                      labelText: 'Chọn gói câu hỏi',
                      border: OutlineInputBorder(),
                    ),
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              readOnly: true,
              onTap: () => selectDate(context),
              decoration: const InputDecoration(
                labelText: 'Hạn chót',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: createTest,
              icon: const Icon(Icons.send),
              label: const Text("Tạo bài kiểm tra"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
