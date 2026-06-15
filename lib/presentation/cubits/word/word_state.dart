part of 'word_cubit.dart';

class WordState extends Equatable {
  final List<WordModel> allWords;
  final List<WordModel> filteredWords;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedType; // 'concept' | 'practical' | null(전체)

  const WordState({
    required this.allWords,
    required this.filteredWords,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedType,
  });

  factory WordState.initial() => const WordState(allWords: [], filteredWords: []);

  WordState copyWith({
    List<WordModel>? allWords,
    List<WordModel>? filteredWords,
    String? searchQuery,
    Object? selectedCategory = _sentinel,
    Object? selectedType = _sentinel,
  }) {
    return WordState(
      allWords: allWords ?? this.allWords,
      filteredWords: filteredWords ?? this.filteredWords,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
      selectedType: selectedType == _sentinel
          ? this.selectedType
          : selectedType as String?,
    );
  }

  @override
  List<Object?> get props =>
      [allWords, filteredWords, searchQuery, selectedCategory, selectedType];
}

const Object _sentinel = Object();
