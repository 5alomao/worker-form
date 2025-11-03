import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
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
