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

  @override
  List<Object?> get props =>
      [id, category, title, description, answerSql, ordered, targetTable];
}
