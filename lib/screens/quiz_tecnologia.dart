import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

class QuizTecnologia extends StatefulWidget {
  final int userId;

  const QuizTecnologia({super.key, required this.userId});

  @override
  State<QuizTecnologia> createState() => _QuizTecnologiaState();
}

class _QuizTecnologiaState extends State<QuizTecnologia> {
  final StorageService _storageService = StorageService();

  int _currentQuestion = 0;
  int _score = 0;
  bool _isFinished = false;
  bool _isSaving = false;
  bool _loadingReward = false;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _rewardPokemon;

  // Lista de perguntas do quiz
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'O que significa a sigla HTML?',
      'options': [
        'HyperText Markup Language',
        'High Tech Modern Language',
        'Home Tool Markup Language',
        'HyperText Modern Language',
      ],
      'correct': 0,
    },
    {
      'question': 'Qual é a função principal do CSS?',
      'options': [
        'Criar bancos de dados',
        'Estilizar páginas web',
        'Programar funcionalidades',
        'Gerenciar servidores',
      ],
      'correct': 1,
    },
    {
      'question': 'O que é JavaScript?',
      'options': [
        'Uma linguagem de programação',
        'Um tipo de café',
        'Um sistema operacional',
        'Um banco de dados',
      ],
      'correct': 0,
    },
    {
      'question': 'O que significa a sigla CPU?',
      'options': [
        'Computer Processing Unit',
        'Central Processing Unit',
        'Central Program Unit',
        'Computer Program Unit',
      ],
      'correct': 1,
    },
    {
      'question': 'Qual é a principal função de um banco de dados?',
      'options': [
        'Criar interfaces visuais',
        'Executar programas',
        'Armazenar e organizar dados',
        'Conectar à internet',
      ],
      'correct': 2,
    },
    {
      'question': 'O que é um algoritmo?',
      'options': [
        'Um tipo de hardware',
        'Um programa de computador',
        'Uma linguagem de programação',
        'Uma sequência de instruções para resolver um problema',
      ],
      'correct': 3,
    },
    {
      'question': 'Qual é a função do sistema operacional?',
      'options': [
        'Gerenciar recursos do computador',
        'Criar páginas web',
        'Editar imagens',
        'Enviar emails',
      ],
      'correct': 0,
    },
    {
      'question': 'O que significa "debugging" em programação?',
      'options': [
        'Criar novos programas',
        'Instalar software',
        'Encontrar e corrigir erros no código',
        'Fazer backup de dados',
      ],
      'correct': 2,
    },
    {
      'question': 'O que é a "nuvem" (cloud) em tecnologia?',
      'options': [
        'Uma condição climática',
        'Um tipo de software',
        'Uma peça de hardware',
        'Serviços de computação via internet',
      ],
      'correct': 3,
    },
    {
      'question': 'O que significa a sigla URL?',
      'options': [
        'Universal Resource Locator',
        'Uniform Resource Locator',
        'Universal Reference Link',
        'Uniform Reference Locator',
      ],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _storageService.getUserById(widget.userId);
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    }
  }

  void _answerQuestion(int selectedOption) {
    if (_questions[_currentQuestion]['correct'] == selectedOption) {
      _score++;
    }

    setState(() {
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _isFinished = true;
        _saveQuizResult();
      }
    });
  }

  Future<void> _saveQuizResult() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final quizData = {
        'user_id': widget.userId,
        'user_email': _userData?['email'] ?? 'Usuário',
        'score': _score,
        'total_questions': _questions.length,
        'percentage': ((_score / _questions.length) * 100).round(),
      };

      await _storageService.insertQuizResult(quizData);

      // Buscar Pokémon aleatório como recompensa
      await _getRandomPokemonReward();

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showMessage('Erro ao salvar resultado: $e', isError: true);
    }
  }

  Future<void> _getRandomPokemonReward() async {
    setState(() {
      _loadingReward = true;
    });

    try {
      final url = Uri.parse('https://www.canalti.com.br/api/pokemons.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pokemons = data['pokemon'] as List;

        if (pokemons.isNotEmpty) {
          final random = Random();
          final randomIndex = random.nextInt(pokemons.length);

          setState(() {
            _rewardPokemon = pokemons[randomIndex];
            _loadingReward = false;
          });
        } else {
          setState(() {
            _loadingReward = false;
          });
        }
      } else {
        setState(() {
          _loadingReward = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingReward = false;
      });
      debugPrint('Erro ao buscar Pokémon: $e');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isFinished ? "Resultado do Quiz" : "Quiz de Tecnologia",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: _isFinished ? _buildResultScreen() : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    final question = _questions[_currentQuestion];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contador de perguntas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              'Pergunta ${_currentQuestion + 1}/10',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),

          // Pergunta
          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // Opções de resposta
          Expanded(
            child: ListView.builder(
              itemCount: question['options'].length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _answerQuestion(index),
                      child: Text(
                        question['options'][index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = ((_score / _questions.length) * 100).round();
    String message;
    Color messageColor;
    IconData icon;

    if (percentage >= 80) {
      message = "Excelente! Você tem um ótimo conhecimento em tecnologia!";
      messageColor = Colors.green;
      icon = Icons.emoji_events;
    } else if (percentage >= 60) {
      message = "Muito bom! Você tem um bom conhecimento básico!";
      messageColor = Colors.orange;
      icon = Icons.thumb_up;
    } else {
      message =
          "Continue estudando! A tecnologia é um campo em constante evolução!";
      messageColor = Colors.red;
      icon = Icons.school;
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: messageColor),
          const SizedBox(height: 30),

          Text(
            'Quiz Finalizado!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: messageColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: messageColor),
            ),
            child: Column(
              children: [
                Text(
                  'Sua Pontuação',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_score/${_questions.length}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: messageColor,
                  ),
                ),
                Text(
                  '$percentage% de acertos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: messageColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: messageColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Seção de Recompensa
          if (_loadingReward) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber),
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 10),
                  Text(
                    'Preparando sua recompensa...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else if (_rewardPokemon != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'RECOMPENSA!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.star, color: Colors.amber, size: 24),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Imagem do Pokémon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _rewardPokemon!['img'],
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 60),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nome do Pokémon
                  Text(
                    _rewardPokemon!['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Tipo do Pokémon
                  Text(
                    "Tipo: ${(_rewardPokemon!['type'] as List).join(', ')}",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 3),

                  // Altura e Peso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Altura: ${_rewardPokemon!['height']}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Peso: ${_rewardPokemon!['weight']}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Você ganhou este Pokémon por completar o quiz!',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Botão Voltar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: (_isSaving || _loadingReward)
                  ? null
                  : () => Navigator.pop(context),
              child: (_isSaving || _loadingReward)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, size: 24),
                        SizedBox(width: 12),
                        Text("Voltar ao Menu Principal"),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
