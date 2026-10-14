import 'package:devoca/data/word_data.dart';
import 'package:devoca/main.dart';
import 'package:devoca/presentation/cubits/progress/progress_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('오늘의 학습은 영단어를 숨기고 바로 철자 연습으로 보낸다', (tester) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DevocaApp());
    await tester.pumpAndSettle();

    final progress =
        tester.element(find.byType(Scaffold).first).read<ProgressCubit>();
    final word = kWordList
        .firstWhere((w) => w.english == progress.state.todayWordEnglish.first);

    final englishBefore = find.text(word.english).evaluate().length;
    final pronunciationBefore =
        find.text(word.koreanPronunciation).evaluate().length;
    await tester.tap(find.text('오늘의 학습'));
    await tester.pumpAndSettle();
    expect(find.text(word.english).evaluate().length, englishBefore);
    expect(find.text(word.koreanPronunciation).evaluate().length,
        pronunciationBefore + 1);

    await tester.tap(find.text(word.koreanPronunciation).last);
    await tester.pumpAndSettle();
    expect(find.text('철자 연습'), findsOneWidget);
    expect(find.text('확인'), findsOneWidget);

    await tester.enterText(find.byType(TextField), word.english);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('정답입니다!'), findsOneWidget);

    await tester.tap(find.text('단어 카드 보기'));
    await tester.pumpAndSettle();
    expect(find.text('철자 연습하기'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    // 맞힌 뒤에는 오늘의 학습 카드에 영단어가 보인다
    expect(find.text(word.english).evaluate().length, englishBefore + 1);
  });
}
