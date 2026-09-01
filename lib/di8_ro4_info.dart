import 'package:flutter/material.dart';

class Di8Ro4Info extends StatefulWidget {
  const Di8Ro4Info({super.key});

  @override
  State<Di8Ro4Info> createState() => Di8Ro4InfoState();
}

String info = "- Положением переключателя устанавливается скорость, адрес и четность. Настройки применяются при перезапуске устройства.";

class Di8Ro4InfoState extends State<Di8Ro4Info> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DI8 RO4'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Настройки RS485/MODBUS",
               style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
            SizedBox(height: 8),
            Text(info),
            SizedBox(height: 20),
            InteractiveViewer(child: Image.asset('assets/images/di8ro4.png'))
            
          ]
        ),
      )
    );
  } 
}