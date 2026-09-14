import 'package:flutter/material.dart';
import 'package:folder_foto/rectifier/rectifier_black.dart';
import 'package:folder_foto/rectifier/rectifier_white.dart';

class RectifierInfo extends StatefulWidget {
  const RectifierInfo({super.key});

  @override
  State<RectifierInfo> createState() => RectifierInfoState();
}

class RectifierInfoState extends State<RectifierInfo> {

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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RectifierBlack()));
                      },
                      icon: Icon(Icons.build_circle, size: 24),
                      label: Text('Черный выпрямитель', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RectifierWhite()));
                      },
                      icon: Icon(Icons.build_circle_outlined, size: 24),
                      label: Text('Серый выпрямитель', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ),
        ),
      )
    );
  } 
}