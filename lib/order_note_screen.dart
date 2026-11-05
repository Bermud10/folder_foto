import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
    Directory directory;
    if (Platform.isAndroid) {
      final appDir = await getExternalStorageDirectory();
      if (appDir == null) throw Exception('Не удалось получить доступ к хранилищу');
      directory = appDir;
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return '${directory.path}/OrderPhotos/${widget.orderNumber}/note.txt';
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
    if (_filePath == null) return;

    try {
      final file = File(_filePath!);
      final textToSave = _controller.text.trim();

      if (textToSave.isEmpty) {
        if (await file.exists()) {
          await file.delete();
        }
      } else {
        await file.parent.create(recursive: true);
        await file.writeAsString(textToSave);
      }
    } catch (e) {
      debugPrint('Ошибка сохранения: $e');
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