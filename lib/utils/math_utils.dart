import 'dart:math';

/// 最大公約数を計算する関数（ユークリッドの互除法）
int gcd(int x, int y) {
  x = x.abs();
  y = y.abs();
  while (y != 0) {
    int temp = y;
    y = x % y;
    x = temp;
  }
  return x;
}

/// 数式の項を適切にフォーマットする関数
/// 
/// [coef] 係数
/// [variable] 変数部分（'x', 'y', 'x^2', 'xy'など）
/// [isFirst] 項が最初かどうか（符号の表示に影響）
String formatTerm(int coef, String variable, bool isFirst) {
  if (coef == 0) return '';
  
  String sign = '';
  int absCoef = coef.abs();
  
  // 符号の決定
  if (!isFirst) {
    sign = coef > 0 ? ' + ' : ' - ';
  } else {
    sign = coef < 0 ? '-' : '';
  }
  
  // 変数がある場合の処理
  if (variable.isNotEmpty) {
    if (absCoef == 1) {
      return '$sign$variable';
    }
    return '$sign$absCoef$variable';
  }
  
  // 定数項の場合
  return '$sign$absCoef';
}

/// bd = product となる因数ペアを生成する関数
/// 
/// [product] 積
/// 戻り値：[b, d] のペアのリスト
List<List<int>> getFactorPairs(int product) {
  List<List<int>> pairs = [];
  int absProduct = product.abs();
  
  for (int i = 1; i <= absProduct; i++) {
    if (absProduct % i == 0) {
      int j = absProduct ~/ i;
      if (product > 0) {
        // 正の積の場合：同符号のペア
        pairs.add([i, j]);
        pairs.add([-i, -j]);
      } else {
        // 負の積の場合：異符号のペア
        pairs.add([i, -j]);
        pairs.add([-i, j]);
      }
    }
  }
  return pairs;
}

/// d^2の因数ペアを取得する関数（平方の差用）
/// 
/// [dSquared] d^2の値
/// 戻り値：[d', d''] のペアのリスト（d' * d'' = d^2）
List<List<int>> getSquareFactorPairs(int dSquared) {
  List<List<int>> pairs = [];
  
  for (int i = 1; i * i <= dSquared; i++) {
    if (dSquared % i == 0) {
      int j = dSquared ~/ i;
      // d' * d'' = d^2 となるペアを追加
      pairs.add([i, j]);
      if (i != j) {
        pairs.add([j, i]);
      }
    }
  }
  
  return pairs;
}

/// ランダムな係数を生成する関数
/// 
/// [min] 最小値
/// [max] 最大値
/// [excludeZero] 0を除外するかどうか
int generateRandomCoefficient(int min, int max, {bool excludeZero = false}) {
  final random = Random();
  int value;
  
  do {
    value = random.nextInt(max - min + 1) + min;
  } while (excludeZero && value == 0);
  
  return value;
}

/// パターンの説明を取得する関数
String getPatternDescription(int pattern) {
  switch (pattern) {
    case 0: return 'ax(cx+d)';
    case 1: return '(ax+b)(cx+d)';
    case 2: return 'a(cx+d)²';
    case 3: return 'a(cx+d)(cx-d)';
    case 4: return 'ax(cx+dy)';
    case 5: return '(ax+by)(cx+dy)';
    case 6: return 'a(cx+dy)²';
    case 7: return 'a(cx+dy)(cx-dy)';
    default: return '不明なパターン';
  }
}