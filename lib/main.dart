import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'order.dart';
import 'order_detail_screen.dart';
List<CameraDescription>? cameras;



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