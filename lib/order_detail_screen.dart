import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:folder_foto/main.dart';
import 'package:folder_foto/photo_grid_screen.dart';
import 'package:folder_foto/service/photo_storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:folder_foto/order.dart';


// ==================== СТРАНИЦА ЗАКАЗА ====================
class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final Function(Order) onOrderUpdated;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isTakingPhoto = false;
  late Order _currentOrder;
  final service = PhotoStorageService();

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
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

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка камеры: $e'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_isTakingPhoto || !_isCameraInitialized || _cameraController == null) return;

    setState(() => _isTakingPhoto = true);

    try {
      
      await _cameraController!.setFlashMode(FlashMode.off);
      
      final XFile photo = await _cameraController!.takePicture();
      
      
      final orderPath = await service.getOrderPhotosPath(_currentOrder.orderNumber);
      
      final orderDir = Directory(orderPath);
      if (!await orderDir.exists()) {
        await orderDir.create(recursive: true);
      }

      final fileName = '${_currentOrder.orderNumber}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File('$orderPath/$fileName');
      await File(photo.path).copy(savedFile.path);

      // Обновляем заказ с новым фото
      final updatedOrder = Order(
        id: _currentOrder.id,
        orderNumber: _currentOrder.orderNumber,
        createdAt: _currentOrder.createdAt,
        photoPaths: [..._currentOrder.photoPaths, savedFile.path],
      );
      
      setState(() => _currentOrder = updatedOrder);
      widget.onOrderUpdated(updatedOrder);
    } catch (e) {
      print('❌ Ошибка: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}'), duration: const Duration(seconds: 3)),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

 Future<void> _focusOnTap(TapDownDetails details) async {
  
  if(_cameraController == null || !_cameraController!.value.isInitialized) return;

  final sizeScreen = MediaQuery.of(context).size;

  final x = details.localPosition.dx / sizeScreen.width;
  final y = details.localPosition.dy / sizeScreen.height;

  await _cameraController!.setFocusPoint(Offset(x, y));
  await _cameraController!.setFocusMode(FocusMode.auto);
 }


  void _navigateToPhotos() async {
    final photos = await service.loadOrderPhotos(_currentOrder.orderNumber);
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGridScreen(
          orderNumber: _currentOrder.orderNumber,
          photoPaths: photos,
          onPhotoDeleted: (deletedPhotoPath) {
          // Обновить Order (убрать путь из photoPaths)
          final updatedOrder = Order(
            id: _currentOrder.id,
            orderNumber: _currentOrder.orderNumber,
            createdAt: _currentOrder.createdAt,
            photoPaths: _currentOrder.photoPaths
                .where((p) => p != deletedPhotoPath)
                .toList(),
          );
          
          // Обновить состояние
          setState(() => _currentOrder = updatedOrder);
          
          // Сохранить в SharedPreferences
          widget.onOrderUpdated(updatedOrder);
        },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Заказ:  ${_currentOrder.orderNumber}')),
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
        title: Text('Заказ:  ${_currentOrder.orderNumber}', style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: 
      Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapDown: _focusOnTap ,
            child: CameraPreview(_cameraController!)
          ),
          Positioned(
           bottom: 40,
           left: 0,
           right: 0,
           child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _navigateToPhotos,
                  child:
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.photo_library, size: 35,color: Color.fromARGB(180, 255, 255, 255)),
                    ),
                  ),
                ),
              ),
           
              Expanded(
                child: GestureDetector(
                  onTap: _isTakingPhoto ? null : _takePhoto,
                  child:
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: _isTakingPhoto ? 
                      SizedBox(
                        width: 75,
                        height: 75,
                        child: CircularProgressIndicator(
                          strokeWidth: 5, 
                          color: Colors.white, 
                          padding: const EdgeInsets.all(8.0)
                        ),
                      )
                     : Icon(Icons.circle, size: 75, color: Color.fromARGB(180, 255, 255, 255),),
                    ),
                  ),
                ),
              ),
           
              Expanded(child: Container())
              ],
            ))
        ]
      )
    );
  }
}