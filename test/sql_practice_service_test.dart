import 'package:devoca/data/services/sql_practice_service.dart';
import 'package:devoca/data/sql_problem_data.dart';
import 'package:devoca/domain/models/sql_problem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = SqlPracticeService();
  SqlProblem problem(String id) => kSqlProblems.firstWhere((p) => p.id == id);

  Future<SqlVerdict> verdict(String id, String sql) async =>
      (await service.grade(problem(id), sql)).verdict;

  test('모든 문제는 자기 정답 쿼리로 정답 처리된다', () async {
    for (final p in kSqlProblems) {
      final result = await service.grade(p, p.answerSql);
      expect(result.verdict, SqlVerdict.correct, reason: p.id);
      expect(result.output, isNotNull, reason: p.id);
      expect(result.output!.rows, isNotEmpty, reason: p.id);
    }
  });

  test('문제 id는 겹치지 않고 카테고리는 모두 등록되어 있다', () {
    expect(
        kSqlProblems.map((p) => p.id).toSet(), hasLength(kSqlProblems.length));
    expect(kSqlProblems.map((p) => p.category).toSet(), kSqlCategories.toSet());
  });

  test('변경 문제의 정답은 실제로 테이블을 바꾼다', () async {
    for (final p in kSqlProblems.where((p) => p.isMutation)) {
      final noop = await service.grade(p, 'SELECT 1');
      expect(noop.verdict, SqlVerdict.wrong, reason: p.id);
    }
  });

  test('표현이 달라도 결과가 같으면 정답', () async {
    expect(
      await verdict('where-age',
          'select name, age from users where not age < 30 order by name;'),
      SqlVerdict.correct,
    );
    expect(
      await verdict('group-city',
          'SELECT city, COUNT(id) AS cnt FROM users GROUP BY city ORDER BY cnt'),
      SqlVerdict.correct,
    );
    expect(
      await verdict(
          'update-city', "UPDATE users SET city = 'Busan' WHERE name = 'Park'"),
      SqlVerdict.correct,
    );
  });

  test('결과가 다르면 오답과 이유를 돌려준다', () async {
    final rows = await service.grade(
        problem('where-age'), 'SELECT name, age FROM users WHERE age > 31');
    expect(rows.verdict, SqlVerdict.wrong);
    expect(rows.message, contains('행 수'));

    final columns =
        await service.grade(problem('where-age'), 'SELECT name FROM users');
    expect(columns.verdict, SqlVerdict.wrong);
    expect(columns.message, contains('컬럼 수'));

    final order = await service.grade(problem('order-limit'),
        'SELECT name, price FROM products WHERE price >= 89000 ORDER BY price');
    expect(order.verdict, SqlVerdict.wrong);
    expect(order.message, contains('정렬'));

    expect(await verdict('update-city', "UPDATE users SET city = 'Busan'"),
        SqlVerdict.wrong);
    expect(
        await verdict('update-city', 'SELECT * FROM users'), SqlVerdict.wrong);
    expect(await verdict('select-all', 'DELETE FROM users'), SqlVerdict.wrong);
  });

  test('문법 오류는 error와 메시지를 돌려준다', () async {
    final result =
        await service.grade(problem('select-all'), 'SELEC * FROM users');
    expect(result.verdict, SqlVerdict.error);
    expect(result.message, contains('syntax error'));

    expect(await verdict('select-all', '-- 주석만'), SqlVerdict.error);
    expect(await verdict('select-all', 'SELECT * FROM nope'), SqlVerdict.error);
  });

  test('채점은 매번 새 DB에서 실행된다', () async {
    await service.grade(problem('select-all'), 'DROP TABLE orders');
    final tables = await service.loadTables();
    expect(tables['orders']!.rows, hasLength(8));
    expect(tables['users']!.columns, ['id', 'name', 'age', 'city']);
    expect(tables['users']!.rows, hasLength(7));
  });

  test('힌트 키워드는 정답 쿼리에서 순서대로 뽑힌다', () {
    expect(problem('where-age').keywords, ['SELECT', 'FROM', 'WHERE']);
    expect(problem('order-limit').keywords,
        ['SELECT', 'FROM', 'ORDER BY', 'DESC', 'LIMIT']);
    expect(
        problem('join-left').keywords, ['SELECT', 'FROM', 'LEFT JOIN', 'ON']);
    expect(problem('join-three').keywords, ['SELECT', 'FROM', 'JOIN', 'ON']);
    expect(
        problem('where-null').keywords, ['SELECT', 'FROM', 'WHERE', 'IS NULL']);
    expect(problem('insert-user').keywords, ['INSERT INTO', 'VALUES']);
    for (final p in kSqlProblems) {
      expect(p.keywords, isNotEmpty, reason: p.id);
    }
  });
}
