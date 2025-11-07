import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'services/storage_service.dart';

void main() async {
  // OBRIGATÓRIO para operações assíncronas antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar o StorageService (funciona em todas as plataformas)
    final storageService = StorageService();
    await storageService.initialize();

    debugPrint('Sistema de armazenamento inicializado com sucesso');
  } catch (e) {
    debugPrint('Erro ao inicializar armazenamento: $e');
  }

  runApp(const PesquisaApp());
}

class PesquisaApp extends StatelessWidget {
  const PesquisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesquisa Profissional',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
