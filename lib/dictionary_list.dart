import 'package:flutter/material.dart';
import 'package:folder_foto/amperage.dart';
import 'package:folder_foto/anks3m.dart';
import 'package:folder_foto/component_check/component_navigator.dart';
import 'package:folder_foto/di8_ro4_info.dart';
import 'package:folder_foto/directory.dart';
import 'package:folder_foto/rectifier/rectifier_info.dart';
import 'package:folder_foto/usc_info.dart';
import 'package:folder_foto/widgets/custom_button.dart';

class DictionaryList extends StatefulWidget {
  const DictionaryList({super.key});

  @override
  State<DictionaryList> createState() => DictionaryListState();
}


class DictionaryListState extends State<DictionaryList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочник'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomButton(label: 'Уставки', icon: Icons.book, target: DirectoryPage()),
            const SizedBox(height: 12),
            CustomButton(label: 'DI8RO4 адреса', icon: Icons.settings, target: Di8Ro4Info()),
            const SizedBox(height: 12),
            CustomButton(label: 'плата USC', icon: Icons.settings, target: UscInfo()),
            const SizedBox(height: 12),
            CustomButton(label: 'Допустимый ток КЛ', icon: Icons.bolt_outlined, target: Amperage()),
            const SizedBox(height: 12),
            CustomButton(label: 'Настройки выпрямителей', icon: Icons.drag_handle, target: RectifierInfo()),
            const SizedBox(height: 12),
            CustomButton(label: 'Проверка компонентов', icon: Icons.perm_data_setting_rounded, target: ComponentNavigator()),
            const SizedBox(height: 12),
            CustomButton(label: 'ЭНКС 3М', icon: Icons.bento, target: Anks3m()),
          ],
          
        ),
      )
    );
  } 
}