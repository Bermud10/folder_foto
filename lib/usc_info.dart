import 'package:flutter/material.dart';

class UscInfo extends StatefulWidget {
  const UscInfo({super.key});

  @override
  State<UscInfo> createState() => UscInfoState();
}



class UscInfoState extends State<UscInfo> {

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
              InteractiveViewer(child: Image.asset('assets/images/usc_view.png')),
              SizedBox(height: 20),
              Text(
                "Режим работы платы USC",
                 style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700)
              ),
              SizedBox(height: 20),
              InteractiveViewer(child: Image.asset('assets/images/type_device.png')),
            ]
          ),
        ),
      )
    );
  } 
}