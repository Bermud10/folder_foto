import 'package:flutter/material.dart';

class RectifierWhite extends StatefulWidget {
  const RectifierWhite({super.key});

  @override
  State<RectifierWhite> createState() => RectifierWhiteState();
}

class RectifierWhiteState extends State<RectifierWhite> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка серого выпрямителя'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            
          ),
        ),
      )
    );
  } 
}