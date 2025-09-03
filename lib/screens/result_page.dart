import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/quiz_models.dart';
import '../utils/math_utils.dart';
import 'quiz_page.dart';

/// 結果画面
/// クイズ終了後の結果と詳細を表示
class ResultPage extends StatelessWidget {
  final QuizSession session;
  
  const ResultPage({
    super.key, 
    required this.session,
  });
  
  /// 解答時間を分秒形式で表示
  String get timeString {
    int minutes = session.totalTime.inMinutes;
    int seconds = session.totalTime.inSeconds % 60;
    return '${minutes}分${seconds}秒';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('結果'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // 戻るボタンを非表示
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // スコア表示
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'スコア',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '${session.correctCount} / ${session.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            '正答率',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '${session.accuracyPercentage}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '解答時間: $timeString',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 間違えたパターンの表示
            if (session.mistakesByPattern.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '復習が必要な問題タイプ：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...session.mistakesByPattern.entries.map((entry) {
                      return Text(
                        '• ${getPatternDescription(entry.key)} 型：${entry.value}問',
                        style: const TextStyle(fontSize: 14),
                      );
                    }).toList(),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // 問題ごとの結果
            Expanded(
              child: ListView.builder(
                itemCount: session.results.length,
                itemBuilder: (context, index) {
                  final result = session.results[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: result.isCorrect 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: result.isCorrect 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 問題番号
                        Text(
                          '${index + 1}. ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        
                        // 問題と正答
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 問題
                              Row(
                                children: [
                                  Flexible(
                                    child: Math.tex(
                                      result.question,
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const Text(
                                    ' = ',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              
                              // 正答
                              Row(
                                children: [
                                  const Text(
                                    '正答: ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Flexible(
                                    child: Math.tex(
                                      result.correct,
                                      textStyle: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // ユーザーの回答（間違いの場合のみ）
                              if (!result.isCorrect)
                                Row(
                                  children: [
                                    const Text(
                                      '回答: ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Flexible(
                                      child: Math.tex(
                                        result.userAnswer,
                                        textStyle: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        
                        // 正誤アイコン
                        Icon(
                          result.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: result.isCorrect ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('もう一度'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('ホームへ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}