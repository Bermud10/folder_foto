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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          // seedColor: const Color.fromARGB(255, 26, 37, 82),
          seedColor: const Color.fromARGB(255, 26, 82, 37),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}