import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {

  /// Android/data/com.example.folder_foto/files/
  Future<Directory> _getAppDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('Не удалось получить доступ к хранилищу');
    }
    return directory;
  }

  Future<String> getOrderPhotosPath(String number) async {
    final appDir = await _getAppDirectory();
    final orderDirPath = '${appDir.path}/OrderPhotos/$number/photos';

    // Создаём папку, если её ещё нет
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
              (f.path.endsWith('.jpg') || f.path.endsWith('.jpeg')))
          .map((f) => f.path)
          .toList()
        ..sort();
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
      final appDir = await _getAppDirectory();
      final orderDir = Directory('${appDir.path}/OrderPhotos/$number');
      
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
      final appDir = await getExternalStorageDirectory();
      if (appDir == null) return false;
      
      final file = File('${appDir.path}/OrderPhotos/$orderNumber/note.txt');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        // Возвращаем true только если в файле есть текст (игнорируем пробелы и переносы строк)
        return content.trim().isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}