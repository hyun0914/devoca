import 'package:flutter/material.dart';
import '../../domain/models/sql_result.dart';

class SqlResultTable extends StatelessWidget {
  final SqlResult result;
  const SqlResultTable({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.columns.isEmpty) {
      return Text('반환된 결과가 없습니다.', style: TextStyle(color: Colors.grey[600]));
    }
    const cellStyle = TextStyle(fontFamily: 'monospace', fontSize: 13);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 36,
            dataRowMinHeight: 32,
            dataRowMaxHeight: 32,
            columnSpacing: 24,
            horizontalMargin: 12,
            columns: [
              for (final column in result.columns)
                DataColumn(
                  label: Text(column,
                      style: cellStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
            ],
            rows: [
              for (final row in result.rows)
                DataRow(cells: [
                  for (final value in row)
                    DataCell(value == null
                        ? Text('NULL',
                            style: cellStyle.copyWith(color: Colors.grey))
                        : Text(_format(value), style: cellStyle)),
                ]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 4),
          child: Text('${result.rows.length}행',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ),
      ],
    );
  }

  // 웹에서는 정수도 double이라 25.0 대신 25로 보여준다
  String _format(Object value) {
    if (value is num && value.isFinite && value == value.truncate()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
