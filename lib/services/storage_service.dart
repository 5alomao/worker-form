import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static SharedPreferences? _prefs;

  StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'StorageService não inicializado. Chame initialize() primeiro.',
      );
    }
    return _prefs!;
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
    try {
      String hashedPassword = _hashPassword(password);
      List<String> users = prefs.getStringList('users') ?? [];

      for (String userJson in users) {
        Map<String, dynamic> user = json.decode(userJson);
        if (user['email'] == email && user['password_hash'] == hashedPassword) {
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao validar usuário: $e');
      return null;
    }
  }

  // Criar novo usuário
  Future<int> createUser(String email, String password) async {
    try {
      List<String> users = prefs.getStringList('users') ?? [];
      int nextId = users.length + 1;

      Map<String, dynamic> newUser = {
        'id': nextId,
        'email': email,
        'password_hash': _hashPassword(password),
        'created_at': DateTime.now().toIso8601String(),
      };

      users.add(json.encode(newUser));
      await prefs.setStringList('users', users);

      return nextId;
    } catch (e) {
      debugPrint('Erro ao criar usuário: $e');
      rethrow;
    }
  }

  // Verificar se email já existe
  Future<bool> emailExists(String email) async {
    try {
      List<String> users = prefs.getStringList('users') ?? [];

      for (String userJson in users) {
        Map<String, dynamic> user = json.decode(userJson);
        if (user['email'] == email) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao verificar email: $e');
      return false;
    }
  }

  // Inserir resposta do formulário
  Future<int> insertFormResponse(Map<String, dynamic> formData) async {
    try {
      List<String> responses = prefs.getStringList('form_responses') ?? [];
      int nextId = responses.length + 1;

      formData['id'] = nextId;
      formData['created_at'] = DateTime.now().toIso8601String();

      responses.add(json.encode(formData));
      await prefs.setStringList('form_responses', responses);

      return nextId;
    } catch (e) {
      debugPrint('Erro ao inserir resposta: $e');
      rethrow;
    }
  }

  // Buscar todas as respostas
  Future<List<Map<String, dynamic>>> getAllFormResponses() async {
    try {
      List<String> responses = prefs.getStringList('form_responses') ?? [];
      List<Map<String, dynamic>> result = [];

      for (String responseJson in responses) {
        result.add(json.decode(responseJson));
      }

      // Ordenar por data (mais recente primeiro)
      result.sort((a, b) => b['created_at'].compareTo(a['created_at']));

      return result;
    } catch (e) {
      debugPrint('Erro ao buscar respostas: $e');
      return [];
    }
  }

  // Buscar respostas por usuário
  Future<List<Map<String, dynamic>>> getFormResponsesByUser(int userId) async {
    try {
      List<Map<String, dynamic>> allResponses = await getAllFormResponses();
      return allResponses
          .where((response) => response['user_id'] == userId)
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar respostas do usuário: $e');
      return [];
    }
  }
}
