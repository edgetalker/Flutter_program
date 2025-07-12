import 'package:flutter/material.dart';

import '../../../../constants.dart';

// 英寸尺寸表
class InchesSizeTable extends StatelessWidget {
  const InchesSizeTable({super.key});// 构造函数

  @override
  Widget build(BuildContext context) {
    return SizedBox(// 尺寸
      width: double.infinity,// 宽度
      child: ClipRRect(// 裁剪
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultBorderRadious)),
        child: DataTable(// 数据表
          border: TableBorder(// 表格边框
            verticalInside: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black12
                    : Colors.white10),
          ),
            columns: const <DataColumn>[
            DataColumn(label: Text('')),
            DataColumn(label: Text('Size')),
            DataColumn(label: Text('Bust')),
            DataColumn(label: Text('Waist')),
            DataColumn(label: Text('Hips')),
          ],
          rows: const <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text('S')),
                DataCell(Text('2-4')),
                DataCell(Text('32')),
                DataCell(Text('23-25')),
                DataCell(Text('34-35')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('M')),
                DataCell(Text('6-8')),
                DataCell(Text('34')),
                DataCell(Text('26-27')),
                DataCell(Text('36-39')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('L')),
                DataCell(Text('9-10')),
                DataCell(Text('36')),
                DataCell(Text('28-30')),
                DataCell(Text('40-42')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('XL')),
                DataCell(Text('11-12')),
                DataCell(Text('38')),
                DataCell(Text('31-33')),
                DataCell(Text('40-44')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
