part of 'progress_cubit.dart';

class ProgressState extends Equatable {
  final Map<String, WordProgress> progress;
  final bool isLoaded;
  final List<String> todayWordEnglish;

  const ProgressState({
    required this.progress,
    required this.isLoaded,
    required this.todayWordEnglish,
  });

  factory ProgressState.initial() => const ProgressState(
        progress: {},
        isLoaded: false,
        todayWordEnglish: [],
      );

  int get totalWords => kWordList.length;
  int get masteredCount =>
      kWordList.where((w) => progressFor(w.english).isMastered).length;
  int get inProgressCount =>
      kWordList.where((w) => progressFor(w.english).isInProgress).length;
  int get unstartedCount =>
      kWordList.where((w) => progressFor(w.english).isUnstarted).length;
  int get intervalReadyCount =>
      kWordList.where((w) => progressFor(w.english).isInProgress && progressFor(w.english).isIntervalReady).length;
  int get totalCorrect =>
      progress.values.fold(0, (sum, p) => sum + p.timesCorrect);

  // 오늘 철자를 정확히 맞춘 단어 수 (lastCorrect가 오늘 날짜인 경우)
  int get todayDoneCount =>
      todayWordEnglish.where((e) => isCorrectToday(e)).length;

  bool isCorrectToday(String english) {
    final lc = progress[english]?.lastCorrect;
    if (lc == null) return false;
    final now = DateTime.now();
    return lc.year == now.year && lc.month == now.month && lc.day == now.day;
  }

  WordProgress progressFor(String english) =>
      progress[english] ?? WordProgress(english: english);

  ProgressState copyWith({
    Map<String, WordProgress>? progress,
    bool? isLoaded,
    List<String>? todayWordEnglish,
  }) {
    return ProgressState(
      progress: progress ?? this.progress,
      isLoaded: isLoaded ?? this.isLoaded,
      todayWordEnglish: todayWordEnglish ?? this.todayWordEnglish,
    );
  }

  @override
  List<Object?> get props => [progress, isLoaded, todayWordEnglish];
}
