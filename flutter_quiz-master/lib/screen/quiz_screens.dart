import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/model/question.dart';
import 'package:flutterquiz/util/constant.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutterquiz/widget/snackbar.dart';
import 'package:flutterquiz/screen/quiz_finish_screen.dart';
import 'package:flutterquiz/widget/awesomedialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPageApi extends StatefulWidget {
  final int categoryId;
  final int questionId;
  final bool isTest;
  final String idTest;
  const QuizPageApi({
    Key? key,
    required this.categoryId,
    required this.questionId,
    required this.isTest,
    required this.idTest,
  }) : super(key: key);

  @override
  State<QuizPageApi> createState() => _QuizPageApiState();
}

class _QuizPageApiState extends State<QuizPageApi> {
  List<Question> listQuestion = [];
  bool isLoading = true;
  String error = '';
  int currentIndex = 0;
  Map<int, dynamic> answer = {};
  Map<int, List<String>> shuffledOptions = {};
  final unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final dio = Dio();
    final url =
        "http://192.168.52.91:3000/api/questions/package/${widget.questionId}";

    try {
      setState(() => isLoading = true);
      final res = await dio.get(url);

      if (res.statusCode == 200) {
        final List<dynamic> results = res.data['result'];
        listQuestion = results.map((e) => Question.fromJson(e)).toList();

        for (int i = 0; i < listQuestion.length; i++) {
          final q = listQuestion[i];
          final List<String> options = [
            ...(q.incorrectAnswers ?? []),
            q.correctAnswer ?? ''
          ];
          options.shuffle();
          shuffledOptions[i] = options;
        }

        setState(() => isLoading = false);
      } else {
        setState(() {
          error = 'Failed to load questions';
          isLoading = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        error = 'Something went wrong!';
        isLoading = false;
      });
      print(e.message);
    }
  }

  void selectAnswer(dynamic value) {
    setState(() {
      answer[currentIndex] = value;
    });
  }

  void nextOrSubmit() async {
    if (answer[currentIndex] == null) {
      SnackBars.buildMessage(context, "Please choose an answer!");
      return;
    }

    if (currentIndex == listQuestion.length - 1) {
      buildDialog(
        context,
        "Finish?",
        "Are you sure you want to finish the quiz?",
        DialogType.success,
        () async {
          await submitExamResult();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizFinishPage(
                title: listQuestion[0].category ?? '',
                answer: answer,
                listQuestion: listQuestion,
              ),
            ),
          );
        },
        () {},
      );
    } else {
      setState(() {
        currentIndex++;
      });
    }
  }

  Future<void> submitExamResult() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    final parts = token.split('.');
    String name = 'Unknown';
    String userId = '';
    if (parts.length == 3) {
      final payload = base64Url.normalize(parts[1]);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      name = decoded['name'] ?? 'Unknown';
      userId = decoded['userId'] ?? ''; // phải là ObjectId từ backend
    }

    int score = 0;
    for (int i = 0; i < listQuestion.length; i++) {
      if (answer[i] == listQuestion[i].correctAnswer) {
        score += (100 ~/ listQuestion.length);
      }
    }

    final status = score >= 50 ? 'Passed' : 'Failed';

    final dio = Dio();
    print('Submitting result...${widget.idTest} ${widget.isTest}');
    try {
      await dio.post(
        'http://192.168.52.91:3000/api/results/add',
        data: {
          "name": name,
          "score": score,
          "status": status,
          "date": DateTime.now().toIso8601String(),
          "categoryId": widget.categoryId,
          "questionId": widget.categoryId,
          "userId": userId,
          "isTest": widget.isTest,
          "testId": widget.idTest,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } catch (e) {
      print("Submit error: $e");
    }
  }

  void changeQuestion(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestionText = listQuestion.isNotEmpty
        ? listQuestion[currentIndex].question ?? 'Quiz'
        : 'Quiz';

    return Scaffold(
      backgroundColor: const Color(0xFFE9F1FB),
      body: Column(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: kTitleColor),
                  onPressed: () {
                    buildDialog(
                      context,
                      "Cảnh báo!",
                      'Bạn có muốn thoát khỏi bài thi không?',
                      DialogType.warning,
                      () => Navigator.pop(context),
                      () {},
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentQuestionText.length > 60
                        ? currentQuestionText.substring(0, 60) + '...'
                        : currentQuestionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTitleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(child: Text(error))
                    : buildQuizContent(),
          ),
        ],
      ),
    );
  }

  Widget buildQuizContent() {
    final q = listQuestion[currentIndex];
    final options = shuffledOptions[currentIndex] ?? [];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey<int>(currentIndex),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${currentIndex + 1} of ${listQuestion.length}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  unescape.convert(q.question ?? ''),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((opt) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: answer[currentIndex] == opt
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RadioListTile<String>(
                    value: opt,
                    groupValue: answer[currentIndex],
                    onChanged: (val) => selectAnswer(val),
                    title: Text(unescape.convert(opt)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () => changeQuestion(currentIndex - 1),
                    child: const Text("Previous"),
                  ),
                ElevatedButton(
                  onPressed: nextOrSubmit,
                  child: Text(
                    currentIndex == listQuestion.length - 1 ? "Submit" : "Next",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
