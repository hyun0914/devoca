import 'dart:convert';

import 'package:devoca/data/repositories/progress_repository.dart';
import 'package:devoca/data/word_data.dart';
import 'package:devoca/presentation/cubits/progress/progress_cubit.dart';
import 'package:devoca/presentation/screens/spelling_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('철자 연습 화면', () {
    late ProgressCubit cubit;

    Future<void> pump(WidgetTester tester) async {
      cubit = ProgressCubit(ProgressRepository());
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
              home: SpellingPracticeScreen(english: 'commit')),
        ),
      );
      await tester.pumpAndSettle();
    }

    Color borderOf(WidgetTester tester, String letter) {
      final box = tester.widget<Container>(
        find
            .ancestor(of: find.text(letter), matching: find.byType(Container))
            .first,
      );
      return ((box.decoration as BoxDecoration).border as Border).top.color;
    }

    testWidgets('다 입력해도 확인 전에는 정답 여부를 보여주지 않는다', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'cxmmit');
      await tester.pump();

      expect(find.text('정답입니다!'), findsNothing);
      expect(find.text('아쉽네요!'), findsNothing);
      expect(borderOf(tester, 'x'), isNot(Colors.red));
      expect(borderOf(tester, 'c'), isNot(Colors.green));
      expect(cubit.state.progressFor('commit').timesPracticed, 0);
    });

    testWidgets('확인을 누르면 채점하고 기록한다', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'cxmmit');
      await tester.pump();
      await tester.tap(find.text('확인'));
      await tester.pump();

      expect(find.text('아쉽네요!'), findsOneWidget);
      expect(borderOf(tester, 'x'), Colors.red);
      final p = cubit.state.progressFor('commit');
      expect(p.timesPracticed, 1);
      expect(p.timesCorrect, 0);
    });

    testWidgets('개념 용어는 대소문자를 구분하지 않는다', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'COMMIT');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('정답입니다!'), findsOneWidget);
      expect(find.textContaining('대소문자 구분'), findsNothing);
    });

    testWidgets('코딩 실무 단어는 대소문자까지 맞아야 정답', (tester) async {
      cubit = ProgressCubit(ProgressRepository());
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
              home: SpellingPracticeScreen(english: 'forEach')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('대소문자 구분'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'foreach');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('아쉽네요!'), findsOneWidget);
      // 틀린 글자(e)와 입력한 그대로의 소문자가 보인다
      expect(borderOf(tester, 'e'), Colors.red);
      expect(cubit.state.progressFor('forEach').timesCorrect, 0);
    });

    testWidgets('키보드 완료 키로도 제출된다', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'commit');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('정답입니다!'), findsOneWidget);
      expect(cubit.state.progressFor('commit').timesCorrect, 1);
    });
  });

  testWidgets('키보드가 올라온 작은 화면에서도 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ProgressCubit(ProgressRepository()),
        child: const MaterialApp(
          home: SpellingPracticeScreen(english: 'TextEditingController'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('진도 기록', () {
    Future<ProgressCubit> cubitWith(Map<String, Object> saved) async {
      SharedPreferences.setMockInitialValues(saved);
      final cubit = ProgressCubit(ProgressRepository());
      await Future<void>.delayed(Duration.zero);
      return cubit;
    }

    test('틀리면 인터벌 횟수가 1 줄어 마스터에서 내려온다', () async {
      final longAgo =
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String();
      final cubit = await cubitWith({
        'devoca_word_progress':
            '{"commit":{"english":"commit","timesPracticed":3,"timesCorrect":3,'
                '"intervalCorrects":3,"lastCorrect":"$longAgo"}}',
      });
      expect(cubit.state.progressFor('commit').isMastered, isTrue);

      await cubit.recordPractice('commit', correct: false);
      final p = cubit.state.progressFor('commit');
      expect(p.intervalCorrects, 2);
      expect(p.isMastered, isFalse);
      expect(p.isInProgress, isTrue);
    });

    test('0회일 때 틀려도 음수가 되지 않는다', () async {
      final cubit = await cubitWith({});
      await cubit.recordPractice('commit', correct: false);
      expect(cubit.state.progressFor('commit').intervalCorrects, 0);
    });

    test('정답은 4일 간격일 때만 인터벌 횟수가 오른다', () async {
      final cubit = await cubitWith({});
      await cubit.recordPractice('commit', correct: true);
      await cubit.recordPractice('commit', correct: true);
      expect(cubit.state.progressFor('commit').intervalCorrects, 1);
    });
  });

  group('오늘의 학습', () {
    test('3글자 이하 단어는 다른 미학습 단어를 다 본 뒤에 추천된다', () async {
      // conflict, polymorphism만 미학습으로 남긴다. 목록상 tag(3글자)가 이 둘보다 앞에 있다.
      final now = DateTime.now().toIso8601String();
      final practiced = kWordList
          .map((w) => w.english)
          .where((e) => e.length > 3 && e != 'conflict' && e != 'polymorphism')
          .map((e) => '${jsonEncode(e)}:{"english":${jsonEncode(e)},'
              '"timesCorrect":1,"intervalCorrects":1,"lastCorrect":"$now"}')
          .join(',');
      SharedPreferences.setMockInitialValues(
          {'devoca_word_progress': '{$practiced}'});
      final cubit = ProgressCubit(ProgressRepository());
      await Future<void>.delayed(Duration.zero);

      final today = cubit.state.todayWordEnglish;
      expect(today.take(2), ['conflict', 'polymorphism']);
      expect(today.skip(2).every((e) => e.length <= 3), isTrue);
    });

    test('목록에서 빠진 단어의 기록과 오늘의 단어는 버린다', () async {
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      SharedPreferences.setMockInitialValues({
        'devoca_word_progress':
            '{"try/except":{"english":"try/except","timesCorrect":2}}',
        'devoca_daily_words': '{"$todayKey":["try/except","commit"]}',
      });
      final cubit = ProgressCubit(ProgressRepository());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.progress, isEmpty);
      expect(cubit.state.totalCorrect, 0);
      expect(cubit.state.todayWordEnglish, isNot(contains('try/except')));
      expect(cubit.state.todayWordEnglish, hasLength(5));
    });
  });
}
