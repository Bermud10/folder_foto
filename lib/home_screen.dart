import 'dart:io';
import 'package:flutter/material.dart';
import 'package:folder_foto/battery_calculator.dart';
import 'package:folder_foto/dictionary_list.dart';
import 'package:folder_foto/order_note_screen.dart';
import 'package:folder_foto/photo_grid_screen.dart';
import 'package:folder_foto/service/photo_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'order.dart';
import 'camera_screen.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:isolate';

// ==================== ГЛАВНЫЙ ЭКРАН ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<String> _buildZipArchive(Map<String, dynamic> params) async {
  final String orderNumber = params['orderNumber'] as String;
  final List<String> filePaths = params['filePaths'] as List<String>;
  final String tempDirPath = params['tempDirPath'] as String;

  final archive = Archive();
  
  for (var path in filePaths) {
    final file = File(path);
    final fileBytes = await file.readAsBytes();
    final relativePath = 'Заказ_$orderNumber/${path.split('/').last}';
    archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));
  }

  final zipData = ZipEncoder().encode(archive);
  if (zipData == null) throw Exception('Не удалось создать архив');

  final zipFile = File('$tempDirPath/Заказ_$orderNumber.zip');
  await zipFile.writeAsBytes(zipData);
  
  return zipFile.path;
}

class _HomeScreenState extends State<HomeScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  final service = PhotoStorageService();

  @override
  void initState() {
    super.initState();
    _loadOrders();
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
          autofocus: true,
          onSubmitted: (_) => _validateNameOrder(controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => _validateNameOrder(controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _validateNameOrder(String orderNumber) async {
    if (orderNumber.isEmpty) {
      _showSnackBar('Введите номер заказа!');
      return;
    }

    if (!RegExp(r'^[a-zA-Zа-яА-Я0-9_-]+$').hasMatch(orderNumber)) {
      _showSnackBar('Только буквы и цифры');
      return ;
    }

    if (_orders.any((o) => o.orderNumber.toLowerCase() == orderNumber.toLowerCase())) {
      Navigator.pop(context);
      _showSnackBar('Заказ:  $orderNumber уже существует');
      return;
    }

    _createOrder(orderNumber);

  }

  // 🔹 Создать новый заказ
  Future<void> _createOrder(String orderNumber) async {

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
          builder: (context) => CameraScreen(
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
        title: const Text(
          'Удалить заказ?',
          textAlign: TextAlign.center
          ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Все фотографии заказа ${order.orderNumber} будут удалены',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          const SizedBox(width: 12),
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
      // 1. Удаляем папку с фото и заметками через сервис
      await service.deleteOrderDirectory(order.orderNumber);

      // 2. Удаляем заказ из списка и сохраняем
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

  // 🔹 Открыть существующий заказ (без диалога)
  void _openExistingOrder(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          order: order,
          onOrderUpdated: _updateOrderInList,
        ),
      ),
    );
  }

  void _navigateToNote(Order order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderNoteScreen(orderNumber: order.orderNumber),
      ),
    );
    
    if (mounted) {
      setState(() {});
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToGallery(Order order) async {

    print(order.orderNumber);

   List<String> photos =  await service.loadOrderPhotos(order.orderNumber);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGridScreen(
          orderNumber: order.orderNumber,
          photoPaths:photos
        ),
      ),
    );
  }

  void _openDirectory() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DictionaryList()));
  }

  void _openCalculator() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BatteryCalculator()));
  }

    // Отправка файлов без архива
  Future<void> _shareOrderPhotos(String orderNumber) async {
    try {
      final service = PhotoStorageService();
      final photos = await service.loadOrderPhotos(orderNumber);
      final notePath = await service.getNoteFilePath(orderNumber);
      final noteFile = File(notePath);

      final files = <XFile>[];
      for (var photoPath in photos) {
        files.add(XFile(photoPath));
      }
      if (await noteFile.exists()) {
        files.add(XFile(notePath));
      }

      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Нет файлов для отправки')),
          );
        }
        return;
      }

      await Share.shareXFiles(files);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


