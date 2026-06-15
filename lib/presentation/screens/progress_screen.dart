import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/word_data.dart';
import '../../domain/models/progress_model.dart';
import '../../domain/models/word_model.dart';
import '../cubits/progress/progress_cubit.dart';
import '../widgets/category_chip.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _showCriteriaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CriteriaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 현황'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: '학습 기준 안내',
            onPressed: () => _showCriteriaSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final hp = isWide ? 40.0 : 16.0;

            // 단어를 상태별로 분류
            final mastered = <WordModel>[];
            final inProgress = <WordModel>[];
            final unstarted = <WordModel>[];

            for (final word in kWordList) {
              final p = state.progressFor(word.english);
              if (p.isMastered) {
                mastered.add(word);
              } else if (p.isInProgress) {
                inProgress.add(word);
              } else {
                unstarted.add(word);
              }
            }

            // 학습 중: lastCorrect 오래된 순 (리뷰가 가장 필요한 것 먼저)
            inProgress.sort((a, b) {
              final pa = state.progressFor(a.english).lastCorrect;
              final pb = state.progressFor(b.english).lastCorrect;
              if (pa == null && pb == null) return 0;
              if (pa == null) return -1;
              if (pb == null) return 1;
              return pa.compareTo(pb);
            });

            return CustomScrollView(
              slivers: [
                // ── 상단 통계 ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hp, 16, hp, 8),
                    child: _StatsRow(state: state),
                  ),
                ),

                // ── 마스터 섹션 ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.star_rounded,
                    color: Colors.amber[700]!,
                    label: '마스터',
                    count: mastered.length,
                    hint: '4일 간격 × 3회',
                    hp: hp,
                  ),
                ),
                if (mastered.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyHint(
                      message: '아직 마스터한 단어가 없어요.\n철자를 여러 날에 걸쳐 맞추면 마스터됩니다.',
                      hp: hp,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _WordTile(
                        word: mastered[i],
                        progress: state.progressFor(mastered[i].english),
                        status: _Status.mastered,
                        hp: hp,
                      ),
                      childCount: mastered.length,
                    ),
                  ),

                // ── 학습 중 섹션 ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.menu_book_rounded,
                    color: Colors.blue[600]!,
                    label: '학습 중',
                    count: inProgress.length,
                    hint: '정답 1회 이상',
                    hp: hp,
                  ),
                ),
                if (inProgress.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyHint(
                      message: '철자 연습에서 한 번 맞추면 여기에 나타나요.',
                      hp: hp,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _WordTile(
                        word: inProgress[i],
                        progress: state.progressFor(inProgress[i].english),
                        status: _Status.inProgress,
                        hp: hp,
                      ),
                      childCount: inProgress.length,
                    ),
                  ),

                // ── 미학습 섹션 ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.lock_outline_rounded,
                    color: Colors.grey[500]!,
                    label: '미학습',
                    count: unstarted.length,
                    hint: '아직 맞춘 적 없음',
                    hp: hp,
                  ),
                ),
                _UnstartedSection(words: unstarted, state: state, hp: hp),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          });
        },
      ),
    );
  }
}

