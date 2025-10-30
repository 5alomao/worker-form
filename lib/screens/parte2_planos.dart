import 'package:flutter/material.dart';
import 'parte3_expectativas.dart';

class Parte2Planos extends StatefulWidget {
  const Parte2Planos({super.key});
  @override
  State<Parte2Planos> createState() => _Parte2PlanosState();
}

class _Parte2PlanosState extends State<Parte2Planos> {
  final _formKey = GlobalKey<FormState>();
  String plano = 'Sim';
  String experiencia = 'Não';
  String area = 'Tecnologia da Informação';
  String descricao = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          "Formulário - Etapa 2/3",
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
                "Parte 2 - Planos de Carreira",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              const Text(
                "Preencha os dados abaixo para continuarmos a pesquisa.",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              const Text("Você já possui um plano de carreira definido?"),
              Row(
                children: [
                  Radio(
                    value: 'Sim',
                    groupValue: plano,
                    onChanged: (v) => setState(() => plano = v!),
                  ),
                  const Text("Sim"),
                  Radio(
                    value: 'Não',
                    groupValue: plano,
                    onChanged: (v) => setState(() => plano = v!),
                  ),
                  const Text("Não"),
                  Radio(
                    value: 'Parcialmente',
                    groupValue: plano,
                    onChanged: (v) => setState(() => plano = v!),
                  ),
                  const Text("Parcialmente"),
                ],
              ),
              SizedBox(height: 40),
              DropdownButtonFormField<String>(
                initialValue: area,
                decoration: const InputDecoration(
                  labelText: 'Área de interesse profissional',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Tecnologia da Informação',
                    child: Text('Tecnologia da Informação'),
                  ),
                  DropdownMenuItem(value: 'Educação', child: Text('Educação')),
                  DropdownMenuItem(value: 'Saúde', child: Text('Saúde')),
                ],
                onChanged: (v) => setState(() => area = v!),
              ),
              SizedBox(height: 40),
              const Text("Já teve experiência profissional?"),
              Row(
                children: [
                  Radio(
                    value: 'Sim',
                    groupValue: experiencia,
                    onChanged: (v) => setState(() => experiencia = v!),
                  ),
                  const Text("Sim"),
                  Radio(
                    value: 'Não',
                    groupValue: experiencia,
                    onChanged: (v) => setState(() => experiencia = v!),
                  ),
                  const Text("Não"),
                  Radio(
                    value: 'Parcialmente',
                    groupValue: experiencia,
                    onChanged: (v) => setState(() => experiencia = v!),
                  ),
                  const Text("Parcialmente"),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descreva brevemente sua experiência',
                ),
                maxLines: 3,
                onSaved: (v) => descricao = v ?? '',
              ),
              SizedBox(height: 40),
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
                          builder: (_) => const Parte3Expectativas(),
                        ),
                      );
                    }
                  },
                  child: const Text("PRÓXIMO"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
