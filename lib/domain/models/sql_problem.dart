import 'package:equatable/equatable.dart';

class SqlProblem extends Equatable {
  final String id;
  final String category;
  final String title;
  final String description;
  final String answerSql;

  /// true면 행 순서까지 같아야 정답 (ORDER BY 문제)
  final bool ordered;

  /// 데이터 변경 문제에서 실행 후 보여줄 테이블. null이면 조회 문제.
  final String? targetTable;

  const SqlProblem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.answerSql,
    this.ordered = false,
    this.targetTable,
  });

  bool get isMutation => targetTable != null;

  /// 정답 쿼리에 쓰인 SQL 키워드 (등장 순서, 중복 제거). 힌트용.
  List<String> get keywords {
    final found = <String, int>{};
    var rest = answerSql.toUpperCase();
    for (final keyword in _hintKeywords) {
      final pattern = RegExp('\\b${keyword.replaceAll(' ', '\\s+')}\\b');
      final match = pattern.firstMatch(rest);
      if (match == null) continue;
      found[keyword] = match.start;
      // LEFT JOIN을 찾은 뒤 JOIN이 또 잡히지 않도록 지운다
      rest = rest.replaceAll(pattern, ' ' * keyword.length);
    }
    return found.keys.toList()..sort((a, b) => found[a]!.compareTo(found[b]!));
  }

  @override
  List<Object?> get props =>
      [id, category, title, description, answerSql, ordered, targetTable];
}

// 여러 단어 키워드를 먼저 둬야 한 단어 키워드보다 먼저 매칭된다
const _hintKeywords = [
  'INSERT INTO',
  'DELETE FROM',
  'LEFT JOIN',
  'ORDER BY',
  'GROUP BY',
  'IS NULL',
  'SELECT',
  'DISTINCT',
  'FROM',
  'WHERE',
  'AND',
  'OR',
  'IN',
  'BETWEEN',
  'LIKE',
  'DESC',
  'LIMIT',
  'COUNT',
  'SUM',
  'AVG',
  'MAX',
  'HAVING',
  'JOIN',
  'ON',
  'VALUES',
  'UPDATE',
  'SET',
];
