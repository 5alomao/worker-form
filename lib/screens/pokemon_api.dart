import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonAPI extends StatefulWidget {
  final int userId;

  const PokemonAPI({super.key, required this.userId});

  @override
  State<PokemonAPI> createState() => _PokemonAPIState();
}

class _PokemonAPIState extends State<PokemonAPI> {
  List pokemons = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    final url = Uri.parse('https://www.canalti.com.br/api/pokemons.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          pokemons = data['pokemon'];
          loading = false;
        });
      } else {
        throw Exception("Erro ao buscar dados (${response.statusCode})");
      }
    } catch (e) {
      setState(() => loading = false);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao carregar dados: $e")));
      }
    }
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
        title: const Text(
          "Recompensa - API Pokémon",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // duas colunas
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: pokemons.length,
              itemBuilder: (context, index) {
                final pokemon = pokemons[index];
                return _buildPokemonCard(pokemon);
              },
            ),
    );
  }

  Widget _buildPokemonCard(dynamic pokemon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            pokemon['img'],
            height: 90,
            width: 90,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported, size: 60),
          ),
          const SizedBox(height: 10),
          Text(
            pokemon['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            "Tipo: ${(pokemon['type'] as List).join(', ')}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            "Altura: ${pokemon['height']}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            "Peso: ${pokemon['weight']}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
