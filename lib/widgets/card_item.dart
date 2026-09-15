import 'package:flutter/material.dart';

class CardItem extends StatefulWidget{

 final String label;
 final String body;

 const CardItem({
  super.key,
  required this.label,
  required this.body,
 });

  @override
  State<CardItem> createState() => CardItemState();
}

class CardItemState extends State<CardItem>{
  
  @override
  Widget build(BuildContext context){
     return Card(
      child: ListTile(
        title: Text(
          widget.label,  // Обращаемся через widget.
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(widget.body),
      ),
    );
  }
}