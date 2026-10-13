import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/services/sql_practice_service.dart';
import '../../../domain/models/sql_problem.dart';
import '../../../domain/models/sql_result.dart';

part 'sql_practice_state.dart';

class SqlPracticeCubit extends Cubit<SqlPracticeState> {
  final SqlPracticeService _service;
  final ProgressRepository _repo;

  SqlPracticeCubit(this._service, this._repo)
      : super(const SqlPracticeState()) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _repo.loadSolvedSqlIds();
    if (isClosed) return;
    emit(state.copyWith(solvedIds: {...saved, ...state.solvedIds}));
  }

  void openProblem(String problemId) {
    emit(SqlPracticeState(problemId: problemId, solvedIds: state.solvedIds));
  }

  Future<void> submit(SqlProblem problem, String sql) async {
    if (state.status == SqlPracticeStatus.running) return;
    if (sql.trim().isEmpty) return;
    emit(state.copyWith(status: SqlPracticeStatus.running));

    final SqlGradeResult result;
    try {
      result = await _service.grade(problem, sql);
    } catch (e) {
      if (state.problemId != problem.id) return;
      emit(state.copyWith(
        status: SqlPracticeStatus.error,
        output: null,
        message: 'SQL 엔진을 불러오지 못했습니다. ($e)',
      ));
      return;
    }
    // 채점 중에 다른 문제로 이동했으면 결과를 버린다
    if (state.problemId != problem.id) return;

    emit(state.copyWith(
      status: switch (result.verdict) {
        SqlVerdict.correct => SqlPracticeStatus.correct,
        SqlVerdict.wrong => SqlPracticeStatus.wrong,
        SqlVerdict.error => SqlPracticeStatus.error,
      },
      output: result.output,
      message: result.message,
      solvedIds: result.verdict == SqlVerdict.correct
          ? {...state.solvedIds, problem.id}
          : null,
    ));
    if (result.verdict == SqlVerdict.correct) {
      await _repo.saveSolvedSqlIds(state.solvedIds);
    }
  }
}
