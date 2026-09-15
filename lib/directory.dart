import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/card_item.dart';

class DirectoryPage extends StatefulWidget {
  
  const DirectoryPage({
    super.key,
  });

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {

  final Map<String, String> referenceData = {
  'AC Трехфазное питание': 'max - 450В\nmin - 304В \nСчитается как ± 10% 400В',
  'AC Однофазное питание': 'max - 242В\nmin - 198В \nСчитается как ± 10% от 220В',
  'DC / U AБ': 'max - 244B \nmin - 198B',
  'Ток заряда АБ': '0.1 * емкость АБ',
  'Режимы заряда': 'УЗ - 241В\nПЗ - 231В\nВЗ - 235В',
  'Температура АКБ': 'Опорная - 25°С\nМаксимальная - 40°С\nМинимальная - 10°С',
  'Контроль изоляции': 'Предупреждающая - 50кОм\nАварийная - 25кОм',
  'Коэф. темп. комп': '0,306',
  'Периодичность УЗ': '180',
};

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уставки'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:  referenceData.entries.map((entry) {
              return CardItem(
                key: Key(entry.key),
                label: entry.key,
                body: entry.value
              );
            }).toList(),
          )
    );
  }
}