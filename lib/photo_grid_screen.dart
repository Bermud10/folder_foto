// ==================== СТРАНИЦА С ФОТОГРАФИЯМИ ====================
import 'dart:io';

import 'package:flutter/material.dart';

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
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
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
                    Positioned(right: 0, top: 2, child: Icon(Icons.delete_outline, color: Colors.red,),)
                    ],
                  ),
                );
              },
            ),
    );
  }

 void _showPhotoDialog(String photoPath) {
  // 🔹 1. Находим индекс текущего фото в списке
  final currentIndex = _photos.indexOf(photoPath);
  
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      fullscreenDialog: true,
      builder: (context) => PageView.builder(
        controller: PageController(initialPage: currentIndex),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.pop(context), // Закрыть по тапу
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.file(
                File(_photos[index]),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.white70, size: 64),
                  );
                },
              ),
            ),
          );
        },
      )
    );
  }
}