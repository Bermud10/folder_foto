import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/zoomable_image.dart';

class Transformer extends StatefulWidget {
  const Transformer({super.key});

  @override
  State<Transformer> createState() => TransformerState();
}

String info = '''Группа соединения обмоток трансформатора — это условное число (от 0 до 11), 
которое показывает, на какой угол (в градусах) сдвинуты по фазе линейные напряжения обмотки низкого напряжения 
(НН) относительно обмотки высокого напряжения (ВН). Сдвиг всегда кратен 30°, поэтому его удобно представлять, 
как положение стрелок на циферблате часов: каждый час соответствует 30°.
''';

String info_1 = '''При проектировании шкафов всегда предполагается использование 11 группы в выпрямителе и 1 группы в инверторе.
''';

String group_11 = '''Для того чтобы понять какой группы перед нами трансформатор, необходимо посмотреть на подключение его выходных обмоток.
Для 11 группы подключение будет выглядеть следующим образом: выход фазы А приходит на начало фазы С, конец фазы С приходит на начало фазы В, конец В приходит на начало А.
''';

String group_1 = '''Первая группа подключается стандартно: конец А приходит на начало В, конец В приходит на начало С, конец С идет на А.
''';
class TransformerState extends State<Transformer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Трансформатор'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Схемы подключения обмоток в трансфформаторе",
                style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              // SizedBox(height: 20),
              // ZoomableImage(imagePath: 'assets/images/thyristor.png'),
              SizedBox(height: 8),
              Text(info),
              SizedBox(height: 8),
              Text(info_1),
              SizedBox(height: 8),
              Text(group_1),
              SizedBox(height: 8),
              Text(group_11),
            ]
          ),
        ),
      )
    );
  } 
}