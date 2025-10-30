import 'package:flutter/material.dart';
import 'parte1_perfil.dart'; // Certifique-se que este arquivo existe no seu projeto

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     if (Navigator.of(context).canPop()) {
        //       Navigator.of(context).pop();
        //     }
        //   },
        // ),
        title: const Text("Formulário", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
                bottom: 32.0,
              ), // Espaçamento para destacar o título no "topo"
              child: Text(
                "Pesquisa sobre Expectativas Profissionais",
                textAlign: TextAlign.center, // Alinhamento centralizado
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, // Estilo H1
                  color: Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 200),
                  const Text(
                    "Responda algumas perguntas sobre seus planos de carreira e oportunidades de emprego.\nLeva menos de 5 minutos!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Parte1Perfil()),
                      );
                    },
                    child: const Text("Começar"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
