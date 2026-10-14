import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/sql_practice_service.dart';
import '../../data/sql_problem_data.dart';
import '../../domain/models/sql_problem.dart';
import '../../domain/models/sql_result.dart';
import '../cubits/sql/sql_practice_cubit.dart';
import '../widgets/sql_result_table.dart';

class SqlProblemScreen extends StatefulWidget {
  final String problemId;
  const SqlProblemScreen({super.key, required this.problemId});

  @override
  State<SqlProblemScreen> createState() => _SqlProblemScreenState();
}

class _SqlProblemScreenState extends State<SqlProblemScreen> {
  final _controller = TextEditingController();

  int get _index => kSqlProblems.indexWhere((p) => p.id == widget.problemId);

  @override
  void initState() {
    super.initState();
    context.read<SqlPracticeCubit>().openProblem(widget.problemId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showTables() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _TablesSheet(),
    );
  }

  void _showHint(SqlProblem problem) {
    showDialog<void>(
      context: context,
      builder: (_) => _HintDialog(keywords: problem.keywords),
    );
  }

  void _showAnswer(SqlProblem problem) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정답 예시'),
        content: SelectableText(
          problem.answerSql,
          style: const TextStyle(fontFamily: 'monospace', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = _index;
    if (index < 0) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('문제를 찾을 수 없습니다.')),
      );
    }
    final problem = kSqlProblems[index];
    final next =
        index + 1 < kSqlProblems.length ? kSqlProblems[index + 1] : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${index + 1}. ${problem.title}'),
        actions: [
          TextButton.icon(
            onPressed: _showTables,
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: const Text('테이블 보기'),
          ),
        ],
      ),
      body: BlocBuilder<SqlPracticeCubit, SqlPracticeState>(
        builder: (context, state) {
          final running = state.status == SqlPracticeStatus.running;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Card(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        problem.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    minLines: 4,
                    maxLines: 8,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    // 둥근 따옴표로 바뀌면 SQL 문자열이 깨진다
                    smartQuotesType: SmartQuotesType.disabled,
                    smartDashesType: SmartDashesType.disabled,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 15, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: '여기에 쿼리를 작성하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _showHint(problem),
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('힌트'),
                      ),
                      TextButton(
                        onPressed: () => _showAnswer(problem),
                        child: const Text('정답 보기'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: running
                            ? null
                            : () => context
                                .read<SqlPracticeCubit>()
                                .submit(problem, _controller.text),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(running ? '실행 중' : '실행'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.problemId == problem.id)
                    _Feedback(state: state, problem: problem),
                  if (state.status == SqlPracticeStatus.correct) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: next != null
                          ? FilledButton.tonalIcon(
                              onPressed: () =>
                                  context.pushReplacement('/sql/${next.id}'),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('다음 문제'),
                            )
                          : FilledButton.tonal(
                              onPressed: () => context.pop(),
                              child: const Text('목록으로'),
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

class _HintDialog extends StatefulWidget {
  final List<String> keywords;
  const _HintDialog({required this.keywords});

  @override
  State<_HintDialog> createState() => _HintDialogState();
}

class _HintDialogState extends State<_HintDialog> {
  bool _revealed = false;

  // 철자를 떠올려 보도록 첫 글자만 보여준다: ORDER BY → O _ _ _ _  B _
  String _mask(String keyword) => keyword
      .split(' ')
      .map((word) =>
          [word[0], for (var i = 1; i < word.length; i++) '_'].join(' '))
      .join('   ');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('힌트'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이 문제에 쓰이는 키워드',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final keyword in widget.keywords)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _revealed ? keyword : _mask(keyword),
                    style: const TextStyle(
                        fontFamily: 'monospace', fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        if (!_revealed)
          TextButton(
            onPressed: () => setState(() => _revealed = true),
            child: const Text('철자 보기'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  final SqlPracticeState state;
  final SqlProblem problem;
  const _Feedback({required this.state, required this.problem});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (state.status) {
      SqlPracticeStatus.correct => (
          Colors.green,
          Icons.check_circle_rounded,
          '정답입니다!'
        ),
      SqlPracticeStatus.wrong => (
          Colors.orange,
          Icons.cancel_rounded,
          '결과가 다릅니다'
        ),
      SqlPracticeStatus.error => (
          Colors.red,
          Icons.error_rounded,
          '쿼리를 실행하지 못했습니다'
        ),
      _ => (Colors.grey, Icons.info_outline, ''),
    };
    if (label.isEmpty) return const SizedBox.shrink();

    final output = state.output;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: color.shade800,
                            fontWeight: FontWeight.bold)),
                    if (state.message != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        state.message!,
                        style: state.status == SqlPracticeStatus.error
                            ? const TextStyle(
                                fontFamily: 'monospace', fontSize: 13)
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (output != null) ...[
          const SizedBox(height: 16),
          Text(
            problem.isMutation ? '실행 후 ${problem.targetTable} 테이블' : '실행 결과',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          SqlResultTable(result: output),
        ],
      ],
    );
  }
}

class _TablesSheet extends StatefulWidget {
  const _TablesSheet();

  @override
  State<_TablesSheet> createState() => _TablesSheetState();
}

class _TablesSheetState extends State<_TablesSheet> {
  late final Future<Map<String, SqlResult>> _tables =
      context.read<SqlPracticeService>().loadTables();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return FutureBuilder<Map<String, SqlResult>>(
          future: _tables,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('테이블을 불러오지 못했습니다.'));
            }
            final tables = snapshot.data;
            if (tables == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                for (final entry in tables.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  SqlResultTable(result: entry.value),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
