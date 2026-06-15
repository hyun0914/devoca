import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/quiz/quiz_cubit.dart';
import '../cubits/progress/progress_cubit.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listenWhen: (a, b) =>
          a.status != QuizStatus.answered && b.status == QuizStatus.answered,
      listener: (context, state) {
        if (state.currentWord != null) {
          context.read<ProgressCubit>().recordPractice(
                state.currentWord!.english,
                correct: state.isCorrect,
              );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('퀴즈'),
            actions: [
              if (state.status != QuizStatus.initial)
                TextButton(
                  onPressed: () => context.read<QuizCubit>().reset(),
                  child: const Text('그만하기'),
                ),
            ],
          ),
          body: switch (state.status) {
            QuizStatus.initial => const _StartView(),
            QuizStatus.complete => _ResultView(state: state),
            _ => _QuestionView(state: state),
          },
        );
      },
    );
  }
}

class _StartView extends StatelessWidget {
  const _StartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
            const SizedBox(height: 24),
            Text('단어 퀴즈',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            Text(
              '10개의 단어를 무작위로 출제합니다.\n영어 단어에 해당하는 한국어 의미를 고르세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.6),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => context.read<QuizCubit>().startQuiz(),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('퀴즈 시작'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizState state;
  const _QuestionView({required this.state});

  @override
  Widget build(BuildContext context) {
    final word = state.currentWord;
    if (word == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final progress = (state.currentIndex + 1) / state.totalQuestions;

    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${state.currentIndex + 1} / ${state.totalQuestions}',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.score} 정답',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    word.english,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    word.koreanPronunciation,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                ...List.generate(state.currentChoices.length, (i) {
                  final choice = state.currentChoices[i];
                  final isSelected = state.selectedChoiceIndex == i;
                  final isCorrectChoice = i == state.correctChoiceIndex;

                  Color? bgColor;
                  Color? borderColor;
                  if (state.isAnswered) {
                    if (isCorrectChoice) {
                      bgColor = Colors.green[50];
                      borderColor = Colors.green;
                    } else if (isSelected && !isCorrectChoice) {
                      bgColor = Colors.red[50];
                      borderColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: state.isAnswered
                          ? null
                          : () =>
                              context.read<QuizCubit>().selectAnswer(i),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor ??
                              colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                          border: Border.all(
                            color: borderColor ?? colorScheme.outline,
                            width: isSelected || isCorrectChoice && state.isAnswered
                                ? 2
                                : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bgColor != null
                                    ? borderColor?.withValues(alpha: 0.2)
                                    : colorScheme.surfaceContainerHighest,
                              ),
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: borderColor ?? Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                choice.koreanMeaning,
                                style: const TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ),
                            if (state.isAnswered && isCorrectChoice)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                            if (state.isAnswered && isSelected && !isCorrectChoice)
                              const Icon(Icons.cancel,
                                  color: Colors.red, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                if (state.isAnswered)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.read<QuizCubit>().nextQuestion(),
                      child: Text(
                        state.currentIndex + 1 >= state.totalQuestions
                            ? '결과 보기'
                            : '다음 문제',
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _ResultView extends StatelessWidget {
  final QuizState state;
  const _ResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = state.totalQuestions > 0
        ? (state.score / state.totalQuestions * 100).round()
        : 0;
    final emoji = pct == 100
        ? '🏆'
        : pct >= 70
            ? '👍'
            : '💪';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$pct점',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.totalQuestions}문제 중 ${state.score}개 정답',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => context.read<QuizCubit>().startQuiz(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 풀기'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<QuizCubit>().reset(),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}
