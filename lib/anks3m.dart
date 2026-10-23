import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/pdf_link_button.dart';
import 'package:folder_foto/widgets/zoomable_image.dart';
import 'package:folder_foto/widgets/link_button.dart';

class Anks3m extends StatefulWidget {
  const Anks3m({super.key});

  @override
  State<Anks3m> createState() => Anks3mState();
}

String infoRXtX = """
Tx и Rx — это сокращения для обозначения направления передачи данных между устройствами.
• Tx (Transmit) — передатчик / отправка данных.
• Rx (Receive) — приемник / получение данных.

Как правильно подключать (распиновка):
При соединении двух устройств контакты всегда подключаются крест-накрест (перекрестно):
• Tx одного устройства соединяется с RX другого (Tx → Rx).
• Rx одного устройства соединяется с TX другого (Rx ← Tx).
По этому Tx и Rx на разъеме Con.B должны быть перевернуты!
""";

  String infoTITC = """
• ТИ - аналоговые сигналы, в адресации начинаются с 1000. Источник – 04 Входные регистры. Группа - Voltage/U.
• ТС - Логические сигналы, в адресации начинаются с 1. Источник – 01 Регистры флагов. Группа - ТС.
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
                "Подключение энкса при RS-232",
                style:TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/true_connect.png'),
              SizedBox(height: 20),
              Text(
                infoRXtX,
              ),
              SizedBox(height: 8),
              Text(
                infoTITC,
              ),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: const Text(
                    'Модели ЭНКС-3M',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  collapsedTextColor: Colors.grey, // Цвет текста, когда свернуто
                  iconColor: Colors.grey,          // Цвет стрелочки, когда свернуто
                  expandedCrossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Text(
                            "ЭНКС-3м-...-1(2)",
                          ),
                          SizedBox(height: 20),
                          const ZoomableImage(imagePath: 'assets/images/anks_3m_1(2).png'),
                          SizedBox(height: 20),
                          Text(
                            "ЭНКС-3м-...-3",
                          ),
                          const SizedBox(height: 16),
                          const ZoomableImage(imagePath: 'assets/images/anks_3m_3.png'),
                           SizedBox(height: 20),
                          Text(
                            "ЭНКС-3м-...-4(5)",
                          ),
                          const SizedBox(height: 16),
                          const ZoomableImage(imagePath: 'assets/images/anks_3m_4(5).png'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              PdfLinkButton(
                label: "Документация ЭНКС",
                pdfUrl: 'https://enip2.ru/documentation/re_encs.403500.001.pdf'
              ),
              LinkButton(
                label: 'Weintek cMT2078X',
                url: 'https://www.weintek.net/cMT2078X.html',
                icon: Icons.language,
              )
            ]
          ),
        ),
      )
    );
  } 
}