import 'dart:math';
import '../models/quiz_models.dart';
import '../utils/math_utils.dart';

/// パターン3: a(cx+d)(cx-d)
/// パターン7: a(cx+dy)(cx-dy)
/// の問題生成を担当するクラス（平方の差）
class Pattern37Generator {
  final Random _random = Random();

  /// パターン3: a(cx+d)(cx-d) の問題を生成
  QuizProblem generatePattern3() {
    int a, c, d;
    
    do {
      a = _random.nextInt(3) + 1;  // 1〜3
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(6) + 1;  // 1〜6（正の値のみ、平方の差なので）
    } while (gcd(c, d) != 1);  // gcd(c,d) = 1 を保証

    // 展開形：a(c²x² - d²)
    int coefX2 = a * c * c;
    int coefConst = -a * d * d;
    
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefConst, '', false)}';

    // 正答：因数分解形：a(cx+d)(cx-d)
    String correctAnswer;
    if (a == 1) {
      correctAnswer = '(${formatTerm(c, 'x', true)} + $d)(${formatTerm(c, 'x', true)} - $d)';
    } else {
      correctAnswer = '$a(${formatTerm(c, 'x', true)} + $d)(${formatTerm(c, 'x', true)} - $d)';
    }

    // 誤答生成
    List<String> wrongAnswers = _generatePattern3WrongAnswers(a, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 3,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン7: a(cx+dy)(cx-dy) の問題を生成
  QuizProblem generatePattern7() {
    int a, c, d;
    
    do {
      a = _random.nextInt(3) + 1;  // 1〜3
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(6) + 1;  // 1〜6（正の値のみ、平方の差なので）
    } while (gcd(c, d) != 1);  // gcd(c,d) = 1 を保証

    // 展開形：a(c²x² - d²y²)
    int coefX2 = a * c * c;
    int coefY2 = -a * d * d;
    
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefY2, 'y^2', false)}';

    // 正答：因数分解形：a(cx+dy)(cx-dy)
    String correctAnswer;
    if (a == 1) {
      correctAnswer = '(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    } else {
      correctAnswer = '$a(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    }

    // 誤答生成
    List<String> wrongAnswers = _generatePattern7WrongAnswers(a, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 7,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン3の誤答を生成（Document 5の元コード完全移植）
  List<String> _generatePattern3WrongAnswers(int a, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 完全平方との混同 a(cx+d)²
    String wrong1;
    if (a == 1) {
      wrong1 = '(${formatTerm(c, 'x', true)} + $d)^2';
    } else {
      wrong1 = '$a(${formatTerm(c, 'x', true)} + $d)^2';
    }
    wrongAnswers.add(wrong1);

    // 誤答2: 係数忘れ (cx+d)(cx-d)
    String wrong2 = '(${formatTerm(c, 'x', true)} + $d)(${formatTerm(c, 'x', true)} - $d)';
    wrongAnswers.add(wrong2);

    // 誤答3: 因数ペアの取り違え a(cx+d')(cx-d'')
    String wrong3;
    int dSquared = d * d;
    List<List<int>> pairs = getSquareFactorPairs(dSquared);
    
    // 正答のペア [d, d] を除外
    pairs.removeWhere((pair) => (pair[0] == d && pair[1] == d));
    
    if (pairs.isNotEmpty) {
      var newPair = pairs[_random.nextInt(pairs.length)];
      int dPrime = newPair[0];
      int dDoublePrime = newPair[1];
      
      if (a == 1) {
        wrong3 = '(${formatTerm(c, 'x', true)} + $dPrime)(${formatTerm(c, 'x', true)} - $dDoublePrime)';
      } else {
        wrong3 = '$a(${formatTerm(c, 'x', true)} + $dPrime)(${formatTerm(c, 'x', true)} - $dDoublePrime)';
      }
    } else {
      // 因数ペアがない場合（d=1の場合など）、完全平方の負バージョンを使用
      if (a == 1) {
        wrong3 = '(${formatTerm(c, 'x', true)} - $d)^2';
      } else {
        wrong3 = '$a(${formatTerm(c, 'x', true)} - $d)^2';
      }
    }
    wrongAnswers.add(wrong3);

    return wrongAnswers;
  }

  /// パターン7の誤答を生成（Document 5の元コード完全移植）
  List<String> _generatePattern7WrongAnswers(int a, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 完全平方との混同 a(cx+dy)²
    String wrong1;
    if (a == 1) {
      wrong1 = '(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})^2';
    } else {
      wrong1 = '$a(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})^2';
    }
    wrongAnswers.add(wrong1);

    // 誤答2: 係数忘れ (cx+dy)(cx-dy)
    String wrong2;
    if (a != 1) {
      wrong2 = '(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    } else {
      // a=1の場合は係数を2倍にして差別化
      wrong2 = '2(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    }
    wrongAnswers.add(wrong2);

    // 誤答3: 因数ペアの取り違え a(cx+d'y)(cx-d''y)
    String wrong3;
    int dSquared = d * d;
    List<List<int>> pairs = getSquareFactorPairs(dSquared);
    
    // 正答のペア [d, d] を除外
    pairs.removeWhere((pair) => (pair[0] == d && pair[1] == d));
    
    if (pairs.isNotEmpty) {
      var newPair = pairs[_random.nextInt(pairs.length)];
      int dPrime = newPair[0];
      int dDoublePrime = newPair[1];
      
      if (a == 1) {
        wrong3 = '(${formatTerm(c, 'x', true)}${formatTerm(dPrime, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-dDoublePrime, 'y', false)})';
      } else {
        wrong3 = '$a(${formatTerm(c, 'x', true)}${formatTerm(dPrime, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-dDoublePrime, 'y', false)})';
      }
    } else {
      // 因数ペアがない場合、完全平方の負バージョンを使用
      if (a == 1) {
        wrong3 = '(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})^2';
      } else {
        wrong3 = '$a(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})^2';
      }
    }
    wrongAnswers.add(wrong3);

    return wrongAnswers;
  }
}