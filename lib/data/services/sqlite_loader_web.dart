import 'package:sqlite3/wasm.dart';

// web/sqlite3.wasm 은 pubspec의 sqlite3 버전과 같은 릴리스 파일이어야 함
Future<CommonSqlite3> loadSqlite() async {
  final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return sqlite;
}
