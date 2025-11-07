import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'tela_inicial.dart';
import 'parte1_perfil.dart';

class TelaFinal extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> formData;

  const TelaFinal({super.key, required this.userId, required this.formData});

  @override
  State<TelaFinal> createState() => _TelaFinalState();
}

class _TelaFinalState extends State<TelaFinal> {
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  bool _saveSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _salvarFormulario();
  }

  Future<void> _salvarFormulario() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Adicionar user_id aos dados do formulário
      Map<String, dynamic> dadosCompletos = Map.from(widget.formData);
      dadosCompletos['user_id'] = widget.userId;

      // Salvar no storage
      await _storageService.insertFormResponse(dadosCompletos);

      setState(() {
        _isLoading = false;
        _saveSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _saveSuccess = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _voltarParaInicio() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => TelaInicial(userId: widget.userId)),
      (route) => false,
    );
  }

  void _responderNovamente() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Parte1Perfil(userId: widget.userId)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Formulário Finalizado",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // Remove botão voltar
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Salvando suas respostas...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ] else if (_saveSuccess) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Formulário Finalizado!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Obrigado pela sua participação!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              const Text(
                "Suas respostas foram salvas com sucesso.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.error, color: Colors.red, size: 64),
              ),
              const SizedBox(height: 30),
              Text(
                "Erro ao Salvar",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Ocorreu um erro ao salvar suas respostas:",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? "Erro desconhecido",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: _salvarFormulario,
                child: const Text("Tentar Novamente"),
              ),
            ],

            const SizedBox(height: 60),

            // Botões de navegação
            if (!_isLoading) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      onPressed: _voltarParaInicio,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, size: 20),
                          SizedBox(width: 8),
                          Text("Voltar ao Início"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _responderNovamente,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, size: 20),
                          SizedBox(width: 8),
                          Text("Responder Novamente"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
