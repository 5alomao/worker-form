import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class VisualizarResultadosQuiz extends StatefulWidget {
  final int userId;

  const VisualizarResultadosQuiz({super.key, required this.userId});

  @override
  State<VisualizarResultadosQuiz> createState() =>
      _VisualizarResultadosQuizState();
}

class _VisualizarResultadosQuizState extends State<VisualizarResultadosQuiz> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> _resultados = [];
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _storageService.getUserById(widget.userId);
      List<Map<String, dynamic>> resultados;

      if (userData?['user_type'] == 'admin') {
        // Admin vê todos os resultados
        resultados = await _storageService.getAllQuizResults();
      } else {
        // Usuário comum vê apenas seus próprios resultados
        resultados = await _storageService.getQuizResultsByUser(widget.userId);
      }

      setState(() {
        _userData = userData;
        _resultados = resultados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Erro ao carregar resultados: $e', isError: true);
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.thumb_up;
    return Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userData?['user_type'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAdmin ? "Resultados do Quiz - Todos" : "Meus Resultados do Quiz",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resultados.isEmpty
          ? _buildEmptyState()
          : _buildResultsList(),
    );
  }

  Widget _buildEmptyState() {
    final isAdmin = _userData?['user_type'] == 'admin';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              isAdmin
                  ? 'Nenhum resultado de quiz encontrado'
                  : 'Você ainda não fez o quiz',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isAdmin
                  ? 'Os usuários ainda não fizeram o quiz de tecnologia.'
                  : 'Que tal testar seus conhecimentos em tecnologia?',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            if (!isAdmin) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fazer Quiz Agora',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final isAdmin = _userData?['user_type'] == 'admin';

    return Column(
      children: [
        // Cabeçalho com estatísticas
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Text(
                isAdmin ? 'Estatísticas Gerais' : 'Suas Estatísticas',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total de Tentativas',
                    _resultados.length.toString(),
                    Icons.quiz,
                  ),
                  if (_resultados.isNotEmpty)
                    _buildStatItem(
                      'Melhor Pontuação',
                      '${_resultados.map((r) => r['percentage'] as int).reduce((a, b) => a > b ? a : b)}%',
                      Icons.star,
                    ),
                ],
              ),
            ],
          ),
        ),

        // Lista de resultados
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _resultados.length,
            itemBuilder: (context, index) {
              final resultado = _resultados[index];
              return _buildResultCard(resultado, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, dynamic> resultado, int position) {
    final percentage = resultado['percentage'] as int;
    final score = resultado['score'] as int;
    final total = resultado['total_questions'] as int;
    final scoreColor = _getScoreColor(percentage);
    final scoreIcon = _getScoreIcon(percentage);
    final isAdmin = _userData?['user_type'] == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone de posição/performance
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: scoreColor),
              ),
              child: Icon(scoreIcon, color: scoreColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Informações do resultado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin) ...[
                    Text(
                      resultado['user_email'] ?? 'Usuário desconhecido',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Quiz #$position',
                    style: TextStyle(
                      fontSize: isAdmin ? 14 : 16,
                      fontWeight: isAdmin ? FontWeight.normal : FontWeight.bold,
                      color: isAdmin ? Colors.black54 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(resultado['created_at']),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Pontuação
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score/$total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
