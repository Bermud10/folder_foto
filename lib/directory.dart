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

  Widget showCard(String title, String data){
    return Card(
      child: ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600),),
      subtitle: Text( data),
      ),
    );
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
          showCard('AC Трехфазное питание', 'max - 450В\nmin - 304В \nСчитается как ± 10% 400В'),
          showCard('AC Однофазное питание', 'max - 242В\nmin - 198В \nСчитается как ± 10% от 220В'),
          showCard('DC / U AБ', 'max - 244B \nmin - 198B'),
          showCard('Ток заряда АБ', '0.1 * емкость АБ'),
          showCard('Режимы заряда', 'УЗ - 241В\nПЗ - 231В\nВЗ - 235В'),
          showCard('Температура АКБ', 'Опорная - 25°С\nМаксимальная - 40°С\nМинимальная - 10°С'),
          showCard('Контроль изоляции', 'Предупреждающая - 50кОм\nАварийная - 25кОм'),
          showCard('Коэф. темп. комп', '0,306'),
          showCard('Периодичность УЗ', '180'),
        ],
      ),
    );
  }
}