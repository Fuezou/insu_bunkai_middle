import 'dart:math';
import '../models/quiz_models.dart';
import '../utils/math_utils.dart';

/// パターン0: ax(cx+d)
/// パターン4: ax(cx+dy)
/// の問題生成を担当するクラス
class Pattern04Generator {
  final Random _random = Random();

  /// パターン0: ax(cx+d) の問題を生成
  QuizProblem generatePattern0() {
    int a, c, d;
    
    do {
      a = _random.nextInt(3) + 1;  // 1〜3
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(13) - 6; // -6〜6
      if (d == 0) d = _random.nextBool() ? 1 : -1;
    } while (gcd(c, d.abs()) != 1);  // gcd(c,|d|) = 1 を保証

    // 展開形：acx^2 + adx
    int coefX2 = a * c;
    int coefX = a * d;
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefX, 'x', false)}';

    // 正答：因数分解形：ax(cx+d)
    String correctAnswer;
    if (a == 1) {
      correctAnswer = 'x(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})';
    } else {
      correctAnswer = '${a}x(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})';
    }

    // 誤答生成
    List<String> wrongAnswers = _generatePattern0WrongAnswers(a, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 0,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン4: ax(cx+dy) の問題を生成
  QuizProblem generatePattern4() {
    int a, c, d;
    
    do {
      a = _random.nextInt(3) + 1;  // 1〜3
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(13) - 6; // -6〜6
      if (d == 0) d = _random.nextBool() ? 1 : -1;
    } while (gcd(c, d.abs()) != 1);  // gcd(c,|d|) = 1 を保証

    // 展開形：acx^2 + adxy
    int coefX2 = a * c;
    int coefXY = a * d;
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefXY, 'xy', false)}';

    // 正答：因数分解形：ax(cx+dy)
    String correctAnswer;
    if (a == 1) {
      correctAnswer = 'x(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})';
    } else {
      correctAnswer = '${a}x(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})';
    }

    // 誤答生成
    List<String> wrongAnswers = _generatePattern4WrongAnswers(a, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 4,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン0の誤答を生成（元のロジック完全移植）
  List<String> _generatePattern0WrongAnswers(int a, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 符号のミス ax(cx-d)
    String wrong1;
    if (a == 1) {
      wrong1 = 'x(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
    } else {
      wrong1 = '${a}x(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
    }
    wrongAnswers.add(wrong1);

    // 誤答2: 共通因数の括り出しのミス ax(cx+ad)
    String wrong2;
    if (a == 1) {
      // a=1の場合は括弧内の係数を変える
      int newC = c == 1 ? 2 : 1;
      wrong2 = 'x(${formatTerm(newC, 'x', true)}${formatTerm(d, '', false)})';
    } else {
      wrong2 = '${a}x(${formatTerm(c, 'x', true)}${formatTerm(a * d, '', false)})';
    }
    wrongAnswers.add(wrong2);

    // 誤答3: a≠1の時は共通因数の書き忘れ、a=1の時は異なる因数分解
    String wrong3;
    if (a != 1) {
      // 共通因数aの書き忘れ: x(cx+d)
      wrong3 = 'x(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})';
    } else {
      // a=1の時: 新しいc',d'を生成（gcd(c',|d'|)=1）
      int cPrime, dPrime;
      do {
        cPrime = _random.nextInt(3) + 1;  // 1〜3
        dPrime = _random.nextInt(13) - 6; // -6〜6
        if (dPrime == 0) dPrime = _random.nextBool() ? 1 : -1;
      } while (
        gcd(cPrime, dPrime.abs()) != 1 || 
        (cPrime == c && dPrime == d) ||   // 正答と同じ
        (cPrime == c && dPrime == -d)     // 誤答1と同じ
      );
      wrong3 = 'x(${formatTerm(cPrime, 'x', true)}${formatTerm(dPrime, '', false)})';
    }
    wrongAnswers.add(wrong3);

    return wrongAnswers;
  }

  /// パターン4の誤答を生成（元のロジック完全移植）
  List<String> _generatePattern4WrongAnswers(int a, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 符号のミス ax(cx-dy)
    String wrong1;
    if (a == 1) {
      wrong1 = 'x(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    } else {
      wrong1 = '${a}x(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    }
    wrongAnswers.add(wrong1);

    // 誤答2: 共通因数の括り出しのミス ax(cx+ady)
    String wrong2;
    if (a == 1) {
      // a=1の場合は括弧内の係数を変える
      int newC = c == 1 ? 2 : 1;
      wrong2 = 'x(${formatTerm(newC, 'x', true)}${formatTerm(d, 'y', false)})';
    } else {
      wrong2 = '${a}x(${formatTerm(c, 'x', true)}${formatTerm(a * d, 'y', false)})';
    }
    wrongAnswers.add(wrong2);

    // 誤答3: a≠1の時は共通因数の書き忘れ、a=1の時は異なる因数分解
    String wrong3;
    if (a != 1) {
      // 共通因数aの書き忘れ: x(cx+dy)
      wrong3 = 'x(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})';
    } else {
      // a=1の時: 新しいc',d'を生成
      int cPrime, dPrime;
      do {
        cPrime = _random.nextInt(3) + 1;  // 1〜3
        dPrime = _random.nextInt(13) - 6; // -6〜6
        if (dPrime == 0) dPrime = _random.nextBool() ? 1 : -1;
      } while (
        gcd(cPrime, dPrime.abs()) != 1 || 
        (cPrime == c && dPrime == d) ||   // 正答と同じ
        (cPrime == c && dPrime == -d)     // 誤答1と同じ
      );
      wrong3 = 'x(${formatTerm(cPrime, 'x', true)}${formatTerm(dPrime, 'y', false)})';
    }
    wrongAnswers.add(wrong3);

    return wrongAnswers;
  }
}