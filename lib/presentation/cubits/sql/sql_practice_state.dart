part of 'sql_practice_cubit.dart';

enum SqlPracticeStatus { idle, running, correct, wrong, error }

class SqlPracticeState extends Equatable {
  final String? problemId;
  final SqlPracticeStatus status;
  final SqlResult? output;
  final String? message;
  final Set<String> solvedIds;

  const SqlPracticeState({
    this.problemId,
    this.status = SqlPracticeStatus.idle,
    this.output,
    this.message,
    this.solvedIds = const {},
  });

  SqlPracticeState copyWith({
    SqlPracticeStatus? status,
    Object? output = _sqlSentinel,
    Object? message = _sqlSentinel,
    Set<String>? solvedIds,
  }) {
    return SqlPracticeState(
      problemId: problemId,
      status: status ?? this.status,
      output: output == _sqlSentinel ? this.output : output as SqlResult?,
      message: message == _sqlSentinel ? this.message : message as String?,
      solvedIds: solvedIds ?? this.solvedIds,
    );
  }

  @override
  List<Object?> get props => [problemId, status, output, message, solvedIds];
}

const Object _sqlSentinel = Object();
