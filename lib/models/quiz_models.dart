// クイズ問題のデータクラス
class QuizProblem {
  final int pattern;        // 問題パターン（0〜7）
  final String expression;  // 展開形（問題として表示）
  final String correctAnswer; // 正答の因数分解形
  final List<String> choices; // 4択の選択肢

  QuizProblem({
    required this.pattern,
    required this.expression,
    required this.correctAnswer,
    required this.choices,
  });
}

// クイズ結果のデータクラス
class QuizResult {
  final int pattern;        // 問題パターン
  final String question;    // 問題（展開形）
  final String correct;     // 正答
  final String userAnswer;  // ユーザーの回答
  final bool isCorrect;     // 正誤判定

  QuizResult({
    required this.pattern,
    required this.question,
    required this.correct,
    required this.userAnswer,
    required this.isCorrect,
  });
}

// 問題生成時に使用する係数データ
class ProblemCoefficients {
  final int a;
  final int b;
  final int c;
  final int d;

  ProblemCoefficients({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });
}

// クイズセッション全体の統計データ
class QuizSession {
  final List<QuizResult> results;
  final Duration totalTime;
  final DateTime startTime;
  final DateTime endTime;

  QuizSession({
    required this.results,
    required this.totalTime,
    required this.startTime,
    required this.endTime,
  });

  // 正解数を取得
  int get correctCount => results.where((r) => r.isCorrect).length;
  
  // 正答率を取得（パーセント）
  int get accuracyPercentage => (correctCount / results.length * 100).round();
  
  // 問題数を取得
  int get totalQuestions => results.length;
  
  // 間違えたパターンの集計
  Map<int, int> get mistakesByPattern {
    Map<int, int> mistakes = {};
    for (var result in results) {
      if (!result.isCorrect) {
        mistakes[result.pattern] = (mistakes[result.pattern] ?? 0) + 1;
      }
    }
    return mistakes;
  }
}

// 保存用の記録データクラス
class QuizRecords {
  final int bestScore;
  final int bestTime;  // 秒数
  final int totalGames;
  final int totalCorrect;
  final int totalQuestions;

  QuizRecords({
    required this.bestScore,
    required this.bestTime,
    required this.totalGames,
    required this.totalCorrect,
    required this.totalQuestions,
  });

  // 累計正答率を取得（パーセント）
  int get overallAccuracy => 
    totalQuestions > 0 ? (totalCorrect / totalQuestions * 100).round() : 0;
}