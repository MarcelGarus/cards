import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';
import 'model.dart';
import 'resource_manager.dart';

class DecksBloc {
  List<Deck> decks = <Deck>[];
  List<Deck> get unlockedDecks => decks.where((d) => d.isUnlocked).toList();
  List<Deck> get selectedDecks => decks.where((d) => d.isSelected).toList();

  final decksSubject = BehaviorSubject<List<Deck>>();
  final unlockedDecksSubject = BehaviorSubject<List<Deck>>();
  final selectedDecksSubject = BehaviorSubject<List<Deck>>();


  void initialize(Locale locale) async {
    final List<Deck> loadedDecks = await _loadDecks(locale);

    // TODO: get unlocked decks.

    // Load selected decks.
    final Set<String> selected = await _loadSelectedDecks();
    for (final deck in loadedDecks) {
      deck.isSelected = selected.contains(deck.id);
    }

    decks = loadedDecks;
    decksSubject.add(decks);
    unlockedDecksSubject.add(unlockedDecks);
    selectedDecksSubject.add(selectedDecks);
  }

  void dispose() {
    decksSubject.close();
    unlockedDecksSubject.close();
    selectedDecksSubject.close();
  }


  void selectDeck(Deck deck) {
    decks.singleWhere((d) => d.id == deck.id).isSelected = true;
    selectedDecksSubject.add(selectedDecks);
    _saveSelectedDecks(selectedDecks);
  }

  void deselectDeck(Deck deck) {
    decks.singleWhere((d) => d.id == deck.id).isSelected = false;
    selectedDecksSubject.add(selectedDecks);
    _saveSelectedDecks(selectedDecks);
  }


  /// Returns a list of all decks of a given language.
  static Future<List<Deck>> _loadDecks(Locale locale) async {
    final decks = <Deck>[];

    final root = 'assets/${locale.languageCode}';
    final filename = '$root/decks.yaml';
    final yaml = loadYaml(await rootBundle.loadString(filename));

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

  static void _saveSelectedDecks(List<Deck> decks) {
    ResourceManager.saveStringList(
      'selected_decks',
      decks.map((d) => d.id).toList()
    ).catchError((e) {
      print('An error occurred while saving $decks as selected decks: $e');
    });
  }

  static Future<Set<String>> _loadSelectedDecks() async {
    return (await ResourceManager.loadStringList('selected_decks')).toSet() ?? Set();
  }
}
