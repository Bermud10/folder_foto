import 'package:flutter/material.dart';

class BatteryCalculator extends StatefulWidget {
  const BatteryCalculator({super.key});

  @override
  State<BatteryCalculator> createState() => BatteryCalculatorState();
}

enum BatteryVoltage {
  v2(2),
  v12(12);

  final int volts;
  const BatteryVoltage(this.volts);
}

class BatteryCalculatorState extends State<BatteryCalculator> {
  final countBatteries = TextEditingController();
  final cBatteries = TextEditingController();
  BatteryVoltage? _selectedVoltage = BatteryVoltage.v12;

  // 🔹 ВАЖНО: Всегда освобождайте контроллеры, чтобы не было утечек памяти!
  @override
  void dispose() {
    countBatteries.dispose();
    cBatteries.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расчет ПЗ, ВЗ, УЗ'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding( // Добавил Padding, чтобы поля не прилипали к краям
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RadioGroup<BatteryVoltage>(
              groupValue: _selectedVoltage,
              onChanged: (BatteryVoltage? value) {
                setState(() {
                  _selectedVoltage = value;
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('2В'),
                      leading: Radio<BatteryVoltage>(
                        value: BatteryVoltage.v2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('12В'),
                      leading: Radio<BatteryVoltage>(
                        value: BatteryVoltage.v12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Отступ между радио и полями
            TextField(
              controller: countBatteries,
              keyboardType: TextInputType.number, // Только цифры
              decoration: const InputDecoration(
                labelText: 'Количество батарей',
                border: OutlineInputBorder(),
              ),
              // autofocus УДАЛЕН
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cBatteries,
              keyboardType: TextInputType.number, // Только цифры
              decoration: const InputDecoration(
                labelText: 'Емкость батарей',
                border: OutlineInputBorder(),
              ),
              // autofocus УДАЛЕН
            ),
          ],
        ),
      ),
    );
  }
}