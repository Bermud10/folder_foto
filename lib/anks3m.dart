import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/zoomable_image.dart';

class Anks3m extends StatefulWidget {
  const Anks3m({super.key});

  @override
  State<Anks3m> createState() => Anks3mState();
}

// String info = '''Настройка и подключение энкса''';

class Anks3mState extends State<Anks3m> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Энкс 3м'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Подключение к интерфейсам",
                style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/connect3m.png'),
              SizedBox(height: 8),
              Text(
                "Интерфейсы",
                style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/interfases.png'),
              SizedBox(height: 8),
              Text(
                "Соответствие интерфейсов",
                style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/coms.png'),
              SizedBox(height: 8),
              // Text(info),
              Text(
                "Разъемы панели cMT2078X",
                style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/conA.png'),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/conB.png'),
            ]
          ),
        ),
      )
    );
  } 
}