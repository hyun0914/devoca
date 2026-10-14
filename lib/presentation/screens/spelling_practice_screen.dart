import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/tts_service.dart';
import '../../data/word_data.dart';
import '../../domain/models/word_model.dart';
import '../cubits/progress/progress_cubit.dart';
import '../widgets/category_chip.dart';

class SpellingPracticeScreen extends StatefulWidget {
  final String english;

  /// 오늘의 학습에서 카드를 보지 않고 바로 들어온 경우
  final bool fromDaily;

  const SpellingPracticeScreen({
    super.key,
    required this.english,
    this.fromDaily = false,
  });

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

  bool get _caseSensitive =>
      _word != null && isCaseSensitiveCategory(_word!.category);

  bool get _isCorrect {
    final answer = _word?.english;
    if (answer == null) return false;
    return _caseSensitive
        ? _typed == answer
        : _typed.toLowerCase() == answer.toLowerCase();
  }

  void _onChanged(String value) {
    final word = _word;
    if (word == null) return;
    final capped = value.length > word.english.length
        ? value.substring(0, word.english.length)
        : value;
    if (capped != value) {
      _controller.value = _controller.value.copyWith(text: capped);
    }
    setState(() => _typed = capped);
  }

  // 글자별 정답은 제출한 뒤에만 보여준다. 입력 중에 보여주면 찍어서 맞출 수 있다.
  void _submit() {
    if (_submitted || _typed.isEmpty) return;
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
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text('단어를 찾을 수 없습니다')));
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
              // 키보드가 올라오면 높이가 부족해지므로 스크롤 가능하게 둔다
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CategoryChip(category: word.category),
                    const SizedBox(height: 24),
                    _HintCard(word: word, caseSensitive: _caseSensitive),
                    const SizedBox(height: 32),
                    _LetterBoxes(
                      word: word.english,
                      caseSensitive: _caseSensitive,
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
                        // 키보드 추천 단어에 정답 철자가 뜨지 않도록 끈다
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onChanged: _onChanged,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _typed.isEmpty ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('확인'),
                        ),
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
                            child: widget.fromDaily
                                ? FilledButton.icon(
                                    onPressed: () => context.pushReplacement(
                                        '/word/${word.english}'),
                                    icon: const Icon(Icons.style_rounded),
                                    label: const Text('단어 카드 보기'),
                                  )
                                : FilledButton.icon(
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
  final bool caseSensitive;
  const _HintCard({required this.word, required this.caseSensitive});

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
          const SizedBox(height: 4),
          // 한글 발음만으로는 cache/cash처럼 철자를 구분할 수 없어 실제 발음을 들려준다
          TextButton.icon(
            onPressed: () => TtsService.instance.speak(word.english),
            icon: const Icon(Icons.volume_up_rounded, size: 20),
            label: const Text('발음 듣기'),
          ),
          Text(
            caseSensitive
                ? '${word.english.length}자 · 대소문자 구분'
                : '${word.english.length}자',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _LetterBoxes extends StatelessWidget {
  final String word;
  final bool caseSensitive;
  final String typed;
  final bool submitted;

  const _LetterBoxes({
    required this.word,
    required this.caseSensitive,
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
            (caseSensitive
                ? typedChar == word[i]
                : typedChar.toLowerCase() == word[i].toLowerCase());

        Color bgColor;
        Color borderColor;
        Color textColor;

        if (typedChar.isEmpty) {
          bgColor = Colors.grey[100]!;
          borderColor = Colors.grey[300]!;
          textColor = Colors.grey[400]!;
        } else if (!submitted) {
          bgColor = Colors.white;
          borderColor = Colors.grey[600]!;
          textColor = Colors.grey[900]!;
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
            // 대소문자도 철자의 일부라 입력한 그대로 보여준다
            typedChar.isNotEmpty ? typedChar : (submitted ? word[i] : ''),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  submitted && typedChar.isEmpty ? Colors.grey[400] : textColor,
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
