import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/word_data.dart';
import '../../domain/models/word_model.dart';
import '../cubits/progress/progress_cubit.dart';
import '../widgets/category_chip.dart';

class SpellingPracticeScreen extends StatefulWidget {
  final String english;
  const SpellingPracticeScreen({super.key, required this.english});

  @override
  State<SpellingPracticeScreen> createState() => _SpellingPracticeScreenState();
}

class _SpellingPracticeScreenState extends State<SpellingPracticeScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _typed = '';
  bool _submitted = false;
  bool _resultSaved = false;

  WordModel? get _word {
    try {
      return kWordList.firstWhere((w) => w.english == widget.english);
    } catch (_) {
      return null;
    }
  }

  bool get _isCorrect => _typed.toLowerCase() == _word?.english.toLowerCase();

  void _onChanged(String value) {
    final word = _word;
    if (word == null) return;
    final capped = value.length > word.english.length
        ? value.substring(0, word.english.length)
        : value;
    if (capped != value) _controller.value = _controller.value.copyWith(text: capped);
    setState(() => _typed = capped);

    if (capped.length == word.english.length && !_submitted) {
      _submit();
    }
  }

  void _submit() {
    if (_submitted) return;
    setState(() => _submitted = true);
    if (!_resultSaved) {
      _resultSaved = true;
      context.read<ProgressCubit>().recordPractice(
            widget.english,
            correct: _isCorrect,
          );
    }
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _typed = '';
      _submitted = false;
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    if (word == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('단어를 찾을 수 없습니다')));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('철자 연습'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CategoryChip(category: word.category),
                    const SizedBox(height: 24),
                    _HintCard(word: word),
                    const SizedBox(height: 32),
                    _LetterBoxes(
                      word: word.english,
                      typed: _typed,
                      submitted: _submitted,
                    ),
                    const SizedBox(height: 24),
                    if (!_submitted) ...[
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: '여기에 철자를 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, letterSpacing: 2),
                        onChanged: _onChanged,
                      ),
                    ] else ...[
                      _ResultBanner(correct: _isCorrect, answer: word.english),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _reset,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('다시 도전'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('단어 카드로'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final WordModel word;
  const _HintCard({required this.word});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            word.koreanPronunciation,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.koreanMeaning,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            '${word.english.length}자',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _LetterBoxes extends StatelessWidget {
  final String word;
  final String typed;
  final bool submitted;

  const _LetterBoxes({
    required this.word,
    required this.typed,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(word.length, (i) {
        final typedChar = i < typed.length ? typed[i] : '';
        final correct = typedChar.isNotEmpty &&
            typedChar.toLowerCase() == word[i].toLowerCase();

        Color bgColor;
        Color borderColor;
        Color textColor;

        if (typedChar.isEmpty) {
          bgColor = Colors.grey[100]!;
          borderColor = Colors.grey[300]!;
          textColor = Colors.grey[400]!;
        } else if (correct) {
          bgColor = Colors.green[50]!;
          borderColor = Colors.green;
          textColor = Colors.green[800]!;
        } else {
          bgColor = Colors.red[50]!;
          borderColor = Colors.red;
          textColor = Colors.red[800]!;
        }

        return Container(
          width: 40,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            typedChar.isNotEmpty
                ? typedChar.toUpperCase()
                : (submitted ? word[i].toUpperCase() : ''),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: submitted && typedChar.isEmpty ? Colors.grey[400] : textColor,
            ),
          ),
        );
      }),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final bool correct;
  final String answer;

  const _ResultBanner({required this.correct, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? Colors.green[50] : Colors.red[50],
        border: Border.all(color: correct ? Colors.green : Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: correct ? Colors.green[700] : Colors.red[700],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? '정답입니다!' : '아쉽네요!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: correct ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                if (!correct) ...[
                  const SizedBox(height: 2),
                  Text(
                    '정답: $answer',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
