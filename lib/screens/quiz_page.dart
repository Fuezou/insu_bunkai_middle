import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';
import '../generators/problem_generator.dart';
import 'result_page.dart';

/// クイズ画面
/// 4択形式の因数分解問題を出題
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final ProblemGenerator _generator = ProblemGenerator();
  
  int currentIndex = 0;
  List<QuizProblem> problems = [];
  List<QuizResult> results = [];
  bool isAnswered = false;
  int? selectedChoice;
  DateTime? startTime;
  Duration totalTime = Duration.zero;
  List<int> mistakePatterns = [];

  @override
  void initState() {
    super.initState();
    generateInitialProblems();
    startTime = DateTime.now();
  }

  /// 初期8問セットを生成
  void generateInitialProblems() {
    problems = _generator.generateBasicQuizSet();
  }

  /// 選択肢を選択したときの処理
  void selectAnswer(int index) {
    if (isAnswered) return;
    
    setState(() {
      isAnswered = true;
      selectedChoice = index;
      
      bool isCorrect = problems[currentIndex].choices[index] == 
                       problems[currentIndex].correctAnswer;
      
      results.add(QuizResult(
        pattern: problems[currentIndex].pattern,
        question: problems[currentIndex].expression,
        correct: problems[currentIndex].correctAnswer,
        userAnswer: problems[currentIndex].choices[index],
        isCorrect: isCorrect,
      ));
      
      // 間違えた場合、追加問題を生成（最大3回まで）
      if (!isCorrect && !mistakePatterns.contains(problems[currentIndex].pattern)) {
        mistakePatterns.add(problems[currentIndex].pattern);
        if (problems.length < 12) { // 最大12問まで
          problems.add(_generator.generateAdditionalProblem(problems[currentIndex].pattern));
        }
      }
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (currentIndex < problems.length - 1) {
          setState(() {
            currentIndex++;
            isAnswered = false;
            selectedChoice = null;
          });
        } else {
          // クイズ終了
          totalTime = DateTime.now().difference(startTime!);
          saveResults();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultPage(
                session: QuizSession(
                  results: results,
                  totalTime: totalTime,
                  startTime: startTime!,
                  endTime: DateTime.now(),
                ),
              ),
            ),
          );
        }
      });
    });
  }

  /// 結果をSharedPreferencesに保存
  Future<void> saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    
    int correctCount = results.where((r) => r.isCorrect).length;
    int currentBestScore = prefs.getInt('bestScore') ?? 0;
    int currentBestTime = prefs.getInt('bestTime') ?? 0;
    
    // ベストスコア更新
    if (correctCount > currentBestScore) {
      await prefs.setInt('bestScore', correctCount);
    }
    
    // ベストタイム更新（全問正解時のみ）
    if (correctCount == problems.length) {
      if (currentBestTime == 0 || totalTime.inSeconds < currentBestTime) {
        await prefs.setInt('bestTime', totalTime.inSeconds);
      }
    }
    
    // 累計データ更新
    int totalGames = (prefs.getInt('totalGames') ?? 0) + 1;
    int totalCorrect = (prefs.getInt('totalCorrect') ?? 0) + correctCount;
    int totalQuestions = (prefs.getInt('totalQuestions') ?? 0) + problems.length;
    
    await prefs.setInt('totalGames', totalGames);
    await prefs.setInt('totalCorrect', totalCorrect);
    await prefs.setInt('totalQuestions', totalQuestions);
  }

  /// 選択肢ボタンの色を決定
  Color getButtonColor(int index) {
    if (!isAnswered) {
      return selectedChoice == index ? Colors.blue.shade100 : Colors.white;
    }
    
    bool isCorrectAnswer = problems[currentIndex].choices[index] == 
                          problems[currentIndex].correctAnswer;
    
    if (isCorrectAnswer) {
      return Colors.green.shade300;
    } else if (selectedChoice == index) {
      return Colors.red.shade300;
    }
    return Colors.grey.shade300;
  }

  /// 選択肢ボタンの枠線色を決定
  Color getBorderColor(int index) {
    if (!isAnswered) {
      return selectedChoice == index ? Colors.blue : Colors.grey;
    }
    
    bool isCorrectAnswer = problems[currentIndex].choices[index] == 
                          problems[currentIndex].correctAnswer;
    
    if (isCorrectAnswer) {
      return Colors.green;
    } else if (selectedChoice == index) {
      return Colors.red;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (problems.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final problem = problems[currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('因数分解クイズ - 中級'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / problems.length,
            backgroundColor: Colors.green.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 問題番号
            Text(
              '問題 ${currentIndex + 1} / ${problems.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // 問題表示
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '次の式を因数分解せよ',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Math.tex(
                    problem.expression,
                    textStyle: const TextStyle(fontSize: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // 選択肢
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3.0,
                children: List.generate(4, (index) {
                  return Material(
                    color: getButtonColor(index),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: isAnswered ? null : () => selectAnswer(index),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: getBorderColor(index),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Math.tex(
                            problem.choices[index],
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // 正誤表示
            if (isAnswered)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: results.last.isCorrect 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  results.last.isCorrect ? '正解！' : '不正解',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: results.last.isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}