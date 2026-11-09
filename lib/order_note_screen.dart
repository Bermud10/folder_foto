import 'dart:io';
import 'package:flutter/material.dart';
import 'package:folder_foto/service/photo_storage_service.dart';

class OrderNoteScreen extends StatefulWidget {
  final String orderNumber;

  const OrderNoteScreen({super.key, required this.orderNumber});

  @override
  State<OrderNoteScreen> createState() => _OrderNoteScreenState();
}

class _OrderNoteScreenState extends State<OrderNoteScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); 
  bool _isLoading = true;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _focusNode.addListener(() {
      setState(() {}); 
    });
  }

  Future<String> _getFilePath() async {
    final service = PhotoStorageService(); // Или используй свой экземпляр сервиса
    return await service.getNoteFilePath(widget.orderNumber);
  }

  Future<void> _loadNote() async {
    try {
      _filePath = await _getFilePath();
      final file = File(_filePath!);

      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _controller.text = content;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки заметки: $e');
      setState(() => _isLoading = false);
    }
  }

   Future<void> _saveNote() async {
    // 1. Явная проверка на отсутствие пути
    if (_filePath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: Папка для сохранения не выбрана! Зайдите в настройки.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final file = File(_filePath!);
      final textToSave = _controller.text.trim();

      if (textToSave.isEmpty) {
        // Если текст стёрли, удаляем файл
        if (await file.exists()) {
          await file.delete();
        }
      } else {
        // 2. Явное и надёжное создание папки перед записью
        final parentDir = file.parent;
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
        
        // 3. Запись файла
        await file.writeAsString(textToSave);
      }
      
      // Уведомление об успехе (опционально, можно убрать, если мешает)
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Заметка сохранена'),
      //       backgroundColor: Colors.green,
      //       duration: Duration(seconds: 1),
      //     ),
      //   );
      // }
      
    } catch (e) {
      // 4. ПОКАЗЫВАЕМ ТОЧНУЮ ОШИБКУ
      debugPrint('❌ Ошибка сохранения заметки: $e');
      debugPrint('📁 Путь, который пытались использовать: $_filePath');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось сохранить: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose(); 
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveNote(); 
        if (mounted) Navigator.pop(context, true); 
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Заметка: ${widget.orderNumber}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _saveNote();
              if (mounted) Navigator.pop(context, true);
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode, 
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  cursorColor: Colors.black,
                  cursorHeight:18.0,
                  decoration: InputDecoration(
                    hintText: _focusNode.hasFocus ? null : 'Введите информацию о заказе...',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87, width: 2.0),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
      ),
    );
  }
}