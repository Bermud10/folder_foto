import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  
  String? _storageRoot;

Future<String?> _getStorageRoot() async {
    if (Platform.isAndroid) {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        _storageRoot = appDir.parent.parent.parent.parent.path;
        return _storageRoot;
      }
    }
    return'';
  }

  Future<String> getOrderPhotosPath(String number) async {
    final storageRoot = _storageRoot ?? (await getExternalStorageDirectory())?.parent.parent.parent.parent.path ?? '';
    return '$storageRoot/Pictures/OrderPhotos/$number';
  }

  Future<List<String>> loadOrderPhotos(String number) async {
    final orderPath = await getOrderPhotosPath(number);
    final dir = Directory(orderPath);
    if (!await dir.exists()) return [];
    
    final files = await dir.list().toList();
    return files
        .where((f) => f is File && (f.path.endsWith('.jpg') || f.path.endsWith('.jpeg')))
        .map((f) => f.path)
        .toList()
      ..sort();
  }
  
}