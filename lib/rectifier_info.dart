import 'package:flutter/material.dart';
import 'package:folder_foto/zoomable_image.dart';

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
              Text(
                "Настройка черного выпрямителя",
                 style:TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
              SizedBox(height: 20),
              ZoomableImage(imagePath: 'assets/images/di8ro4.png'),
            ]
          ),
        ),
      )
    );
  } 
}