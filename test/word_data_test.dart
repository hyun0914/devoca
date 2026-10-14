import 'package:devoca/data/word_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('영단어는 철자 기준으로 겹치지 않는다', () {
    final spellings = kWordList.map((w) => w.english).toList();
    expect(spellings.toSet(), hasLength(spellings.length));
  });

  test('철자 문제로 쓰기 어려운 기호가 없다', () {
    final odd = kWordList
        .map((w) => w.english)
        .where((e) => RegExp(r'[/()?:]|\bvs\b').hasMatch(e))
        .toList();
    expect(odd, isEmpty);
  });

  test('모든 단어의 카테고리가 등록되어 있다', () {
    for (final word in kWordList) {
      expect(kCategories, contains(word.category), reason: word.english);
      expect(kCategoryType, contains(word.category), reason: word.english);
    }
  });
}
