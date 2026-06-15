import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/word_data.dart';
import '../../domain/models/word_model.dart';
import '../cubits/word/word_cubit.dart';
import '../cubits/quiz/quiz_cubit.dart';
import '../cubits/progress/progress_cubit.dart';
import '../widgets/category_chip.dart';
import '../widgets/mastery_indicator.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devoca'),
        centerTitle: false,
        actions: [
          _SearchIconButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _SearchBarInline(),
          _TypeToggle(),
          const Expanded(child: _GroupedWordList()),
        ],
      ),
    );
  }
}

// ── 검색 아이콘 & 인라인 검색창 ───────────────────────────────────────────────

class _SearchIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordCubit, WordState>(
      buildWhen: (a, b) => a.searchQuery != b.searchQuery,
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            state.searchQuery.isNotEmpty ? Icons.search_off : Icons.search,
          ),
          onPressed: () {
            if (state.searchQuery.isNotEmpty) {
              context.read<WordCubit>().search('');
            }
          },
          tooltip: '검색',
        );
      },
    );
  }
}

class _SearchBarInline extends StatefulWidget {
  @override
  State<_SearchBarInline> createState() => _SearchBarInlineState();
}

class _SearchBarInlineState extends State<_SearchBarInline> {
  final _controller = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _visible = !_visible);
    if (!_visible) {
      _controller.clear();
      context.read<WordCubit>().search('');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 외부(AppBar 버튼)에서 검색어 초기화 시 같이 닫힘
    return BlocListener<WordCubit, WordState>(
      listenWhen: (a, b) => a.searchQuery != b.searchQuery,
      listener: (_, state) {
        if (state.searchQuery.isEmpty && _visible) {
          _controller.clear();
          setState(() => _visible = false);
        }
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: _visible
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '영어 단어 또는 한국어 의미 검색',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _toggle,
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (v) => context.read<WordCubit>().search(v),
                ),
              )
            : const SizedBox(
                width: double.infinity,
                height: 0,
              ),
      ),
    );
  }
}

// ── 타입 토글 (전체 / 개념 용어 / 코딩 실무) ─────────────────────────────────

