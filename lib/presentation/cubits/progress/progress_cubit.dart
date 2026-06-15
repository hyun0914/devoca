import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/word_data.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/models/progress_model.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final ProgressRepository _repo;

  ProgressCubit(this._repo) : super(ProgressState.initial()) {
    _load();
  }

  static const _dailyCount = 5;

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    final progress = await _repo.loadAll();
    final today = _todayKey;
    var todayWords = await _repo.loadDailyWords(today);
    if (todayWords == null) {
      todayWords = _computeTodayWords(progress);
      await _repo.saveDailyWords(today, todayWords);
    }
    emit(state.copyWith(
      progress: progress,
      isLoaded: true,
      todayWordEnglish: todayWords,
    ));
  }

  // 우선순위: 미학습 → 학습중(lastCorrect 오래된 순) → 마스터(랜덤)
  List<String> _computeTodayWords(Map<String, WordProgress> progress) {
    final seed = int.parse(_todayKey.replaceAll('-', ''));
    final rng = Random(seed);

    final unstarted = <MapEntry<String, DateTime?>>[];
    final inProgressReady = <MapEntry<String, DateTime>>[];   // 인터벌 도전 가능
    final inProgressWaiting = <MapEntry<String, DateTime>>[]; // 아직 대기 중
    final mastered = <String>[];

    for (final word in kWordList) {
      final p = progress[word.english];
      if (p == null || p.isUnstarted) {
        unstarted.add(MapEntry(word.english, p?.lastSeen));
      } else if (p.isInProgress) {
        if (p.isIntervalReady) {
          inProgressReady.add(MapEntry(word.english, p.lastCorrect!));
        } else {
          inProgressWaiting.add(MapEntry(word.english, p.lastCorrect!));
        }
      } else {
        mastered.add(word.english);
      }
    }

    unstarted.sort((a, b) {
      if (a.value == null && b.value == null) return 0;
      if (a.value == null) return -1;
      if (b.value == null) return 1;
      return a.value!.compareTo(b.value!);
    });
    // 인터벌 가능한 것: lastCorrect 오래된 순
    inProgressReady.sort((a, b) => a.value.compareTo(b.value));
    // 대기 중인 것: lastCorrect 최신 순 (가장 최근 배운 것 복습)
    inProgressWaiting.sort((a, b) => b.value.compareTo(a.value));
    final inProgress = [...inProgressReady, ...inProgressWaiting];
    mastered.shuffle(rng);

    return [
      ...unstarted.map((e) => e.key),
      ...inProgress.map((e) => e.key),
      ...mastered,
    ].take(_dailyCount).toList();
  }

  Future<void> recordPractice(String english, {required bool correct}) async {
    final current = state.progressFor(english);
    final now = DateTime.now();

    int newIntervalCorrects = current.intervalCorrects;
    if (correct) {
      // 마지막 정답으로부터 4일 이상 지났거나 처음 정답이면 인터벌 카운트 증가
      final daysSinceLast = current.lastCorrect == null
          ? WordProgress.intervalDays // 처음이면 무조건 카운트
          : now.difference(current.lastCorrect!).inDays;
      if (daysSinceLast >= WordProgress.intervalDays) {
        newIntervalCorrects += 1;
      }
    }

    final updated = WordProgress(
      english: english,
      timesPracticed: current.timesPracticed + 1,
      timesCorrect: current.timesCorrect + (correct ? 1 : 0),
      intervalCorrects: newIntervalCorrects,
      lastSeen: now,
      lastCorrect: correct ? now : current.lastCorrect,
    );

    final newMap = Map<String, WordProgress>.from(state.progress)
      ..[english] = updated;
    emit(state.copyWith(progress: newMap));
    await _repo.saveAll(newMap);
  }
}
