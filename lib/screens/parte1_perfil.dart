import 'package:flutter/material.dart';
import 'parte2_planos.dart';

class Parte1Perfil extends StatefulWidget {
  final int userId;

  const Parte1Perfil({super.key, required this.userId});

  @override
  State<Parte1Perfil> createState() => _Parte1PerfilState();
}

class _Parte1PerfilState extends State<Parte1Perfil> {
  final _formKey = GlobalKey<FormState>();
  String? nome;
  String? idade;
  String escolaridade = 'Ensino Médio';
  String situacao = 'Estudando';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Remove o botão voltar
        title: const Text(
          "Formulário - Etapa 1/3",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Text(
                "Parte 1 - Perfil",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              const Text(
                "Preencha seus dados pessoais abaixo para iniciarmos a pesquisa.",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              // Campo Nome
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite seu nome' : null,
                onSaved: (value) => nome = value,
              ),
              const SizedBox(height: 25),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite sua idade' : null,
                onSaved: (value) => idade = value,
              ),
              const SizedBox(height: 25),

              // Dropdown Escolaridade
              DropdownButtonFormField<String>(
                initialValue: escolaridade,
                decoration: InputDecoration(
                  labelText: 'Nível de escolaridade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Ensino Médio',
                    child: Text('Ensino Médio'),
                  ),
                  DropdownMenuItem(
                    value: 'Educação Superior',
                    child: Text('Educação Superior'),
                  ),
                  DropdownMenuItem(
                    value: 'Pós-Graduação',
                    child: Text('Pós-Graduação'),
                  ),
                ],
                onChanged: (value) => setState(() => escolaridade = value!),
              ),
              const SizedBox(height: 25),

              // Dropdown Situação Atual
              DropdownButtonFormField<String>(
                initialValue: situacao,
                decoration: InputDecoration(
                  labelText: 'Situação Atual',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Estudando',
                    child: Text('Estudando'),
                  ),
                  DropdownMenuItem(
                    value: 'Fazendo estágio',
                    child: Text('Fazendo estágio'),
                  ),
                  DropdownMenuItem(
                    value: 'Trabalhando',
                    child: Text('Trabalhando'),
                  ),
                ],
                onChanged: (value) => setState(() => situacao = value!),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Parte2Planos(
                            userId: widget.userId,
                            nome: nome!,
                            idade: idade!,
                            escolaridade: escolaridade,
                            situacao: situacao,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("PRÓXIMO"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