class _TypeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordCubit, WordState>(
      buildWhen: (a, b) => a.selectedType != b.selectedType,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              _TypeChip(
                label: '전체',
                value: null,
                selected: state.selectedType == null,
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '개념 용어',
                value: 'concept',
                selected: state.selectedType == 'concept',
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '코딩 실무',
                value: 'practical',
                selected: state.selectedType == 'practical',
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'DB',
                value: 'db',
                selected: state.selectedType == 'db',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = value == 'concept'
        ? const Color(0xFF3B4FBF)
        : value == 'practical'
            ? const Color(0xFF1A7F5A)
            : value == 'db'
                ? const Color(0xFFB05E00)
                : theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => context.read<WordCubit>().filterByType(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(
            color: selected ? color : theme.colorScheme.outline,
            width: selected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color:
                selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── 카테고리 그룹 단어 목록 ────────────────────────────────────────────────────

class _GroupedWordList extends StatelessWidget {
  const _GroupedWordList();

  List<String> _categoriesFor(String? type) {
    if (type == 'concept') return kConceptCategories;
    if (type == 'practical') return kPracticalCategories;
    if (type == 'db') return kDbCategories;
    return kCategories;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordCubit, WordState>(
      builder: (context, state) {
        final categories = _categoriesFor(state.selectedType);

        if (state.searchQuery.isNotEmpty) {
          // 검색 중에는 일반 flat 리스트
          return _FlatWordList(words: state.filteredWords);
        }

        // 카테고리별로 filteredWords 그룹화
        final grouped = <String, List<WordModel>>{};
        for (final cat in categories) {
          final words =
              state.filteredWords.where((w) => w.category == cat).toList();
          if (words.isNotEmpty) grouped[cat] = words;
        }

        if (grouped.isEmpty) {
          return const Center(
            child: Text('단어가 없습니다', style: TextStyle(color: Colors.grey)),
          );
        }

        return BlocBuilder<ProgressCubit, ProgressState>(
          builder: (context, progressState) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // 오늘의 학습 compact 카드
                _DailyCompact(),
                ...grouped.entries.map((entry) => _CategorySection(
                      category: entry.key,
                      words: entry.value,
                      progressState: progressState,
                    )),
              ],
            );
          },
        );
      },
    );
  }
}

// ── 오늘의 학습 (compact) ──────────────────────────────────────────────────────

class _DailyCompact extends StatefulWidget {
  @override
  State<_DailyCompact> createState() => _DailyCompactState();
}

class _DailyCompactState extends State<_DailyCompact> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordCubit, WordState>(
      buildWhen: (_, __) => false,
      builder: (context, _) => BlocBuilder<ProgressCubit, ProgressState>(
        buildWhen: (a, b) =>
            a.todayWordEnglish != b.todayWordEnglish ||
            a.todayDoneCount != b.todayDoneCount,
        builder: (context, state) {
          if (!state.isLoaded || state.todayWordEnglish.isEmpty) {
            return const SizedBox.shrink();
          }

          final wordCubit = context.read<WordCubit>();
          final words = state.todayWordEnglish
              .map((e) => wordCubit.findByEnglish(e))
              .whereType<WordModel>()
              .toList();

          if (words.isEmpty) return const SizedBox.shrink();

          final done = state.todayDoneCount;
          final total = words.length;
          final allDone = done == total;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B4FBF), Color(0xFF5C6EE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4355B9).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // 헤더
                      Row(
                        children: [
                          const Text('☀️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          const Text(
                            '오늘의 학습',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total > 0 ? done / total : 0,
                                minHeight: 4,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  allDone
                                      ? Colors.greenAccent
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            allDone ? '완료 🎉' : '$done/$total',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                      // 펼쳐진 내용
                      if (_expanded) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 82,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: words.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final word = words[i];
                              final seen =
                                  state.isCorrectToday(word.english);
                              return _DailyWordCard(
                                  word: word, seen: seen);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              context
                                  .read<QuizCubit>()
                                  .startQuiz(focusWords: words);
                              context.go('/quiz');
                            },
                            icon: const Icon(Icons.play_arrow_rounded,
                                size: 18),
                            label: Text(
                                allDone ? '퀴즈 다시 풀기' : '오늘의 퀴즈 시작'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3B4FBF),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DailyWordCard extends StatelessWidget {
  final WordModel word;
  final bool seen;

  const _DailyWordCard({required this.word, required this.seen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/word/${word.english}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 108,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: seen
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.12),
          border: Border.all(
            color: Colors.white.withValues(alpha: seen ? 0.5 : 0.25),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (seen) ...[
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.greenAccent, size: 11),
                  const SizedBox(width: 3),
                ],
                Expanded(
                  child: Text(
                    word.english,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              word.koreanPronunciation,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                word.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 카테고리 섹션 (접기/펼치기) ───────────────────────────────────────────────

class _CategorySection extends StatefulWidget {
  final String category;
  final List<WordModel> words;
  final ProgressState progressState;

  const _CategorySection({
    required this.category,
    required this.words,
    required this.progressState,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = CategoryChip.colorFor(widget.category);
    final rawType = kCategoryType[widget.category];
    final typeLabel = rawType == 'concept'
        ? '개념'
        : rawType == 'db'
            ? 'DB'
            : '실무';
    final typeBg = rawType == 'concept'
        ? const Color(0xFF3B4FBF)
        : rawType == 'db'
            ? const Color(0xFFB05E00)
            : const Color(0xFF1A7F5A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: catColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.category,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: typeBg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.words.length}개',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        // 단어 목록
        if (_expanded)
          ...widget.words.map((word) {
            final progress =
                widget.progressState.progressFor(word.english);
            return _WordTile(word: word, progress: progress);
          }),
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

// ── 단어 타일 ─────────────────────────────────────────────────────────────────

class _WordTile extends StatelessWidget {
  final WordModel word;
  final dynamic progress;

  const _WordTile({required this.word, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Row(
        children: [
          Expanded(
            child: Text(
              word.english,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          MasteryIndicator(progress: progress),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            word.koreanPronunciation,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            word.koreanMeaning,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      onTap: () => context.push('/word/${word.english}'),
    );
  }
}

// ── 검색 결과 flat 리스트 ──────────────────────────────────────────────────────

class _FlatWordList extends StatelessWidget {
  final List<WordModel> words;

  const _FlatWordList({required this.words});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, progressState) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: words.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, i) {
            final word = words[i];
            final progress = progressState.progressFor(word.english);
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.english,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    CategoryChip(category: word.category, small: true),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      word.koreanPronunciation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word.koreanMeaning,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: MasteryIndicator(progress: progress),
                onTap: () => context.push('/word/${word.english}'),
              ),
            );
          },
        );
      },
    );
  }
}
