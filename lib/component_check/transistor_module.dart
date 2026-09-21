import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/zoomable_image.dart';

class TransistorModule extends StatefulWidget {
  const TransistorModule({super.key});

  @override
  State<TransistorModule> createState() => TransistorModuleState();
}

String info = '''В начале необходимо проверить целостность диодов между контактами 1-2 и 2-3.\n
Для этого в режиме диодной прозвонки на мультиметре, ставим черный щуп на точку 1, красный на точку 2, получаем сопротивление 0.3В - это 
значит, что диод живой, далее ставим черный на точку 3, красный на точку 1, получаем так же 0.3В, если диод целый.\n
Далее проверяем связь эммитора и силовой части на первом и втором транзисторе.\n
В рижиме сопротивления проверяем точку 7 и точку 2 для 1 транзистора, точки 5 и 1 для второго - 0 Ом значит, что связь есть.\n
Далее проверяем сопротивление затвора и управляющей части между точками 6-1 и 6-2 (для первого транзистора) и 4-1 и 4-3 (для второго).
Сопротивление должно быть либо какое то большое, либо бесконечность (0).\n
Далее проверяем емкость затвора между точками 4-5 и 6-7. Емкость этого измерения должна быть примерно равна паспортным данным проверяемого 
модуля (показатель Cies- измеряется в нанофаратах).''';

class TransistorModuleState extends State<TransistorModule> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Транзисторный модуль'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Схема транзисторного модуля",
                style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/transistor.png'),
              SizedBox(height: 8),
              Text(info),
            ]
          ),
        ),
      )
    );
  } 
}