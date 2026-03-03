import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:folder_foto/home_screen.dart';


List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const OrderPhotoApp());
}

class OrderPhotoApp extends StatelessWidget {
  const OrderPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Фотографии заказов',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}