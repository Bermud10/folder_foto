import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/pdf_link_button.dart';
import 'package:folder_foto/widgets/zoomable_image.dart';

class Anks3m extends StatefulWidget {
  const Anks3m({super.key});

  @override
  State<Anks3m> createState() => Anks3mState();
}

String infoRXtX = """Tx и Rx — это сокращения для обозначения направления передачи данных между устройствами\n
• Tx (Transmit) — передатчик / отправка данных.\n
• Rx (Receive) — приемник / получение данных.\n

Как правильно подключать (распиновка)\n
При соединении двух устройств контакты всегда подключаются крест-накрест (перекрестно):\n
• Tx одного устройства соединяется с RX другого (Tx → Rx).\n
• Rx одного устройства соединяется с TX другого (Rx ← Tx).\n
По этому Tx и Rx на разъеме Con.B должны быть перевернуты!
 """;

 String infoTITC = """
  • ТИ - аналоговые сигналы, в адресации начинаются с 1000. Источник – 01 Регистры флагов. Группа - ТС.\n
  • ТС - Логические сигналы, в адресации начинаются с 1. Источник – 04 Входные регистры. Группа - Voltage/U.
""";

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
              SizedBox(height: 20),
              Text(
                infoRXtX,
              ),
              SizedBox(height: 8),
              Text(
                infoTITC,
              ),
              PdfLinkButton(
                label: "Документация ЭНКС",
                pdfUrl: 'https://enip2.ru/documentation/re_encs.403500.001.pdf'
              )
            ]
          ),
        ),
      )
    );
  } 
}