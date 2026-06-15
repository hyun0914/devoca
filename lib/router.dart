import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/word_list_screen.dart';
import 'presentation/screens/word_card_screen.dart';
import 'presentation/screens/spelling_practice_screen.dart';
import 'presentation/screens/quiz_screen.dart';
import 'presentation/screens/progress_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/words',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/words',
            builder: (context, state) => const WordListScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/quiz',
            builder: (context, state) => const QuizScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/word/:english',
      builder: (context, state) =>
          WordCardScreen(english: state.pathParameters['english']!),
      routes: [
        GoRoute(
          path: 'spelling',
          builder: (context, state) =>
              SpellingPracticeScreen(english: state.pathParameters['english']!),
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '단어',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: '퀴즈',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '현황',
          ),
        ],
      ),
    );
  }
}
