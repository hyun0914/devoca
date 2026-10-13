import 'dart:convert';
import 'package:sqlite3/common.dart';
import '../../domain/models/sql_problem.dart';
import '../../domain/models/sql_result.dart';
import '../sql_problem_data.dart';
import 'sql_engine.dart';

enum SqlVerdict { correct, wrong, error }

class SqlGradeResult {
  final SqlVerdict verdict;

  /// 조회 문제는 사용자 쿼리 결과, 변경 문제는 실행 후 대상 테이블
  final SqlResult? output;
  final String? message;

  const SqlGradeResult(this.verdict, {this.output, this.message});
}

class SqlPracticeService {
  final SqlEngine _engine;
  SqlPracticeService([SqlEngine? engine])
      : _engine = engine ?? SqlEngine.instance;

  Future<Map<String, SqlResult>> loadTables() async {
    final session = await _engine.open(seedSql: kSqlSeed);
    try {
      return {
        for (final table in kSqlTables)
          table: session.run('SELECT * FROM $table'),
      };
    } finally {
      session.close();
    }
  }

  /// 사용자 쿼리와 정답 쿼리를 각각 새 DB에서 실행해 결과를 비교한다.
  Future<SqlGradeResult> grade(SqlProblem problem, String userSql) async {
    final expected = await _evaluate(problem, problem.answerSql);

    final _Evaluation actual;
    try {
      actual = await _evaluate(problem, userSql);
    } on SqliteException catch (e) {
      return SqlGradeResult(SqlVerdict.error, message: e.message);
    } on ArgumentError catch (e) {
      return SqlGradeResult(SqlVerdict.error, message: '${e.message}');
    }

    final mismatch = problem.isMutation
        ? _compareTables(expected.tables, actual.tables)
        : _compareOutput(expected.output, actual.output, problem.ordered);

    return SqlGradeResult(
      mismatch == null ? SqlVerdict.correct : SqlVerdict.wrong,
      output: problem.isMutation
          ? actual.tables[problem.targetTable]
          : actual.output,
      message: mismatch,
    );
  }

  Future<_Evaluation> _evaluate(SqlProblem problem, String sql) async {
    final session = await _engine.open(seedSql: kSqlSeed);
    try {
      final output = session.run(sql);
      return _Evaluation(output, {
        for (final table in kSqlTables)
          table: session.run('SELECT * FROM $table'),
      });
    } finally {
      session.close();
    }
  }

  String? _compareOutput(SqlResult expected, SqlResult actual, bool ordered) {
    if (expected.columns.length != actual.columns.length) {
      return '컬럼 수가 다릅니다. (기대 ${expected.columns.length}개, 결과 ${actual.columns.length}개)';
    }
    if (expected.rows.length != actual.rows.length) {
      return '행 수가 다릅니다. (기대 ${expected.rows.length}개, 결과 ${actual.rows.length}개)';
    }
    final expectedKeys = expected.rows.map(_rowKey).toList();
    final actualKeys = actual.rows.map(_rowKey).toList();
    if (_listEquals(expectedKeys, actualKeys)) return null;

    final sameRows =
        _listEquals([...expectedKeys]..sort(), [...actualKeys]..sort());
    if (!sameRows) return '결과 값이 다릅니다.';
    return ordered ? '정렬 순서가 다릅니다.' : null;
  }

  String? _compareTables(
    Map<String, SqlResult> expected,
    Map<String, SqlResult> actual,
  ) {
    for (final table in kSqlTables) {
      final expectedKeys = expected[table]!.rows.map(_rowKey).toList()..sort();
      final actualKeys = actual[table]!.rows.map(_rowKey).toList()..sort();
      if (!_listEquals(expectedKeys, actualKeys)) {
        return '실행 후 $table 테이블의 상태가 기대와 다릅니다.';
      }
    }
    return null;
  }

  // 웹에서는 정수도 double로 오기 때문에 25와 25.0을 같은 값으로 맞춘다
  String _rowKey(List<Object?> row) => jsonEncode([
        for (final value in row)
          if (value is num && value.isFinite && value == value.truncate())
            value.toInt()
          else if (value is num || value is String || value == null)
            value
          else
            value.toString(),
      ]);

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _Evaluation {
  final SqlResult output;
  final Map<String, SqlResult> tables;
  const _Evaluation(this.output, this.tables);
}
