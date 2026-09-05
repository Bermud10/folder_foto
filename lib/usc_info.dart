import 'package:flutter/material.dart';
import 'package:folder_foto/zoomable_image.dart';

class UscInfo extends StatefulWidget {
  const UscInfo({super.key});

  @override
  State<UscInfo> createState() => UscInfoState();
}



class UscInfoState extends State<UscInfo> {

  String invertor = """● Светодиод мигает 1 раз в секунду - Авария по превышению тока (КЗ)\n
● Светодиод мигает 2 раз подряд - Авария по перегреву радиатора\n 
● Светодиод мигает 3 раз подряд - Авария по минимальному или 
максимальному напряжению на шине DC\n 
● Светодиод мигает 4 раз подряд - Авария по отключению ведомого 
инвертора, когда приоритет локального статического переключателя на 
вводе "Сеть"\n  
● Светодиод мигает 5 раз подряд - Авария по обрыву обратной связи\n 
● Светодиод мигает постоянно - Авария по перегрузке\n 
● Светодиод горит постоянно - Авария по драйверной защите""";

String rectifier = """● Светодиод равномерно моргает - Авария обрыв обратной связи\n 
● Светодиод горит постоянно - Авария по превышению номинального 
напряжения или тока\n 
● Светодиод мигает 1 раз в секунду - (ДОП. КАНАЛ) Авария по 
превышению номинального напряжения или тока\n 
● Светодиод мигает 2 раз подряд - (ДОП. КАНАЛ) Авария обрыв обратной 
связи """;

String sts = """● Светодиод моргает 1 раз в секунду - Авария по пониженному 
напряжению (Инвертор)\n 
● Светодиод моргает 2 раз подряд - Авария по пониженному напряжению 
(Сеть)\n 
● Светодиод моргает 3 раз подряд - Авария по повышенному напряжению 
(Инвертор)\n 
● Светодиод моргает 4 раз подряд - Авария по повышенному напряжению 
(Сеть)\n 
● Светодиод моргает 5 раз подряд - Авария по перегрузке-перегреву 
(Инвертор)\n 
● Светодиод моргает 6 раз подряд - Авария по перегрузке-перегреву (Сеть)\n 
● Светодиод моргает постоянно - Авария по отсутствию напряжения (Сеть)\n 
● Светодиод горит постоянно - Авария по отсутствию напряжения 
(Инвертор)  """;

String dcDcUP = """● Светодиод мигает 1 раз в секунду - Авария по обрыву обратной связи\n  
● Светодиод мигает 2 раз подряд -  Авария по пониженному или 
повышенному напряжению по входу\n 
● Светодиод мигает 3 раз подряд - Авария по перегреву радиатора\n 
● Светодиод мигает постоянно - Авария перегрузка по току\n 
● Светодиод горит постоянно - Авария по драйверной защите  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Плата USC'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // SizedBox(height: 8),
              Text(
              "Внешний вид платы",
               style:TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700
                )
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/usc_view.png'),
              SizedBox(height: 20),
              Text(
                "Режим работы платы USC",
                 style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700)
              ),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/type_device.png'),
              SizedBox(height: 20),
              Text(
                "Расшифровка аварий по миганию аварийного светодиода",
                 style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700)
              ),
              SizedBox(height: 20),
              Text(
              "Инвертор",
              style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700)        
              ),
              SizedBox(height: 20),
              Text(
              invertor                 
              ),
              SizedBox(height: 20),
              Text(
              "Выпрямитель",
              style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700)        
              ),
              SizedBox(height: 20),
              Text(
              rectifier                
              ),
              SizedBox(height: 20),
              Text(
              "STS",
              style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700)        
              ),
              SizedBox(height: 20),
              Text(
              sts                
              ),
              SizedBox(height: 20),
              Text(
              "Повышающий DC/DC",
              style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700)        
              ),
              SizedBox(height: 20),
              Text(
              dcDcUP                
              ),
            ]
          ),
        ),
      )
    );
  } 
}