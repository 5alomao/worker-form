import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  // Método para inicialização explícita
  Future<void> initializeDatabase() async {
    _database ??= await _initDatabase();
  }

  Future<Database> get database async {
    try {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      // Removido print para produção
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'worker_form.db');
      debugPrint('Caminho do banco: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) {
          debugPrint('Banco de dados aberto com sucesso');
        },
      );
    } catch (e) {
      debugPrint('Erro ao criar banco de dados: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Criação da tabela de usuários
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Criação da tabela de respostas do formulário
    await db.execute('''
      CREATE TABLE form_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        idade TEXT NOT NULL,
        escolaridade TEXT NOT NULL,
        situacao TEXT NOT NULL,
        plano_carreira TEXT NOT NULL,
        area_interesse TEXT NOT NULL,
        experiencia TEXT NOT NULL,
        descricao_experiencia TEXT,
        preocupacao TEXT NOT NULL,
        palavra_futuro TEXT NOT NULL,
        expectativas TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Inserir usuário padrão com senha criptografada
    String defaultPassword = _hashPassword('123456');
    await db.insert('users', {
      'email': 'admin@test.com',
      'password_hash': defaultPassword,
    });
  }

  // Função para gerar hash da senha
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validar login do usuário
  Future<Map<String, dynamic>?> validateUser(
    String email,
    String password,
  ) async {
    final db = await database;
    String hashedPassword = _hashPassword(password);

    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, hashedPassword],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Inserir resposta do formulário
  Future<int> insertFormResponse(Map<String, dynamic> formData) async {
    final db = await database;
    return await db.insert('form_responses', formData);
  }

  // Buscar respostas por usuário
  Future<List<Map<String, dynamic>>> getFormResponsesByUser(int userId) async {
    final db = await database;
    return await db.query(
      'form_responses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Buscar todas as respostas
  Future<List<Map<String, dynamic>>> getAllFormResponses() async {
    final db = await database;
    return await db.query('form_responses', orderBy: 'created_at DESC');
  }

  // Criar novo usuário
  Future<int> createUser(String email, String password) async {
    final db = await database;
    String hashedPassword = _hashPassword(password);

    return await db.insert('users', {
      'email': email,
      'password_hash': hashedPassword,
    });
  }

  // Verificar se email já existe
  Future<bool> emailExists(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Fechar banco de dados
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
