import 'package:flutter/material.dart';
// import 'package:folder_foto/widgets/zoomable_image.dart';

class CurrentSensor extends StatefulWidget {
  const CurrentSensor({super.key});

  @override
  State<CurrentSensor> createState() => CurrentSensorState();
}

String info = '''Для проверки токового датчика необходимо измерить напряжение на его подключении к плате.
Измеряем напряжение на контактах 35,37,39,(измеряем прямо на фишке между черным и белым проводом) напряжение должно быть до 2В.\n
На плате выпрямителя измеряется постоянное напряжение, на плате инвертора измеряем переменное напряжение.
Если Напряжение изменяется вместе с током, а нагрузки нет, то неисправен датчик тока.\n
Если Напряжение = 0, а ток максимальный, то нужен либо сброс нуля ТД, либо неисправна плата.
''';

class CurrentSensorState extends State<CurrentSensor> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Токовый датчик'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Text(
              //   "Подключение к плате",
              //   style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              // ),
              // SizedBox(height: 20),
              // ZoomableImage(imagePath: 'assets/images/thyristor.png'),
              // SizedBox(height: 8),
              Text(info),
            ]
          ),
        ),
      )
    );
  } 
}