import 'package:flutter/material.dart';
import 'package:folder_foto/amperage.dart';
import 'package:folder_foto/di8_ro4_info.dart';
import 'package:folder_foto/directory.dart';
import 'package:folder_foto/rectifier_info.dart';
import 'package:folder_foto/usc_info.dart';

class DictionaryList extends StatefulWidget {
  const DictionaryList({super.key});

  @override
  State<DictionaryList> createState() => DictionaryListState();
}


class DictionaryListState extends State<DictionaryList> {

  Widget buttonTemplate(String lable, IconData icon, Widget target){
    return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => target));
                  },
                  icon: Icon(icon, size: 24),
                  label: Text(lable, style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          );
  }

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
            buttonTemplate('Уставки', Icons.book, DirectoryPage()),
            SizedBox(height: 12),
            buttonTemplate('DI8RO4 адреса', Icons.settings, Di8Ro4Info()),
            SizedBox(height: 12),
            buttonTemplate('плата USC', Icons.settings, UscInfo()),
            SizedBox(height: 12),
            buttonTemplate('Допустимый ток КЛ', Icons.bolt_outlined, Amperage()),
            SizedBox(height: 12),
            buttonTemplate('Настройки выпрямителей', Icons.drag_handle, RectifierInfo()),
          ],
          
        ),
      )
    );
  } 
}