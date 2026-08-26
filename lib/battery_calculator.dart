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
  BatteryVoltage? _selectedVoltage = BatteryVoltage.v12;
  late Map<String, double> _calculationResults;
  bool resultsCalc = false;

  @override
  void dispose() {
    countBatteries.dispose();
    super.dispose();
  }

 Map<String,double> calculation(int quantity, int uAKB) {
  int factorElements = 1;
  bool params = uAKB == 12;
  if(params){
    factorElements = 6;
  }

  double pZ = quantity * 2.27 * factorElements;
  double uZ = quantity * 2.35 * factorElements;
  double vZ = quantity * 2.4 * factorElements;
  double tCompens = ((params)? 0.02 : 0.003) * quantity;
  return{"pZ": pZ, "uZ": uZ, "vZ": vZ, "tCompens": tCompens};
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
                     child: RadioListTile<BatteryVoltage>(
                     shape: RoundedRectangleBorder(borderRadius: .circular(15)),
                     title: Text('12В'),
                     value: BatteryVoltage.v12,
                     ),
                   ),
                  Expanded(
                    child: RadioListTile<BatteryVoltage>(
                    shape: RoundedRectangleBorder(borderRadius: .circular(15)),
                    title: Text('2В'),
                    value: BatteryVoltage.v2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), 
            TextField(
              controller: countBatteries,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Количество батарей',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
              var quantity = int.tryParse(countBatteries.text);
               if (quantity == null) {
                resultsCalc = false;
                return; 
               }
               _calculationResults = calculation(quantity,_selectedVoltage!.volts);

              },
              icon: const Icon(Icons.calculate, size: 24),
              label: const Text('Расчитать', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  } 
}