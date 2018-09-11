import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';
import 'model.dart';

class ResourceMissingError implements Error {
  const ResourceMissingError(this.path) : assert(path != null);
  
  final String path;

  String toString() => "Resource missing: $path";

  StackTrace get stackTrace => null;
}


/// Handles all the low level stuff, like dealing with files or package
/// libraries.
abstract class ResourceManager {

  /// Saves the players' names to the shared preferences in order to preserve
  /// them beyond the lifetime of the app.
  /// 
  /// See [loadPlayers].
  static void savePlayers(List<String> players) async {
    assert(players != null);

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('players', players);
  }


  /// Loads the players' names from the shared preferences.
  /// 
  /// See [savePlayers]-
  static Future<List<String>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('players') ?? [];
  }


  /// Saves the selected decks to the shared preferences in order to preserve
  /// it beyond the lifetime of the app.
  /// 
  /// See [loadSelectedDecks].
  static void saveSelectedDecks(List<Deck> decks) async {
    assert(decks != null);

    final prefs = await SharedPreferences.getInstance();
    
    prefs.setStringList(
      'selected_decks',
      decks.map<String>((deck) => deck.id).toList()
    );
  }


  /// Loads the selected decks from the shared preferences.
  /// 
  /// See [saveSelectedDecks].
  static Future<List<String>> loadSelectedDecks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selected_decks') ?? [];
  }


  /// Saves the user's cards.
  static void saveMyCards(List<ContentCard> myCards) async {
    assert(myCards != null);

    // Save the cards in the same format as cards in deck files.
    final List<String> stringifiedCards = myCards.map((card) =>
        '${card.id}|${card.author}|${card.content}|${card.followup}'
    ).toList();

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('my_cards', stringifiedCards);
  }


  /// Loads the user's cards.
  static Future<List<ContentCard>> loadMyCards() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getStringList('my_cards') ?? [])
        .map((stringifiedCard) {
          final parts = stringifiedCard.split('|');
          return parts.length == 4 ? ContentCard(
            id: parts[0],
            color: '#FFFFFF',
            content: parts[2],
            followup: parts[3],
            author: parts[0],
          ) : null;
        })
        .where((card) => card != null)
        .toList();
  }


  /// Returns a list of all decks of a given language.
  static Future<List<Deck>> getDecks(Locale locale) async {
    assert(locale != null);

    // All the decks will be saved here.
    final decks = <Deck>[];

    // Try to read the yaml file corresponding to the locale.
    final root = 'assets/${locale.languageCode}';
    final filename = '$root/decks.yaml';
    var yaml = loadYaml(await rootBundle.loadString(filename));

    print('Loading decks of version ${yaml['version']}.');

    // Save the decks.
    for (final deck in yaml['decks'] ?? []) {
      decks.add(Deck(
        id: deck['id'],
        file: '$root/deck_${deck['id'] ?? 'id'}.txt',
        name: deck['name'] ?? '<no name>',
        coverImage: deck['image'] ?? '',
        color: deck['color'] ?? '<color>',
        description: deck['description'] ?? '<description>',
        probability: deck['probability'] ?? 1.0
      ));
    }

    return decks;
  }


  /// Picks a random deck from the given decks.
  /// Caution: May return null if the chosen deck's file is corrupt or if there
  /// are too few players for the chosen card. Just call it again, then. :D
  static Deck _pickDeck(List<Deck> decks) {
    // Calculate the sum of all the deck's probabilites.
    // Then choose a random cumulative sum in that range.
    final probabilitySum = decks
        .map((deck) => deck.probability)
        .reduce((a, b) => a + b);
    final chosenCumSum = Random().nextDouble() * probabilitySum;

    // Calculate the cumulative sum and as we go, return the first deck where
    // the cumulative sum gets above the chosen cumulative sum.
    double cumSum = 0.0;
    return decks.firstWhere((deck) {
      cumSum += deck.probability;
      return cumSum >= chosenCumSum;
    });
  }


  /// Picks a random card from a random deck.
  static Future<ContentCard> pickCard({
    @required List<Deck> decks,
    @required List<String> players
  }) async {
    assert(decks != null);
    assert(players != null);

    final deck = _pickDeck(decks);
    int selectedCard = 0;
    int count = -1;

    // Reads the deck's file line by line.
    final line = await rootBundle.loadString(deck.file)
      .asStream()
      .transform(LineSplitter())
      .where((String line) => !line.startsWith('#'))
      .where((String line) {
        if (line.startsWith('/')) {
          // This is the line telling us the number of cards in this file.
          final numberOfCards = int.parse(line.substring(1));
          selectedCard = Random().nextInt(numberOfCards);
          return false;
        } else return true;
      })
      .singleWhere((String line) {
        // Increase count until we are at the chosen card.
        count++;
        return count == selectedCard;
      });

    // Make sure the chosen line is valid.
    final parts = line.split('|');
    if (parts.length != 4) {
      print('Warning: Card is corrupt: There are ${parts.length} parts: $line.');
      return null;
    }

    // Insert the players. Return null if there are too few players to fill all
    // the slots in the card.
    players.shuffle(Random());
    final content = _insertNames(parts[2], players);
    final annihilation = _insertNames(parts[3], players);

    if (content == null || annihilation == null) {
      return null;
    }
 
    // Finally, return the card.
    return ContentCard(
      id: deck.id + '-' + parts[0],
      author: parts[1],
      content: _insertNames(parts[2], players),
      followup: _insertNames(parts[3], players),
      color: deck.color
    );
  }


  /// Replaces player tokens in the string with actual player names.
  /// $a is replaced with [players[0]], $b with [players[1]] and so on.
  /// In order to guarantee a fair game, shuffle the players before calling.
  static String _insertNames(String string, List<String> players) {
    const chars = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k' ];
    
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
