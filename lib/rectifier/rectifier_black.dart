import 'package:flutter/material.dart';

class RectifierBlack extends StatefulWidget {
  const RectifierBlack({super.key});

  @override
  State<RectifierBlack> createState() => RectifierBlackState();
}

Map<String, String> params = {
  "F00": "Режим работы: 0—Одиночный, 1—Ручной, 2—Авто",
  "F01": "Протокол связи: 0-7 (8 Протокол связи)",
  "F02": "Уставка высокого: 110V-320V",
  "F03": "Уставка низкого напряжения: 110V-320V",
  "F04": "Режим заряда: 0—Подзаряд(ПЗ), 1—УСК заряд(УЗ)",
  "F05": "Напряжение ПЗ: От Umin до напр УЗ",
  "F06": "Напряжение УЗ: От напр УЗ до Umax",
  "F07": "Ограничение тока заряда: 10%-Max ограничение тока",
  "F08": "Ток ПЗ->Ток УЗ: Max ток для УЗ->ПЗ",
  "F09": "Ток УЗ->Ток ПЗ: 10%—Ток ПЗ>Ток УЗ",
  "F10": "Время заряда: 0-10 Часов",
  "F11": "Маха время ускоренного: 0-99 Часов",
  "F12": "Цикл УЗ: 0-999 Дней",
  "F13": "Сухой контакт аварии: 0-Открыт 1-Закрыт",
  "F14": "Информацию тока: 0—не показ, 1—показ",
  "F15": "защита от превыш напря на: 0—аварии, 1—завышение",
  "F16": "по умолчанию напряжение: Min Напряжение-Max Напряжение",
  "F17": "группировочный признак: 0-3",
  "F18": "адрес связи: 1,2,3 - адрес, 0-99",
  "F19": "скорость передачи данных: 1—8 (8 вида)",
  "F20": "проверка данных: 0—5 (6 вида)",
  "F21": "время отклика связи: 2-10 (9 вида) (ms)",
  "F22": "Состояние переключателя по умолчанию при включении питания в ручном режиме: включать | выключать",
  "F23": "Ручное управление переключателем режимов: включать | выключать"
};

class RectifierBlackState extends State<RectifierBlack> {

  Widget printMode(String label, String info) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: info,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка черного выпрямителей'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: params.entries
              .map((entry) => printMode(entry.key, entry.value))
              .toList(),
        ),
            ],
          ),
        ),
      )
    );
  } 
}