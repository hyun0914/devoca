import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/word_model.dart';
import '../../../data/word_data.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(QuizState.initial());

  static const _questionsPerSession = 10;

  // focusWords: 오늘의 단어 퀴즈처럼 특정 단어만 출제할 때 사용
  // null이면 전체 단어 풀에서 랜덤 10개
  void startQuiz({List<WordModel>? focusWords}) {
    final random = Random();
    final pool = focusWords ?? kWordList;

    final shuffled = [...pool]..shuffle(random);
    final questions = shuffled.take(_questionsPerSession).toList();

    // 오답 보기는 항상 전체 단어에서 뽑아서 선택지 4개를 보장
    final allChoices = questions.map((q) {
      final distractors = kWordList.where((w) => w != q).toList()
        ..shuffle(random);
      final choices = [q, ...distractors.take(3)]..shuffle(random);
      return choices;
    }).toList();

    emit(QuizState(
      status: QuizStatus.inProgress,
      questions: questions,
      allChoices: allChoices,
      currentIndex: 0,
      selectedChoiceIndex: null,
      score: 0,
    ));
  }

  void selectAnswer(int choiceIndex) {
    if (state.status != QuizStatus.inProgress) return;
    final correct = state.currentChoices[choiceIndex] == state.currentWord;
    emit(state.copyWith(
      status: QuizStatus.answered,
      selectedChoiceIndex: choiceIndex,
      score: state.score + (correct ? 1 : 0),
    ));
  }

  void nextQuestion() {
    if (state.status != QuizStatus.answered) return;
    final next = state.currentIndex + 1;
    if (next >= state.totalQuestions) {
      emit(state.copyWith(status: QuizStatus.complete));
    } else {
      emit(state.copyWith(
        status: QuizStatus.inProgress,
        currentIndex: next,
        selectedChoiceIndex: null,
      ));
    }
  }

  void reset() => emit(QuizState.initial());
}
