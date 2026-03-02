import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

List<CameraDescription>? cameras;

// ==================== МОДЕЛЬ ЗАКАЗА ====================
class Order {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final List<String> photoPaths;

  Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    this.photoPaths = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'createdAt': createdAt.toIso8601String(),
        'photoPaths': photoPaths,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        orderNumber: json['orderNumber'],
        createdAt: DateTime.parse(json['createdAt']),
        photoPaths: List<String>.from(json['photoPaths'] ?? []),
      );
}

// ==================== ТОЧКА ВХОДА ====================
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

// ==================== ГЛАВНЫЙ ЭКРАН ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _getStorageRoot(); 
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getStringList('orders') ?? [];
    setState(() {
      _orders = ordersJson
          .map((json) => Order.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
    });
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = _orders.map((order) => jsonEncode(order.toJson())).toList();
    await prefs.setStringList('orders', ordersJson);
  }

  // 🔹 Показать диалог создания нового заказа
  Future<void> _showNewOrderDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый заказ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Номер заказа',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
          onSubmitted: (_) => _createOrder(controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => _createOrder(controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 🔹 Создать новый заказ
  Future<void> _createOrder(String orderNumber) async {
    if (orderNumber.isEmpty) {
      _showSnackBar('Введите номер заказа!');
      return;
    }

    if (_orders.any((o) => o.orderNumber == orderNumber)) {
      Navigator.pop(context);
      _showSnackBar('Заказ:  $orderNumber уже существует');
      return;
    }

    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderNumber: orderNumber,
      createdAt: DateTime.now(),
    );

    setState(() {
      _orders.insert(0, newOrder);
    });
    await _saveOrders();
    
    if (mounted) Navigator.pop(context); // Закрыть диалог
    
    // Переход на страницу заказа
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(
            order: newOrder,
            onOrderUpdated: _updateOrderInList,
          ),
        ),
      );
    }
  }

  // 🔹 Обновить заказ в списке
  void _updateOrderInList(Order updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      setState(() {
        _orders[index] = updatedOrder;
      });
      _saveOrders();
    }
  }

  Future<void> _showDeleteConfirmation(Order order) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заказ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вы действительно хотите удалить Заказ:  ${order.orderNumber}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Все фотографии этого заказа будут удалены безвозвратно',
                      style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  // 🔹 Удалить заказ и его фотографии
Future<void> _deleteOrder(Order order) async {
  try {
    // 1. Получаем корень хранилища локально
    String? storageRoot;
    if (Platform.isAndroid) {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        storageRoot = appDir.parent.parent.parent.parent.path;
      }
    }

    // 2. Удаляем папку с фотографиями
    if (storageRoot != null) {
      final orderPath = '$storageRoot/Pictures/OrderPhotos/${order.orderNumber}';
      final orderDir = Directory(orderPath);
      if (await orderDir.exists()) {
        await orderDir.delete(recursive: true);
        print('✅ Папка заказа удалена: $orderPath');
      }
    }

    // 3. Удаляем заказ из списка и сохраняем
    setState(() {
      _orders.removeWhere((o) => o.id == order.id);
    });
    await _saveOrders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заказ:  ${order.orderNumber} удалён'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    print('❌ Ошибка при удалении: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

  // 🔹 Получение корня хранилища (для удаления папок)
  Future<String?> _getStorageRoot() async {
    if (Platform.isAndroid) {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        return appDir.parent.parent.parent.parent.path;
      }
    }
    return null;
  }

  // 🔹 Открыть существующий заказ (без диалога)
  void _openExistingOrder(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          order: order,
          onOrderUpdated: _updateOrderInList,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фотографии заказов'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 🔹 Кнопка "Новый заказ"
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showNewOrderDialog,
                icon: const Icon(Icons.add, size: 24),
                label: const Text('Новый заказ', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // 🔹 Список заказов
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Нет созданных заказов',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нажмите "Новый заказ" чтобы начать',
                              style: TextStyle(color: Colors.grey[500], fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  order.orderNumber.substring(0, order.orderNumber.length.clamp(0, 2)),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                'Заказ:  ${order.orderNumber}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text('Создан: ${_formatDate(order.createdAt)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 🔹 Кнопка удаления
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(order),
                                    tooltip: 'Удалить заказ',
                                  )
                                ],
                              ),
                              onTap: () => _openExistingOrder(order),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

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
  String? _storageRoot;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _requestPermissions();
    _initializeCamera();
    _getStorageRoot();
  }

  Future<void> _getStorageRoot() async {
    if (Platform.isAndroid) {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        setState(() {
          _storageRoot = appDir.parent.parent.parent.parent.path;
        });
      }
    }
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

  Future<String> _getOrderPhotosPath() async {
    final storageRoot = _storageRoot ?? (await getExternalStorageDirectory())?.parent.parent.parent.parent.path ?? '';
    return '$storageRoot/Pictures/OrderPhotos/${_currentOrder.orderNumber}';
  }

  Future<List<String>> _loadOrderPhotos() async {
    final orderPath = await _getOrderPhotosPath();
    final dir = Directory(orderPath);
    if (!await dir.exists()) return [];
    
    final files = await dir.list().toList();
    return files
        .where((f) => f is File && (f.path.endsWith('.jpg') || f.path.endsWith('.jpeg')))
        .map((f) => f.path)
        .toList()
      ..sort();
  }

  Future<void> _takePhoto() async {
    if (_isTakingPhoto || !_isCameraInitialized || _cameraController == null) return;

    setState(() => _isTakingPhoto = true);

    try {
      final XFile photo = await _cameraController!.takePicture();
      final orderPath = await _getOrderPhotosPath();
      
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

      // уведомление о том что фотка с заказом сохранилась
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: const Text('✅ Фото сохранено'), duration: const Duration(seconds: 2)),
      //   );
      // }
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

  void _navigateToPhotos() async {
    final photos = await _loadOrderPhotos();
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGridScreen(
          orderNumber: _currentOrder.orderNumber,
          photoPaths: photos,
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
        title: Text('Заказ:  ${_currentOrder.orderNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 🔹 Номер заказа
          Padding(
            padding: const EdgeInsets.only(top: 16),
          ),

          // 🔹 Камера (40% экрана)
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CameraPreview(_cameraController!),
            ),
          ),

          // 🔹 Кнопка съёмки
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
                  _isTakingPhoto ? 'Съёмка...' : 'Сделать фото',
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

          // 🔹 Кнопка "Фотографии заказа"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToPhotos,
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text('Фотографии заказа', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== СТРАНИЦА С ФОТОГРАФИЯМИ ====================
class PhotoGridScreen extends StatefulWidget {
  final String orderNumber;
  final List<String> photoPaths;

  const PhotoGridScreen({
    super.key,
    required this.orderNumber,
    required this.photoPaths,
  });

  @override
  State<PhotoGridScreen> createState() => _PhotoGridScreenState();
}

class _PhotoGridScreenState extends State<PhotoGridScreen> {
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = widget.photoPaths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Фото заказа - ${widget.orderNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _photos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_filter, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Нет фотографий',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сделайте фото на странице заказа',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showPhotoDialog(_photos[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_photos[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPhotoDialog(String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              child: Image.file(File(photoPath), fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}