import 'package:devoca/data/repositories/progress_repository.dart';
import 'package:devoca/data/services/sql_engine.dart';
import 'package:devoca/data/services/sql_practice_service.dart';
import 'package:devoca/presentation/cubits/sql/sql_practice_cubit.dart';
import 'package:devoca/presentation/screens/sql_problem_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpProblem(WidgetTester tester, String id) async {
    // 결과 표 아래 버튼까지 한 화면에 들어오도록 세로로 긴 화면을 쓴다
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // 테스트마다 zone이 달라서 엔진을 공유하면 로딩 Future가 끝나지 않는다
    final service = SqlPracticeService(SqlEngine());
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: service,
        child: BlocProvider(
          create: (_) => SqlPracticeCubit(service, ProgressRepository()),
          child: MaterialApp(home: SqlProblemScreen(problemId: id)),
        ),
      ),
    );
  }

  Future<void> run(WidgetTester tester, String sql) async {
    await tester.enterText(find.byType(TextField), sql);
    await tester.tap(find.text('실행'));
    await tester.pumpAndSettle();
  }

  testWidgets('오류 → 오답 → 정답 순서로 피드백이 바뀐다', (tester) async {
    await pumpProblem(tester, 'where-age');
    expect(find.textContaining('30 이상'), findsOneWidget);

    await run(tester, 'SELEC name FROM users');
    expect(find.text('쿼리를 실행하지 못했습니다'), findsOneWidget);
    expect(find.textContaining('syntax error'), findsOneWidget);

    await run(tester, 'SELECT name, age FROM users');
    expect(find.text('결과가 다릅니다'), findsOneWidget);
    expect(find.textContaining('행 수가 다릅니다'), findsOneWidget);

    await run(tester, 'SELECT name, age FROM users WHERE age >= 30');
    expect(find.text('정답입니다!'), findsOneWidget);
    expect(find.text('Choi'), findsOneWidget);
    expect(find.text('3행'), findsOneWidget);
    expect(find.text('다음 문제'), findsOneWidget);
    expect(await ProgressRepository().loadSolvedSqlIds(), {'where-age'});
  });

  testWidgets('힌트는 첫 글자만 보여주고 요청하면 철자를 보여준다', (tester) async {
    await pumpProblem(tester, 'where-age');
    expect(find.text('SELECT'), findsNothing);

    await tester.tap(find.text('힌트'));
    await tester.pumpAndSettle();
    expect(find.text('S _ _ _ _ _'), findsOneWidget);
    expect(find.text('W _ _ _ _'), findsOneWidget);
    expect(find.text('WHERE'), findsNothing);

    await tester.tap(find.text('철자 보기'));
    await tester.pump();
    expect(find.text('SELECT'), findsOneWidget);
    expect(find.text('FROM'), findsOneWidget);
    expect(find.text('WHERE'), findsOneWidget);
  });

  testWidgets('변경 문제는 실행 후 테이블을 보여준다', (tester) async {
    await pumpProblem(tester, 'update-city');
    await run(tester, "UPDATE users SET city = 'Busan' WHERE id = 3");
    expect(find.text('정답입니다!'), findsOneWidget);
    expect(find.text('실행 후 users 테이블'), findsOneWidget);
    expect(find.text('다음 문제'), findsOneWidget);
  });
}
