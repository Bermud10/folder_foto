import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class PhotoStorageService {
  static const String _dirKey = 'shandbook_storage_directory';

  /// 1. ВЫБОР ПАПКИ: Вызывается один раз при первом запуске или в настройках
  Future<bool> selectStorageDirectory() async {
    String? selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Выберите папку для сохранения заказов',
    );

    if (selectedPath != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dirKey, selectedPath);
      return true;
    }
    return false; // Пользователь отменил выбор
  }

  /// 2. ПОЛУЧЕНИЕ БАЗОВОЙ ПАПКИ: Заменяет getExternalStorageDirectory()
  Future<Directory> _getBaseDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_dirKey);

    if (savedPath == null || savedPath.isEmpty) {
      throw Exception('Папка для сохранения не выбрана. Пожалуйста, выберите её в настройках.');
    }

    final directory = Directory(savedPath);
    if (!await directory.exists()) {
      // Если пользователь удалил папку вручную, сбрасываем настройку
      await prefs.remove(_dirKey);
      throw Exception('Выбранная папка больше не существует. Выберите новую.');
    }

    return directory;
  }

  Future<String> getOrderPhotosPath(String number) async {
    final baseDir = await _getBaseDirectory();
    // Структура: Выбранная_Папка/OrderPhotos/[номер_заказа]/photos
    final orderDirPath = '${baseDir.path}/OrderPhotos/$number/photos';
    final orderDir = Directory(orderDirPath);

    if (!await orderDir.exists()) {
      await orderDir.create(recursive: true);
    }

    return orderDirPath;
  }


  Future<List<String>> loadOrderPhotos(String number) async {
    try {
      final orderPath = await getOrderPhotosPath(number);
      final dir = Directory(orderPath);
      
      if (!await dir.exists()) return [];

      final files = await dir.list().toList();
      return files
          .where((f) => f is File && 
              (f.path.toLowerCase().endsWith('.jpg') || f.path.toLowerCase().endsWith('.jpeg')))
          .map((f) => f.path)
          .toList()
        ..sort(); // Сортировка по имени
    } catch (e) {
      print('❌ Ошибка загрузки фото заказа $number: $e');
      return [];
    }
  }

  Future<void> deleteFoto(String photoPath) async {
    final file = File(photoPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteOrderDirectory(String number) async {
    try {
      final baseDir = await _getBaseDirectory();
      final orderDir = Directory('${baseDir.path}/OrderPhotos/$number');
      
      if (await orderDir.exists()) {
        await orderDir.delete(recursive: true);
      }
    } catch (e) {
      print('❌ Ошибка удаления папки заказа $number: $e');
      rethrow;
    }
  }

  Future<bool> hasPhotos(String number) async {
    final photos = await loadOrderPhotos(number);
    return photos.isNotEmpty;
  }

  Future<bool> hasNote(String orderNumber) async {
    try {
      final baseDir = await _getBaseDirectory();
      final filePath = '${baseDir.path}/OrderPhotos/$orderNumber/note.txt';
      final file = File(filePath);
      
      if (await file.exists()) {
        final content = await file.readAsString();
        return content.trim().isNotEmpty;
      }
      return false;
    } catch (e) {
      print('❌ Ошибка проверки заметки: $e');
      return false;
    }
  }

  Future<String> getNoteFilePath(String orderNumber) async {
    final baseDir = await _getBaseDirectory();
    final noteDir = Directory('${baseDir.path}/OrderPhotos/$orderNumber');
    
    if (!await noteDir.exists()) {
      await noteDir.create(recursive: true);
    }
    
    return '${noteDir.path}/note.txt';
  }
}