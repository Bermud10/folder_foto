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
  Map<String, double>? _calculationResults;
  String? _errorMessage;

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

  getResult(){

  if (countBatteries.text.isEmpty) {
    setState(() {
      _calculationResults = null;
      _errorMessage = null;
    });
    return;
  }

  var quantity = int.tryParse(countBatteries.text);
  if (quantity == null) {
    setState(() {
      _calculationResults = null;
      _errorMessage = 'Введите корректное значение без пробелов';
    });
  return; 
  }
  else{
    setState(() {
      _errorMessage = null;
      _calculationResults = calculation(quantity,_selectedVoltage!.volts);
    });
  }
 }

 Widget showResult(String h1,  double? value, String unit) {

  var styleLable = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  var styleValue = TextStyle(fontSize: 20);
  return Row(
    mainAxisAlignment: .start,
    crossAxisAlignment: .end,
    children: [
      Text(h1, style: styleLable),
      Text('${value!.toStringAsFixed(3)}', style: styleValue),
      Text(unit, style: styleValue)
      ],
  );
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расчет ПЗ, ВЗ, УЗ, t-комп.'),
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
                  getResult();
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
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                  getResult();
                });
              },
              decoration: InputDecoration(
                labelText: 'Количество батарей',
                border: const OutlineInputBorder(),
                errorBorder: const OutlineInputBorder(),
                errorText: _errorMessage,
                errorStyle: const TextStyle(color: Colors.red))
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _calculationResults = null;
                        countBatteries.clear();
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.clear, size: 24),
                    label: const Text('Очистить', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
            if(_calculationResults != null) ...[
              SizedBox(height: 8),
              showResult('ПЗ: ', _calculationResults!['pZ'], ' В'),
              SizedBox(height: 8),
              showResult('ВЗ: ', _calculationResults!['vZ'], ' В'),
              SizedBox(height: 8),
              showResult('УЗ: ', _calculationResults!['uZ'], ' В'),
              SizedBox(height: 8),
              showResult('Темп. компенсация: ', _calculationResults!['tCompens'], ''),
            ]
          ],
        ),
      ),
    );
  } 
}