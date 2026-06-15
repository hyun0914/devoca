import 'package:equatable/equatable.dart';

class WordProgress extends Equatable {
  final String english;
  final int timesPracticed;
  final int timesCorrect;
  /// 4일 이상 간격을 두고 정답을 맞춘 횟수.
  /// 마스터 기준: intervalCorrects >= 3
  final int intervalCorrects;
  final DateTime? lastSeen;
  final DateTime? lastCorrect;

  const WordProgress({
    required this.english,
    this.timesPracticed = 0,
    this.timesCorrect = 0,
    this.intervalCorrects = 0,
    this.lastSeen,
    this.lastCorrect,
  });

  static const int masterThreshold = 3;
  static const int intervalDays = 4;

  bool get isMastered => intervalCorrects >= masterThreshold;
  bool get isInProgress => timesCorrect > 0 && !isMastered;
  bool get isUnstarted => timesCorrect == 0;

  /// 다음 인터벌까지 남은 일수. 0이면 지금 도전 가능.
  int daysUntilNextInterval() {
    if (lastCorrect == null) return 0;
    final diff = DateTime.now().difference(lastCorrect!).inDays;
    final remaining = intervalDays - diff;
    return remaining > 0 ? remaining : 0;
  }

  bool get isIntervalReady => daysUntilNextInterval() == 0;

  Map<String, dynamic> toJson() => {
        'english': english,
        'timesPracticed': timesPracticed,
        'timesCorrect': timesCorrect,
        'intervalCorrects': intervalCorrects,
        'lastSeen': lastSeen?.toIso8601String(),
        'lastCorrect': lastCorrect?.toIso8601String(),
      };

  factory WordProgress.fromJson(Map<String, dynamic> json) => WordProgress(
        english: json['english'] as String,
        timesPracticed: (json['timesPracticed'] as num?)?.toInt() ?? 0,
        timesCorrect: (json['timesCorrect'] as num?)?.toInt() ?? 0,
        intervalCorrects: (json['intervalCorrects'] as num?)?.toInt() ?? 0,
        lastSeen: json['lastSeen'] != null
            ? DateTime.tryParse(json['lastSeen'] as String)
            : null,
        lastCorrect: json['lastCorrect'] != null
            ? DateTime.tryParse(json['lastCorrect'] as String)
            : null,
      );

  @override
  List<Object?> get props =>
      [english, timesPracticed, timesCorrect, intervalCorrects, lastSeen, lastCorrect];
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
