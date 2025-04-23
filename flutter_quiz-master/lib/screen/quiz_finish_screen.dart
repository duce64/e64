import 'package:flutter/material.dart';
import 'package:flutterquiz/model/question.dart';
import 'package:flutterquiz/provider/score_provider.dart';
import 'package:flutterquiz/screen/dashboard.dart';
import 'package:flutterquiz/screen/show_question_screen.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:flutterquiz/widget/button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class QuizFinishPage extends StatefulWidget {
  final String? title;
  final Map<int, dynamic>? answer;
  final List<Question>? listQuestion;

  const QuizFinishPage({Key? key, this.title, this.answer, this.listQuestion})
      : super(key: key);

  @override
  _QuizFinishPageState createState() => _QuizFinishPageState();
}

class _QuizFinishPageState extends State<QuizFinishPage> {
  int correct = 0;
  int incorrect = 0;
  int score = 0;
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.answer?.forEach((key, value) {
      if (widget.listQuestion?[key].correctAnswer == value) {
        correct++;
        score += 10;
      } else {
        incorrect++;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/congratulate.png', width: 200),
                    const SizedBox(height: 24),
                    Text(
                      "Your Score: $score",
                      style: kHeadingTextStyleAppBar.copyWith(
                          fontSize: 26, color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "You have successfully completed",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title ?? '',
                      style: kHeadingTextStyleAppBar.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildStatChip(
                            Icons.check, "$correct correct", Colors.green),
                        _buildStatChip(
                            Icons.close, "$incorrect incorrect", Colors.red),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Button(
                            title: 'Show Question',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShowQuestionScreen(
                                    answer: widget.answer ?? {},
                                    listQuestion: widget.listQuestion ?? [],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Button(
                            title: 'Save Score',
                            onTap: _buildDialogSaveScore,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Button(
                            title: 'Home',
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DashboardPage()),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Chip(
      elevation: 4,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _buildDialogSaveScore() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Save Score',
                  style: kHeadingTextStyleAppBar.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Your Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text("Your Score: ", style: TextStyle(fontSize: 16)),
                    Text(
                      "$score",
                      style: kHeadingTextStyleAppBar.copyWith(
                          fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveScore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kItemSelectBottomNav,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Save",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveScore() async {
    final now = DateTime.now();
    String datetime = DateFormat.yMd().format(now);
    await Provider.of<ScoreProvider>(context, listen: false).addScore(
      nameController.text,
      widget.title ?? '',
      score,
      datetime,
      correct,
      widget.listQuestion!.length,
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => DashboardPage()),
      (route) => false,
    );
  }
}
