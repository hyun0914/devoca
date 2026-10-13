import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/sql_problem_data.dart';
import '../cubits/sql/sql_practice_cubit.dart';

class SqlProblemListScreen extends StatelessWidget {
  const SqlProblemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('SQL 연습')),
      body: BlocBuilder<SqlPracticeCubit, SqlPracticeState>(
        buildWhen: (a, b) => a.solvedIds != b.solvedIds,
        builder: (context, state) {
          final solvedCount = kSqlProblems
              .where((p) => state.solvedIds.contains(p.id))
              .length;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '문제를 읽고 쿼리를 직접 작성해 실행해 보세요.',
                          style:
                              TextStyle(color: Colors.grey[600], height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: solvedCount / kSqlProblems.length,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$solvedCount / ${kSqlProblems.length} 해결',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  for (final category in kSqlCategories) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    for (final (index, problem) in kSqlProblems.indexed)
                      if (problem.category == category)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(problem.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              problem.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: state.solvedIds.contains(problem.id)
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.chevron_right),
                            onTap: () => context.push('/sql/${problem.id}'),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