// ── 상단 요약 통계 ──────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final ProgressState state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          value: '${state.totalWords}',
          label: '전체',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        _StatChip(
          value: '${state.masteredCount}',
          label: '마스터',
          color: Colors.amber[700]!,
        ),
        const SizedBox(width: 8),
        _StatChip(
          value: '${state.inProgressCount}',
          label: '학습 중',
          color: Colors.blue[600]!,
        ),
        const SizedBox(width: 8),
        _StatChip(
          value: '${state.totalCorrect}',
          label: '총 정답',
          color: Colors.green[700]!,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatChip({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 섹션 헤더 ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final String hint;
  final double hp;

  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.hint,
    required this.hp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 20, hp, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          Text(
            hint,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ── 단어 타일 ────────────────────────────────────────────────────────────────

enum _Status { mastered, inProgress, unstarted }

class _WordTile extends StatelessWidget {
  final WordModel word;
  final dynamic progress;
  final _Status status;
  final double hp;

  const _WordTile({
    required this.word,
    required this.progress,
    required this.status,
    required this.hp,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = switch (status) {
      _Status.mastered => Colors.amber[700]!,
      _Status.inProgress => Colors.blue[600]!,
      _Status.unstarted => Colors.grey[400]!,
    };

    final IconData statusIcon = switch (status) {
      _Status.mastered => Icons.star_rounded,
      _Status.inProgress => Icons.check_circle_rounded,
      _Status.unstarted => Icons.radio_button_unchecked_rounded,
    };

    String? sub;
    if (status == _Status.mastered) {
      sub = '인터벌 ${progress.intervalCorrects}회 완료 · 정답 ${progress.timesCorrect}회';
    } else if (status == _Status.inProgress) {
      final intervalStr = '${progress.intervalCorrects}/${WordProgress.masterThreshold}회 인터벌';
      if (progress.isIntervalReady) {
        sub = '🔔 지금 도전 가능! · $intervalStr';
      } else {
        final daysLeft = progress.daysUntilNextInterval();
        sub = '$daysLeft일 후 인터벌 가능 · $intervalStr';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 2),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(statusIcon, color: accentColor, size: 20),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  word.english,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              CategoryChip(category: word.category, small: true),
            ],
          ),
          subtitle: sub != null
              ? Text(
                  sub,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                )
              : null,
          onTap: () => context.push('/word/${word.english}'),
        ),
      ),
    );
  }
}

// ── 미학습 섹션 (기본 접힘) ──────────────────────────────────────────────────

class _UnstartedSection extends StatefulWidget {
  final List<WordModel> words;
  final ProgressState state;
  final double hp;

  const _UnstartedSection({
    required this.words,
    required this.state,
    required this.hp,
  });

  @override
  State<_UnstartedSection> createState() => _UnstartedSectionState();
}

class _UnstartedSectionState extends State<_UnstartedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyHint(message: '모든 단어를 한 번 이상 맞췄어요! 🎉', hp: widget.hp),
      );
    }

    // SliverToBoxAdapter 안에 전부 넣어야 해서 Column 사용
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // 펼치기/접기 버튼
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.hp, vertical: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _expanded
                          ? '접기'
                          : '${widget.words.length}개 보기',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            ...widget.words.map((word) => _WordTile(
                  word: word,
                  progress: widget.state.progressFor(word.english),
                  status: _Status.unstarted,
                  hp: widget.hp,
                )),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  final double hp;
  const _EmptyHint({required this.message, required this.hp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 4, hp, 4),
      child: Text(
        message,
        style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
      ),
    );
  }
}

// ── 학습 기준 안내 바텀시트 ──────────────────────────────────────────────────

class _CriteriaSheet extends StatelessWidget {
  const _CriteriaSheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            '학습 기준 안내',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _CriteriaRow(
            icon: Icons.lock_outline_rounded,
            color: Colors.grey[500]!,
            title: '미학습',
            description: '철자 연습에서 아직 한 번도 정답을 맞추지 못한 단어',
          ),
          const SizedBox(height: 14),
          _CriteriaRow(
            icon: Icons.check_circle_rounded,
            color: Colors.blue[600]!,
            title: '학습 중',
            description: '철자를 1번 이상 완전히 맞춘 단어',
          ),
          const SizedBox(height: 14),
          _CriteriaRow(
            icon: Icons.star_rounded,
            color: Colors.amber[700]!,
            title: '마스터',
            description: '아래 사이클을 3회 완료한 단어\n  • 1회차: 처음 정답\n  • 2회차: 4일 이상 뒤 다시 정답\n  • 3회차: 또 4일 이상 뒤 다시 정답',
          ),
          const SizedBox(height: 16),
          // 타임라인 예시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('예시', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _TimelineItem(day: 'Day 1', label: '1회차 정답 ✓', color: Colors.blue[400]!),
                _TimelineItem(day: 'Day 5+', label: '2회차 정답 ✓  (4일 이상 뒤)', color: Colors.blue[600]!),
                _TimelineItem(day: 'Day 9+', label: '3회차 정답 ✓  (4일 이상 뒤)', color: Colors.amber[700]!, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              border: Border.all(color: Colors.amber[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_rounded, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '4일 이내에 맞춰도 인터벌 횟수가 오르지 않아요.\n충분한 간격을 두고 다시 맞춰야 장기 기억이 됩니다.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String day;
  final String label;
  final Color color;
  final bool isLast;

  const _TimelineItem({
    required this.day,
    required this.label,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.grey[200]),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _CriteriaRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[700], height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
