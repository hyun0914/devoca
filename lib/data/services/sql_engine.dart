import 'package:sqlite3/common.dart';
import '../../domain/models/sql_result.dart';
import 'sqlite_loader_native.dart'
    if (dart.library.js_interop) 'sqlite_loader_web.dart';

class SqlEngine {
  static final SqlEngine instance = SqlEngine();

  Future<CommonSqlite3>? _loading;

  /// 매번 새 인메모리 DB를 열고 [seedSql]로 초기 상태를 만든다.
  Future<SqlSession> open({String seedSql = ''}) async {
    final sqlite = await (_loading ??= loadSqlite());
    final db = sqlite.openInMemory();
    if (seedSql.isNotEmpty) db.execute(seedSql);
    return SqlSession._(db);
  }
}

class SqlSession {
  final CommonDatabase _db;
  SqlSession._(this._db);

  /// 문법 오류 등은 [SqliteException]으로 던져진다.
  SqlResult run(String sql) {
    final result = _db.select(sql);
    return SqlResult(
      result.columnNames,
      [for (final row in result.rows) List<Object?>.of(row)],
    );
  }

  void close() => _db.close();
}
