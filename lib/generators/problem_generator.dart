import '../models/quiz_models.dart';
import 'pattern_0_4_generator.dart';
import 'pattern_1_5_generator.dart';
import 'pattern_2_6_generator.dart';
import 'pattern_3_7_generator.dart';

/// 因数分解問題を生成するメインクラス
/// 各パターンの生成を専用クラスに委譲する
class ProblemGenerator {
  final Pattern04Generator _pattern04Generator = Pattern04Generator();
  final Pattern15Generator _pattern15Generator = Pattern15Generator();
  final Pattern26Generator _pattern26Generator = Pattern26Generator();
  final Pattern37Generator _pattern37Generator = Pattern37Generator();

  /// 指定されたパターンでクイズ問題を生成
  QuizProblem generateQuizProblem(int pattern) {
    switch (pattern) {
      case 0:
        return _pattern04Generator.generatePattern0();
      case 1:
        return _pattern15Generator.generatePattern1();
      case 2:
        return _pattern26Generator.generatePattern2();
      case 3:
        return _pattern37Generator.generatePattern3();
      case 4:
        return _pattern04Generator.generatePattern4();
      case 5:
        return _pattern15Generator.generatePattern5();
      case 6:
        return _pattern26Generator.generatePattern6();
      case 7:
        return _pattern37Generator.generatePattern7();
      default:
        throw ArgumentError('無効なパターン: $pattern');
    }
  }

  /// 基本8問セット（各パターン1問ずつ）を生成
List<QuizProblem> generateBasicQuizSet() {
  List<QuizProblem> problems = [];
  for (int pattern = 0; pattern < 8; pattern++) {
    var problem = generateQuizProblem(pattern);
    print('パターン$pattern: ${problem.expression}'); // デバッグ出力
    problems.add(problem);
  }
  problems.shuffle(); // 出題順をランダム化
  
  // シャッフル後の順序をデバッグ出力
  for (int i = 0; i < problems.length; i++) {
    print('問題${i+1}: パターン${problems[i].pattern}');
  }
  
  return problems;
}

  /// 指定されたパターンの追加問題を生成（間違えた時用）
  QuizProblem generateAdditionalProblem(int pattern) {
    return generateQuizProblem(pattern);
  }
}