Future<void> _exportOrderAsZip(String orderNumber) async {
  // 1. Показываем индикатор
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Архивирую...'),
        ],
      ),
    ),
  );

  try {
    final service = PhotoStorageService();
    final orderPath = await service.getOrderPhotosPath(orderNumber);
    final orderDir = Directory(orderPath);
    final parentDir = orderDir.parent;

    if (!await parentDir.exists()) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Папка заказа не найдена')),
        );
      }
      return;
    }

    // Собираем список всех файлов
    final files = await parentDir.list(recursive: true).toList();
    final filePaths = files.whereType<File>().map((f) => f.path).toList();

    if (filePaths.isEmpty) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет файлов для архивации')),
        );
      }
      return;
    }

    // Получаем путь к временной папке (нужен для isolate)
    final tempDir = await getTemporaryDirectory();

    // 2. ⚡ Запускаем архивацию в отдельном потоке!
    final zipPath = await Isolate.run(() => _buildZipArchive({
      'orderNumber': orderNumber,
      'filePaths': filePaths,
      'tempDirPath': tempDir.path,
    }));

    // 3. Закрываем индикатор
    if (mounted) Navigator.pop(context);

    // 4. Отправляем файл
    await Share.shareXFiles([XFile(zipPath)]);

    // 5. Удаляем временный ZIP
    await File(zipPath).delete();

  } catch (e) {
    if (mounted) Navigator.pop(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фотографии заказов'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child:
                  ElevatedButton.icon(
                    onPressed: _openCalculator,
                    icon: const Icon(Icons.calculate, size: 24),
                    label: const Text('Калькулятор', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(child: 
                  ElevatedButton.icon(
                    onPressed: _openDirectory,
                    icon: const Icon(Icons.book_outlined, size: 24),
                    label: const Text('Справочник', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                              'Нажмите "+ Заказ" чтобы начать',
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
                              title: Text(
                                'Заказ:  ${order.orderNumber}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text('Создан: ${_formatDate(order.createdAt)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 🔹 создание заметки
                                 PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    borderRadius: BorderRadius.circular(8),
                                    onSelected: (value) {
                                      if (value == 'note') {
                                        _navigateToNote(order); 
                                      } else if (value == 'export_zip') {
                                        _exportOrderAsZip(order.orderNumber);
                                      } else if (value == 'share') {
                                        _shareOrderPhotos(order.orderNumber); 
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'note',
                                        child: Row(children: [Icon(Icons.edit_note, size: 20), SizedBox(width: 12), Text('Заметка')]),
                                      ),
                                      const PopupMenuItem(
                                        value: 'export_zip',
                                        child: Row(children: [Icon(Icons.send_and_archive, size: 20), SizedBox(width: 12), Text('Отправить в zip')]),
                                      ),
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Row(children: [Icon(Icons.share, size: 20), SizedBox(width: 12), Text('Отправить файлы')]),
                                      ),
                                    ],
                                    
                                  ),
                                  const SizedBox( width: 12),
                                   // 🔹 перехода в галерею
                                  IconButton(
                                    icon: const Icon(Icons.photo_library, color: Color.fromARGB(255, 77, 73, 73)),
                                    onPressed: () => _navigateToGallery(order),
                                    tooltip: 'Перейти в галерею заказа',
                                  ),
                                  const SizedBox( width: 12),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(18.0),
        child: FloatingActionButton.extended(
          onPressed: _showNewOrderDialog,
          icon: const Icon(Icons.add, size: 24),
          label: const Text('Заказ'),
          foregroundColor: const Color.fromARGB(255, 26, 82, 37),
          backgroundColor: const Color.fromARGB(255, 242, 246, 243),
          ),
      ),
    );
  }
}