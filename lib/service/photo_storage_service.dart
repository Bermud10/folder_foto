import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  
  String? _storageRoot;



  Future<String> getOrderPhotosPath(String number) async {

   if(_storageRoot != null && _storageRoot !=''){
      return '$_storageRoot/Pictures/OrderPhotos/$number';
    }

    final path = (await getExternalStorageDirectory())?.parent.parent.parent.parent.path;

    if(path != null){
      _storageRoot = path;
      return '$_storageRoot/Pictures/OrderPhotos/$number';
    }

    throw Exception('Не удалось получить доступ к хранилищу');
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

  Future<void> deleteFoto(String photoPath) async {

    final file = File(photoPath);
    
    if (await file.exists()) {
      await file.delete();
    }
  }
  
}