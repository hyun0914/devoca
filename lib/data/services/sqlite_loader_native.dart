import 'package:sqlite3/sqlite3.dart';

// 앱은 웹 전용이지만 flutter test(VM)에서 같은 엔진을 돌리기 위한 로더
Future<CommonSqlite3> loadSqlite() async => sqlite3;
