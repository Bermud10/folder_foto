import 'package:flutter/material.dart';
import 'package:folder_foto/widgets/card_item.dart';

class RectifierBlack extends StatefulWidget {
  const RectifierBlack({super.key});

  @override
  State<RectifierBlack> createState() => RectifierBlackState();
}

class RectifierBlackState extends State<RectifierBlack> {

 static const Map<String, String> params = {
  "F00 Режим работы": "0 - Одиночный, 1 - Ручной, 2 - Авто",
  "F01 Протокол связи": "0-7 (8 Протоколов связи)",
  "F02 U Max": "110В - 320В",
  "F03 U Min": "110В - 320В",
  "F04 Режим заряда": "0 - Подзаряд(ПЗ), 1 - УСК заряд(УЗ)",
  "F05 Напряжение ПЗ": "От Umin до напряжения УЗ",
  "F06 Напряжение УЗ": "От напряжения УЗ до Umax",
  "F07 Ограничение тока заряда": "Ограничение тока 10% от емкости",
  "F08 Ток ПЗ->Ток УЗ": "Max ток для УЗ -> ПЗ",
  "F09 Ток УЗ->Ток ПЗ": "10% Ток ПЗ -> Ток УЗ",
  "F10 Время заряда": "0-10 Часов",
  "F11 Мах время УЗ": "0-99 Часов",
  "F12 Цикл УЗ": "0-999 Дней",
  "F13 Сухой контакт аварии": "0 - Открыт, 1 - Закрыт",
  "F14 Информация о токе": "0 - не показывать, 1 - показывать",
  "F15 защита от превыш U": "0 - аварии, 1 - завышение",
  "F16 U по умолчанию": "Min Напряжение - Max Напряжение",
  "F17 Группировочный признак": "0-3",
  "F18 Адрес связи": "1,2,3 - адрес, 0-99",
  "F19 Скорость передачи данных": "1—8 (8 вида)",
  "F20 Проверка данных": "0—5 (6 видов)",
  "F21 Время отклика связи": "2-10мс (9 видов)",
  "F22 Состояние переключателя по умолчанию при включении питания в ручном режиме": "включать | выключать",
  "F23 Ручное управление переключателем режимов": "включать | выключать"
};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка черного выпрямителя'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/images/black_rectifier.jpg'),
              SizedBox(height: 16),
              Text('Для перехода в режим настройки параметров необходимо удерживать клавишу "ввод" до появления F00.'),
              SizedBox(height: 8),
              ...params.entries
              .map((entry) => CardItem(
                key: Key(entry.key),
                label: entry.key,
                body: entry.value
              )),
              Text('*По умолчанию выпрямитель находится в автоматическом режиме работы (2 - Авто)'),
              SizedBox(height: 8),
              Text('*Настройки протокола связи: 0 - MODBUS, 1 - TH, 2 - ENPC, 3 - ENPS + MODBUS'),
              SizedBox(height: 8),
              Text('*Скорость передачи данных: 1-2400, 2-4800, 3-9600, 4-19200'),
            ],
          ),
        ),
      )
    );
  } 
}