import 'dart:convert';
import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF1976D2);
const kLightBackground = Color(0xFFE9F1FB);
const kCardBackground = Colors.white;
const kTitleColor = Color(0xFF002856);

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({Key? key}) : super(key: key);

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFakeData();
  }

  void _loadFakeData() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _results = [
          {
            'name': 'Nguyễn Văn A',
            'score': 85,
            'date': '2024-06-10',
            'status': 'Passed',
          },
          {
            'name': 'Trần Thị B',
            'score': 72,
            'date': '2024-06-09',
            'status': 'Pending',
          },
          {
            'name': 'Lê Văn C',
            'score': 48,
            'date': '2024-06-08',
            'status': 'Failed',
          },
          {
            'name': 'Phạm Thị D',
            'score': 90,
            'date': '2024-06-07',
            'status': 'Passed',
          },
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: kTitleColor),
        title: const Text(
          "📋 Kết quả thi",
          style: TextStyle(
            color: kTitleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: kPrimaryColor.withOpacity(0.1),
                        child: Text(item['name'][0].toUpperCase(),
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kTitleColor),
                            ),
                            const SizedBox(height: 4),
                            Text("Điểm: ${item['score']} / 100",
                                style: TextStyle(color: Colors.grey[700])),
                            Text("Ngày thi: ${item['date']}",
                                style: TextStyle(color: Colors.grey[600]))
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(item['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['status'],
                          style: TextStyle(
                            color: _statusColor(item['status']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
