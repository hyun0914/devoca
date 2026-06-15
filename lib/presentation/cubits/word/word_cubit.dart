import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/word_model.dart';
import '../../../data/word_data.dart';

part 'word_state.dart';

class WordCubit extends Cubit<WordState> {
  WordCubit() : super(WordState.initial()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(allWords: kWordList, filteredWords: kWordList));
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilter(query.toLowerCase().trim(), state.selectedCategory, state.selectedType);
  }

  void filterByCategory(String? category) {
    emit(WordState(
      allWords: state.allWords,
      filteredWords: state.filteredWords,
      searchQuery: state.searchQuery,
      selectedCategory: category,
      selectedType: state.selectedType,
    ));
    _applyFilter(state.searchQuery.toLowerCase().trim(), category, state.selectedType);
  }

  void filterByType(String? type) {
    emit(WordState(
      allWords: state.allWords,
      filteredWords: state.filteredWords,
      searchQuery: state.searchQuery,
      selectedCategory: null,
      selectedType: type,
    ));
    _applyFilter(state.searchQuery.toLowerCase().trim(), null, type);
  }

  void _applyFilter(String query, String? category, String? type) {
    var words = state.allWords;
    if (type != null) {
      words = words.where((w) => kCategoryType[w.category] == type).toList();
    }
    if (category != null) {
      words = words.where((w) => w.category == category).toList();
    }
    if (query.isNotEmpty) {
      words = words.where((w) {
        return w.english.toLowerCase().contains(query) ||
            w.koreanMeaning.contains(query) ||
            w.koreanPronunciation.contains(query);
      }).toList();
    }
    emit(state.copyWith(filteredWords: words));
  }

  WordModel? findByEnglish(String english) {
    try {
      return state.allWords.firstWhere((w) => w.english == english);
    } catch (_) {
      return null;
    }
  }
}
