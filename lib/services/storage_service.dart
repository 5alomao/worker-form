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
  Future<int> createUser(
    String email,
    String password, {
    String userType = 'usuario',
  }) async {
    try {
      List<String> users = prefs.getStringList('users') ?? [];
      int nextId = users.length + 1;

      Map<String, dynamic> newUser = {
        'id': nextId,
        'email': email,
        'password_hash': _hashPassword(password),
        'user_type': userType,
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

  // === MÉTODOS CRUD PARA USUÁRIOS ===

  // Listar todos os usuários
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      List<String> users = prefs.getStringList('users') ?? [];
      List<Map<String, dynamic>> result = [];

      for (String userJson in users) {
        Map<String, dynamic> user = json.decode(userJson);
        // Remove a senha hash por segurança
        user.remove('password_hash');
        result.add(user);
      }

      // Ordenar por email
      result.sort((a, b) => (a['email'] ?? '').compareTo(b['email'] ?? ''));

      return result;
    } catch (e) {
      debugPrint('Erro ao buscar usuários: $e');
      return [];
    }
  }

  // Buscar usuário por ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      List<String> users = prefs.getStringList('users') ?? [];

      for (String userJson in users) {
        Map<String, dynamic> user = json.decode(userJson);
        if (user['id'] == userId) {
          // Remove a senha hash por segurança
          user.remove('password_hash');
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar usuário: $e');
      return null;
    }
  }

  // Atualizar senha do usuário
  Future<bool> updateUserPassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      List<String> users = prefs.getStringList('users') ?? [];
      String oldPasswordHash = _hashPassword(oldPassword);

      for (int i = 0; i < users.length; i++) {
        Map<String, dynamic> user = json.decode(users[i]);
        if (user['id'] == userId) {
          // Verificar senha antiga
          if (user['password_hash'] != oldPasswordHash) {
            return false; // Senha antiga incorreta
          }

          // Atualizar senha
          user['password_hash'] = _hashPassword(newPassword);
          users[i] = json.encode(user);
          await prefs.setStringList('users', users);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar senha: $e');
      return false;
    }
  }

  // Excluir usuário
  Future<bool> deleteUser(int userId) async {
    try {
      List<String> users = prefs.getStringList('users') ?? [];

      for (int i = 0; i < users.length; i++) {
        Map<String, dynamic> user = json.decode(users[i]);
        if (user['id'] == userId) {
          users.removeAt(i);
          await prefs.setStringList('users', users);

          // Também remove as respostas do formulário deste usuário
          await _deleteUserFormResponses(userId);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao excluir usuário: $e');
      return false;
    }
  }

  // Método auxiliar para remover respostas do usuário excluído
  Future<void> _deleteUserFormResponses(int userId) async {
    try {
      List<String> responses = prefs.getStringList('form_responses') ?? [];
      List<String> filteredResponses = [];

      for (String responseJson in responses) {
        Map<String, dynamic> response = json.decode(responseJson);
        if (response['user_id'] != userId) {
          filteredResponses.add(responseJson);
        }
      }

      await prefs.setStringList('form_responses', filteredResponses);
    } catch (e) {
      debugPrint('Erro ao remover respostas do usuário: $e');
    }
  }

  // === MÉTODOS PARA QUIZ ===

  // Salvar resultado do quiz
  Future<int> insertQuizResult(Map<String, dynamic> quizData) async {
    try {
      List<String> results = prefs.getStringList('quiz_results') ?? [];
      int nextId = results.length + 1;

      quizData['id'] = nextId;
      quizData['created_at'] = DateTime.now().toIso8601String();

      results.add(json.encode(quizData));
      await prefs.setStringList('quiz_results', results);

      return nextId;
    } catch (e) {
      debugPrint('Erro ao salvar resultado do quiz: $e');
      rethrow;
    }
  }

  // Buscar todos os resultados do quiz
  Future<List<Map<String, dynamic>>> getAllQuizResults() async {
    try {
      List<String> results = prefs.getStringList('quiz_results') ?? [];
      List<Map<String, dynamic>> resultList = [];

      for (String resultJson in results) {
        resultList.add(json.decode(resultJson));
      }

      // Ordenar por data (mais recente primeiro)
      resultList.sort((a, b) => b['created_at'].compareTo(a['created_at']));

      return resultList;
    } catch (e) {
      debugPrint('Erro ao buscar resultados do quiz: $e');
      return [];
    }
  }

  // Buscar resultados do quiz por usuário
  Future<List<Map<String, dynamic>>> getQuizResultsByUser(int userId) async {
    try {
      List<Map<String, dynamic>> allResults = await getAllQuizResults();
      return allResults.where((result) => result['user_id'] == userId).toList();
    } catch (e) {
      debugPrint('Erro ao buscar resultados do quiz do usuário: $e');
      return [];
    }
  }
}
