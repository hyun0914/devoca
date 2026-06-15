part of 'quiz_cubit.dart';

enum QuizStatus { initial, inProgress, answered, complete }

class QuizState extends Equatable {
  final QuizStatus status;
  final List<WordModel> questions;
  final List<List<WordModel>> allChoices;
  final int currentIndex;
  final int? selectedChoiceIndex;
  final int score;

  const QuizState({
    required this.status,
    required this.questions,
    required this.allChoices,
    required this.currentIndex,
    required this.selectedChoiceIndex,
    required this.score,
  });

  factory QuizState.initial() => const QuizState(
        status: QuizStatus.initial,
        questions: [],
        allChoices: [],
        currentIndex: 0,
        selectedChoiceIndex: null,
        score: 0,
      );

  WordModel? get currentWord =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  List<WordModel> get currentChoices =>
      currentIndex < allChoices.length ? allChoices[currentIndex] : [];

  bool get isAnswered => selectedChoiceIndex != null;

  bool get isCorrect =>
      selectedChoiceIndex != null &&
      currentChoices[selectedChoiceIndex!] == currentWord;

  int get correctChoiceIndex =>
      currentWord != null ? currentChoices.indexOf(currentWord!) : -1;

  int get totalQuestions => questions.length;

  QuizState copyWith({
    QuizStatus? status,
    List<WordModel>? questions,
    List<List<WordModel>>? allChoices,
    int? currentIndex,
    Object? selectedChoiceIndex = _quizSentinel,
    int? score,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      allChoices: allChoices ?? this.allChoices,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedChoiceIndex: selectedChoiceIndex == _quizSentinel
          ? this.selectedChoiceIndex
          : selectedChoiceIndex as int?,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props =>
      [status, questions, allChoices, currentIndex, selectedChoiceIndex, score];
}

const Object _quizSentinel = Object();
