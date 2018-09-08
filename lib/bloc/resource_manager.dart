import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';
import 'model.dart';

abstract class ResourceManager {

  static void savePlayers(List<String> players) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('players', players);
  }

  static Future<List<String>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('players') ?? [];
  }

  static void saveSelectedDecks(List<Deck> decks) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'selected_decks',
      decks.map<String>((deck) => deck.id).toList()
    );
  }

  static Future<List<String>> loadSelectedDecks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selected_decks') ?? [];
  }

  /// Returns a list of all decks of a given language.
  static Future<List<Deck>> getDecks({
    @required String language
  }) async {
    assert(language != null);

    print('Loading yaml.');
    final decks = <Deck>[];
    final decksFile = loadYaml(await rootBundle.loadString('assets/decks.yaml'));

    print('Loading decks of version ${decksFile['version']}.');

    for (final deck in decksFile[language] ?? []) {
      decks.add(Deck(
        id: deck['id'],
        file: 'assets/deck_$language\_${deck['id'] ?? 'id'}.txt',
        name: deck['name'] ?? '<no name>',
        coverImage: deck['image'] ?? '',
        color: deck['color'] ?? '<color>',
        description: deck['description'] ?? '<description>',
        probability: deck['probability'] ?? 1.0
      ));
    }

    print('Decks: $decks');
    return decks;
  }

  /// Picks a random card from a random deck.
  /// Caution: may return null if it picks a card that required too many
  /// players or deck files are corrupt. Just call it again, then.
  static Future<ContentCard> pickCard({
    @required List<Deck> decks,
    @required List<String> players
  }) async {
    assert(decks != null);
    assert(players != null);

    final random = Random();
    
    final deckProbabilitySum = decks.map((deck) => deck.probability).reduce((a, b) => a + b);
    final chosenDeckProbability = random.nextDouble() * deckProbabilitySum;
    double cumulativeProbability = 0.0;
    final deck = decks.firstWhere((deck) {
      cumulativeProbability += deck.probability;
      return cumulativeProbability >= chosenDeckProbability;
    });

    int selectedCard = 0;
    int count = -1;
    //print('Picking a card from deck $deck. Loading file ${deck.file}');

    final line = await rootBundle.loadString(deck.file)
      .asStream()
      .transform(LineSplitter())
      .where((String line) => !line.startsWith('#'))
      .where((String line) {
        if (line.startsWith('/')) {
          selectedCard = random.nextInt(int.parse(line.substring(1)));
          return false;
        } else return true;
      })
      .singleWhere((String line) {
        count++;
        return count == selectedCard;
      });

    players.shuffle(random);
    final parts = line.split('|');

    if (parts.length != 4) {
      print('Card is corrupt: There are ${parts.length} parts: $line.');
      return null; // await pickCard(decks, players);
    }

    final content = _insertNames(parts[2], players);
    final annihilation = _insertNames(parts[3], players);

    if (content == null || annihilation == null) {
      print('Not enough players to fill slots in card $parts.');
      return null; // await pickCard(decks, players);
    }
 
    return ContentCard(
      id: deck.id + '-' + parts[0],
      author: parts[1],
      content: _insertNames(parts[2], players),
      followup: _insertNames(parts[3], players),
      color: deck.color
    );
  }

  /// Replaces player tokens in the string with actual player names.
  /// [$a] is replaced with [players[0]], [$b] with [players[1]] and so on.
  /// In order to not limit the game to the first players, shuffle players
  /// before calling.
  static String _insertNames(String string, List<String> players) {
    final chars = 'abcdefghiojklmnopqrstuvwxyz'.split('');
    
    for (int i = 0; i < chars.length; i++) {
      final placeholder = '\$${chars[i]}';

      if (string.contains(placeholder)) {
        if (i >= players.length)
          return null;
        string = string.replaceAll(placeholder, players[i]);
      }
    }
    return string;
  }
}
