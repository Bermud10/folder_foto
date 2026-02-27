import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

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
      title: 'Фото для Заказа',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const OrderPhotoScreen(),
    );
  }
}

class OrderPhotoScreen extends StatefulWidget {
  const OrderPhotoScreen({super.key});

  @override
  State<OrderPhotoScreen> createState() => _OrderPhotoScreenState();
}

class _OrderPhotoScreenState extends State<OrderPhotoScreen> {
  final TextEditingController _orderController = TextEditingController();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isTakingPhoto = false;
  final List<String> _takenPhotos = [];
  String? _currentFolderPath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeCamera();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.camera.request();
      await Permission.storage.request();
    } else if (Platform.isIOS) {
      await Permission.camera.request();
      await Permission.photos.request();
    }
  }

  Future<void> _initializeCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    _cameraController = CameraController(
      cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });
  }

  
  Future<void> _takePhoto() async {
  final orderNumber = _orderController.text.trim();

  if (orderNumber.isEmpty) {
    _showSnackBar('Введите номер заказа!');
    return;
  }

  if (_isTakingPhoto || !_isCameraInitialized || _cameraController == null) return;

  setState(() {
    _isTakingPhoto = true;
  });

  try {
    // 1. Делаем снимок
    final XFile photo = await _cameraController!.takePicture();

    // ✅ 2. ПРАВИЛЬНЫЙ ПУТЬ - добавляем ещё один .parent
    final Directory? appDir = await getExternalStorageDirectory();
    if (appDir == null) throw Exception('Нет доступа к хранилищу');
    
    // Переходим из /Android/data/com.example.folder_foto/files
    // в /storage/emulated/0 (корень хранилища)
    final String storageRoot = appDir.parent.parent.parent.parent.path; // ← 4 раза .parent!
    final String orderPath = '$storageRoot/Pictures/OrderPhotos/$orderNumber';
    
    print('📁 Корень хранилища: $storageRoot');
    print('📁 Сохраняем в: $orderPath');

    // ✅ 3. Создаём папку
    final Directory orderDir = Directory(orderPath);
    if (!await orderDir.exists()) {
      await orderDir.create(recursive: true);
      print('✅ Папка создана');
    }

    // ✅ 4. Имя файла
    final fileName = '${orderNumber}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File savedFile = File('$orderPath/$fileName');
    
    // ✅ 5. Копируем файл
    await File(photo.path).copy(savedFile.path);
    print('✅ Фото сохранено: ${savedFile.path}');

    // ✅ 6. Обновляем UI
    setState(() {
      _takenPhotos.add(savedFile.path);
      _currentFolderPath = orderPath;
    });

    _showSnackBar('✅ Фото сохранено:\nPictures/OrderPhotos/$orderNumber');
  } catch (e) {
    print('❌ Ошибка: $e');
    _showSnackBar('Ошибка: ${e.toString()}');
  } finally {
    setState(() {
      _isTakingPhoto = false;
    });
  }
}

 // ✅ Метод для сканирования файла (чтобы фото появилось в галерее)
Future<void> _scanFile(String filePath) async {
  if (Platform.isAndroid) {
    // Используем MediaScanner через platform channel (опционально)
    // Или просто ждём, пока система сама просканирует папку
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  // Экран загрузки камеры
  if (!_isCameraInitialized) {
    return Scaffold(
      appBar: AppBar(title: const Text('Фото для Заказа')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Инициализация камеры...'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Фото для Заказа'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: Column(
      children: [
        // 🔹 Поле ввода номера заказа (фиксированная высота)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _orderController,
            decoration: const InputDecoration(
              labelText: 'Номер заказа',
              hintText: 'Например: 12345',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            keyboardType: TextInputType.number,
          ),
        ),

        // 🔹 Предпросмотр камеры (занимает 40% экрана)
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CameraPreview(_cameraController!),
          ),
        ),

        // 🔹 Кнопка съёмки (фиксированная высота)
        Container(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTakingPhoto ? null : _takePhoto,
              icon: _isTakingPhoto
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt, size: 24),
              label: Text(
                _isTakingPhoto ? 'Съёмка...' : '📸 Сделать фото',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // 🔹 Предпросмотр сделанных фото (занимает 30% экрана, с прокруткой)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Сделано в этой сессии:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              // ✅ GridView с правильными настройками
              Expanded(
                child: _takenPhotos.isEmpty
                    ? const Center(child: Text('Фото пока нет', style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.85, // Высота чуть больше ширины для превью
                        ),
                        itemCount: _takenPhotos.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_takenPhotos[index]),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}