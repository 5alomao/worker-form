import 'package:flutter/material.dart';
import 'finalizacao.dart';

class Parte3Expectativas extends StatefulWidget {
  final int userId;
  final String nome;
  final String idade;
  final String escolaridade;
  final String situacao;
  final String planoCarreira;
  final String areaInteresse;
  final String experiencia;
  final String descricaoExperiencia;

  const Parte3Expectativas({
    super.key,
    required this.userId,
    required this.nome,
    required this.idade,
    required this.escolaridade,
    required this.situacao,
    required this.planoCarreira,
    required this.areaInteresse,
    required this.experiencia,
    required this.descricaoExperiencia,
  });

  @override
  State<Parte3Expectativas> createState() => _Parte3ExpectativasState();
}

class _Parte3ExpectativasState extends State<Parte3Expectativas> {
  final _formKey = GlobalKey<FormState>();
  String preocupacao = '';
  String palavra = '';
  String expectativas = '';

  Future<void> _finalizarFormulario() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Preparar dados do formulário para passar para TelaFinal
      Map<String, dynamic> formData = {
        'nome': widget.nome,
        'idade': widget.idade,
        'escolaridade': widget.escolaridade,
        'situacao': widget.situacao,
        'plano_carreira': widget.planoCarreira,
        'area_interesse': widget.areaInteresse,
        'experiencia': widget.experiencia,
        'descricao_experiencia': widget.descricaoExperiencia,
        'preocupacao': preocupacao,
        'palavra_futuro': palavra,
        'expectativas': expectativas,
      };

      // Navegar para tela final
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TelaFinal(userId: widget.userId, formData: formData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Remove o botão voltar
        title: const Text(
          "Formulário - Etapa 3/3",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Text(
                "Parte 3 - Preparação e Expectativas",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              const Text(
                "Preencha os dados abaixo para finalizarmos a pesquisa.",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 40),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'O que mais preocupa no mercado de trabalho',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (v) => preocupacao = v!,
              ),
              const SizedBox(height: 40),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Uma palavra que define seu futuro profissional',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (v) => palavra = v!,
              ),
              const SizedBox(height: 40),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Expectativas para os próximos anos',
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (v) => expectativas = v!,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _finalizarFormulario,
                  child: const Text("FINALIZAR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
