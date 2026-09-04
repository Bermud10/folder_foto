import 'package:flutter/material.dart';

class Amperage extends StatefulWidget {
  const Amperage({super.key});

  @override
  State<Amperage> createState() => AmperageState();
}

final List<(String, String)> tableDataStrings = [
  ('0.5', '11'),
  ('0.75', '15'),
  ('1', '17'),
  ('1.2', '20'),
  ('1.5', '23'),
  ('2', '26'),
  ('2.5', '30'),
  ('3', '34'),
  ('4', '41'),
  ('5', '46'),
  ('6', '50'),
  ('8', '62'),
  ('10', '80'),
  ('16', '100'),
  ('25', '140'),
  ('35', '170'),
  ('50', '215'),
  ('70', '270'),
  ('95', '330'),
];

class AmperageState extends State<Amperage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Допустимый ток кабеля'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Сечение, мм²')),
                  DataColumn(label: Text('Ток, А')),
                ],
                rows: tableDataStrings.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item.$1)),
                    DataCell(Text(item.$2)),
                  ]);
                }).toList(),
              )
)
          ]
        ),
      )
    );
  } 
}