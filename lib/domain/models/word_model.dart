import 'package:equatable/equatable.dart';

class WordModel extends Equatable {
  final String english;
  final String koreanPronunciation;
  final String koreanMeaning;
  final String exampleSentence;
  final String category;

  const WordModel({
    required this.english,
    required this.koreanPronunciation,
    required this.koreanMeaning,
    required this.exampleSentence,
    required this.category,
  });

  @override
  List<Object?> get props => [english];
}
