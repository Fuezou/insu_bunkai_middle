import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';
import 'quiz_page.dart';

/// ホーム画面
/// 因数分解クイズ中級編のメイン画面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuizRecords? records;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  /// SharedPreferencesから記録を読み込む
  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      records = QuizRecords(
        bestScore: prefs.getInt('bestScore') ?? 0,
        bestTime: prefs.getInt('bestTime') ?? 0,
        totalGames: prefs.getInt('totalGames') ?? 0,
        totalCorrect: prefs.getInt('totalCorrect') ?? 0,
        totalQuestions: prefs.getInt('totalQuestions') ?? 0,
      );
      isLoading = false;
    });
  }

  /// ベストタイムを分秒形式で表示
  String formatTime(int seconds) {
    if (seconds == 0) return '--';
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}分${remainingSeconds}秒';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('因数分解クイズ - 中級'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // タイトル
                  const Text(
                    '因数分解マスター',
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // サブタイトル
                  const Text(
                    '中級編',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 個人記録表示
                  if (records != null && records!.totalGames > 0)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '個人記録',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // 記録の詳細
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'ベストスコア',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    '${records!.bestScore}/8',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'ベストタイム',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    formatTime(records!.bestTime),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'プレイ回数',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    '${records!.totalGames}回',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    '累計正答率',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    '${records!.overallAccuracy}%',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // 説明カード
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'クイズについて',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '• 基本8問（各パターン1問ずつ）',
                          style: TextStyle(fontSize: 14),
                        ),
                        const Text(
                          '• 間違えた問題は最大3回まで追加',
                          style: TextStyle(fontSize: 14),
                        ),
                        const Text(
                          '• 展開式→因数分解形を4択で選択',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // スタートボタン
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizPage()),
                      );
                      // クイズから戻ってきたら記録を再読み込み
                      if (result == true) {
                        loadRecords();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'クイズを始める',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }
}