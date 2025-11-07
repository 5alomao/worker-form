import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class VisualizarResultados extends StatefulWidget {
  final int? userId;

  const VisualizarResultados({super.key, this.userId});

  @override
  State<VisualizarResultados> createState() => _VisualizarResultadosState();
}

class _VisualizarResultadosState extends State<VisualizarResultados> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> _respostas = [];
  bool _isLoading = true;
  bool _showOnlyMyResponses = false;

  @override
  void initState() {
    super.initState();
    _carregarRespostas();
  }

  Future<void> _carregarRespostas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> respostas;

      if (_showOnlyMyResponses && widget.userId != null) {
        respostas = await _storageService.getFormResponsesByUser(
          widget.userId!,
        );
      } else {
        respostas = await _storageService.getAllFormResponses();
      }

      setState(() {
        _respostas = respostas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar respostas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Resultados da Pesquisa",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarRespostas,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Filtros
          if (widget.userId != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    "Filtros:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _showOnlyMyResponses,
                          onChanged: (value) {
                            setState(() {
                              _showOnlyMyResponses = value ?? false;
                            });
                            _carregarRespostas();
                          },
                        ),
                        const Text("Apenas minhas respostas"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Conteúdo principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: Colors.blue, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _showOnlyMyResponses
                            ? "Minhas Respostas"
                            : "Todas as Respostas",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading
                        ? "Carregando..."
                        : "${_respostas.length} resposta(s) encontrada(s)",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Lista de respostas
                  if (_isLoading)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Carregando respostas..."),
                          ],
                        ),
                      ),
                    )
                  else if (_respostas.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showOnlyMyResponses
                                  ? "Você ainda não respondeu nenhum formulário"
                                  : "Nenhuma resposta encontrada",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "As respostas dos formulários aparecerão aqui",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _respostas.length,
                        itemBuilder: (context, index) {
                          final resposta = _respostas[index];
                          return _buildRespostaCard(resposta);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRespostaCard(Map<String, dynamic> resposta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da resposta
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Resposta #${resposta['id']}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(resposta['created_at']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Informações do perfil
            _buildSection("👤 Perfil", [
              _buildInfoRow("Nome:", resposta['nome']),
              _buildInfoRow("Idade:", resposta['idade']),
              _buildInfoRow("Escolaridade:", resposta['escolaridade']),
              _buildInfoRow("Situação:", resposta['situacao']),
            ]),

            const SizedBox(height: 16),

            // Planos de carreira
            _buildSection("🎯 Planos de Carreira", [
              _buildInfoRow("Plano de Carreira:", resposta['plano_carreira']),
              _buildInfoRow("Área de Interesse:", resposta['area_interesse']),
              _buildInfoRow("Experiência:", resposta['experiencia']),
              if (resposta['descricao_experiencia']?.isNotEmpty ?? false)
                _buildInfoRow(
                  "Descrição da Experiência:",
                  resposta['descricao_experiencia'],
                ),
            ]),

            const SizedBox(height: 16),

            // Expectativas
            _buildSection("💭 Expectativas", [
              _buildInfoRow("Principal Preocupação:", resposta['preocupacao']),
              _buildInfoRow("Palavra do Futuro:", resposta['palavra_futuro']),
              _buildInfoRow("Expectativas:", resposta['expectativas']),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Data não disponível';

    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Data inválida';
    }
  }
}
