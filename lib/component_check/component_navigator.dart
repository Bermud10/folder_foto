import 'package:flutter/material.dart';
import 'package:folder_foto/component_check/current_sensor.dart';
import 'package:folder_foto/component_check/thyristor_module.dart';
import 'package:folder_foto/component_check/transistor_module.dart';
import 'package:folder_foto/widgets/custom_button.dart';

class ComponentNavigator extends StatefulWidget {
  const ComponentNavigator({super.key});

  @override
  State<ComponentNavigator> createState() => ComponentNavigatorState();
}

class ComponentNavigatorState extends State<ComponentNavigator> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка выпрямителей'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
           children: [
            CustomButton(
              label: 'Тиристорный модуль',
              icon: Icons.build_circle,
              target: ThyristorModule(),
            ),
            const SizedBox(height: 8),
            CustomButton(
              label: 'Транзисторный модуль',
              icon: Icons.build_circle_outlined,
              target: TransistorModule(),
            ),
            const SizedBox(height: 8),
            CustomButton(
              label: 'Токовый датчик',
              icon: Icons.offline_bolt_outlined,
              target: CurrentSensor(),
            ),
          ],
          ),
        ),
      )
    );
  } 
}