import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/zoomable_image.dart';

class ThyristorModule extends StatefulWidget {
  const ThyristorModule({super.key});

  @override
  State<ThyristorModule> createState() => ThyristorModuleState();
}

String info = '''Проверка тиристорного модуля серии SKKT начинается с проверки сопротивления основных силовых тиристоров.\n
Для этого в режиме измерения сопротивленя с помощью мультиметра делаем замеры в точках 1-2 для первого и 1-3 для второго тиристора, сопротивление
должно быть мегоомы или бесконечность.\n
Далее проверяем сопротивление управляющего канала между контактами 4-5 и 6-7.\n
Сопротивление должно быть в пределах от 10 до 20 Ом (до 100Ом - нормальное значение, зависит от модели тиристора),
если сопротивление бесконечно или мегоомы значит управление пробито и модуль не исправен.''';

class ThyristorModuleState extends State<ThyristorModule> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тиристорный модуль'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Схема тиристорного модуля",
                style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/thyristor.png'),
              SizedBox(height: 8),
              Text(info),
            ]
          ),
        ),
      )
    );
  } 
}