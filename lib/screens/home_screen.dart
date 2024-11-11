import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Character>> futureCharacters;

  @override
  void initState() {
    super.initState();
    futureCharacters = fetchCharacters();
  }

  Future<List<Character>> fetchCharacters() async {
    final response =
        await http.get(Uri.parse('https://api.disneyapi.dev/character'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> charactersJson = jsonResponse['data'];
      return charactersJson.map((json) => Character.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<Character>>(
        // setup the URL for your API here
        future: futureCharacters,
        builder: (context, snapshot) {
          // Consider 3 cases here
          if (snapshot.connectionState == ConnectionState.waiting) {
            // when the process is ongoing
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // error
            return Center(
                child: Text(
                    'Error: ${snapshot.error?.toString() ?? 'Unknown error'}'));
          } else if (snapshot.hasData) {
            // when the process is completed:
            // successful
            final characters = snapshot.data!;
            return ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return ExpandedTile(
                  controller: ExpandedTileController(),
                  title: Text(character.name),
                  leading: character.imageUrl.isEmpty
                      ? const Icon(Icons.image_not_supported)
                      : Image.network(character.imageUrl),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: character.films.isNotEmpty
                        ? character.films.map((film) => Text(film)).toList()
                        : [const Text('No films available')],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class Character {
  final String name;
  final String imageUrl;
  final List<String> films;

  Character({
    required this.name,
    required this.imageUrl,
    required this.films,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      films: List<String>.from(json['films'] ?? []),
    );
  }
}
