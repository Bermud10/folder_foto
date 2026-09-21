import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget{

 final String label;
 final IconData icon;
 final Widget target;


 const CustomButton({
  super.key,
  required this.label,
  required this.icon,
  required this.target,
 });

  @override
  State<CustomButton> createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton>{
  
  @override
  Widget build(BuildContext context){
    return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => widget.target));
                  },
                  icon: Icon(widget.icon, size: 24),
                  label: Text(widget.label, style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          );
  }
}