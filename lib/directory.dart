import 'package:flutter/material.dart';

class DirectoryPage extends StatefulWidget {
  
  const DirectoryPage({
    super.key,
  });

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
 

  @override
  void initState() {
    super.initState();
    
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уставки'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(child: ListTile(
            title: Text('• Трехфазное питание'),
            subtitle: Text('AC max - 450В\nAC min - 304В \nСчитается как ± 10% 400В'),
            )
          ),
          Card(child: ListTile(
            title: Text('• Однофазное питание'),
            subtitle: Text('AC max - 242В\nAC min - 198В \nСчитается как ± 10% от 220В'),
            )
          ),
          Card(child: ListTile(
            title: Text('• U AБ'),
            subtitle: Text('max - 244B \nmin - 198B'),
            )
          ),
          Card(child: ListTile(
            title: Text('• Ток заряда АБ'),
            subtitle: Text('0.1 * емкость АБ'),
            )
          ),
          Card(child: ListTile(
            title: Text('• Режимы заряда'),
            subtitle: Text('УЗ - 241В\nПЗ - 231В\nВЗ - 235В'),
            )
          ),
          Card(child: ListTile(
            title: Text('• Температура АКБ'),
            subtitle: Text('Опорная - 25°С\nМаксимальная - 40°С\nМинимальная - 10°С')
            )
          ),
          Card(child: ListTile(
            title: Text('• Контроль изоляции'),
            subtitle: Text('Предупреждающая - 50кОм\nАварийная - 25кОм'),
            )
          ),
          Card(child: ListTile(
            title: Text('• Коэф. темп. комп'),
            subtitle: Text('0,306'),
            )
          ),
          Card(child: ListTile(
            title: Text('• Периодичность УЗ'),
            subtitle: Text('180'),
            )
          ),
        ],
      ),
    );
  }
}