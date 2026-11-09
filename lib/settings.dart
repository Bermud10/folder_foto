import 'package:flutter/material.dart';
import 'package:folder_foto/service/photo_storage_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}


class SettingsState extends State<Settings> {

  Future<void> _changeStorageDirectory() async {
    final service = PhotoStorageService();
    
    // Вызываем тот же диалог выбора папки
    final success = await service.selectStorageDirectory();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Папка для сохранения успешно изменена!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 👇 ВАЖНО: Если ты используешь BLoC или setState для списка заказов,
      // здесь нужно обновить список, так как путь к файлам изменился.
      // Например: context.read<OrdersBloc>().add(LoadOrders());
      // Или просто: setState(() {});
      setState(() {}); 
      
    } else {
      // Пользователь нажал "Отмена" в системном диалоге
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выбор папки отменён'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                        onPressed: _changeStorageDirectory,
                        icon: const Icon(Icons.folder_open),
                        label: Text("Изменить папку сохранения", style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                    ),
                  ),
                ],
              ),
            ]
          ),
        ),
      )
    );
  } 
}