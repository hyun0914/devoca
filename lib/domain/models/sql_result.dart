class SqlResult {
  final List<String> columns;
  final List<List<Object?>> rows;

  const SqlResult(this.columns, this.rows);
}
