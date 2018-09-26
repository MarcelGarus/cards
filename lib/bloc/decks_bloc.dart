import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';
import 'model.dart';
import 'resource_manager.dart';

class DecksBloc {
  bool showMyDeck = false;
  List<Deck> decks = <Deck>[];
  List<Deck> get usefulDecks => showMyDeck ? decks : decks.where((d) => d.id != 'my').toList();
  List<Deck> get unlockedDecks => decks.where((d) => d.isUnlocked).toList();
  List<Deck> get selectedDecks => decks.where((d) => d.isSelected).toList();

  final decksSubject = BehaviorSubject<List<Deck>>();


  Future<void> initialize(Locale locale) async {
    final List<Deck> loadedDecks = await _loadDecks(locale);

    // Load unlocked decks.
    final Set<String> unlocked = await _loadUnlockedDecks();
    for (final deck in loadedDecks) {
      deck.isUnlocked = deck.price == 0 || unlocked.contains(deck.id);
    }

    // Load selected decks.
    final Set<String> selected = await _loadSelectedDecks();
    for (final deck in loadedDecks) {
      deck.isSelected = selected.contains(deck.id);
    }

    decks = loadedDecks;
    print('Loaded decks: Unlocked: $unlocked, selected: $selected');
    _update();
  }

  void dispose() {
    decksSubject.close();
  }


  void updateShowMyDeck(bool showMyDeck) {
    this.showMyDeck = showMyDeck;
    _update();
  }

  void buy(Deck deck) {
    deck.isUnlocked = true;
    deck.isSelected = true;
    _update();
    _saveUnlockedDecks(unlockedDecks);
    _saveSelectedDecks(selectedDecks);
  }

  void selectDeck(Deck deck) {
    deck.isSelected = true;
    _update();
    _saveSelectedDecks(selectedDecks);
  }

  void deselectDeck(Deck deck) {
    deck.isSelected = false;
    _update();
    _saveSelectedDecks(selectedDecks);
  }

  void _update() {
    final displayedDecks = List.from<Deck>(usefulDecks);
    displayedDecks.sort((a, b) => a.price.compareTo(b.price));
    decksSubject.add(displayedDecks);
  }


  /// Returns a list of all decks of a given language.
  static Future<List<Deck>> _loadDecks(Locale locale) async {
    if (locale == null)
      return [];

    final decks = <Deck>[];

    final root = ResourceManager.getRootDirectory(locale);
    final filename = '$root/decks.yaml';
    final yaml = loadYaml(await rootBundle.loadString(filename));

    for (final deck in yaml['decks'] ?? []) {
      decks.add(Deck(
        id: deck['id'] ?? '<no id>',
        file: deck['id'] != null ? '$root/deck_${deck['id'] ?? 'id'}.txt' : '<no file>',
        name: deck['name'] ?? '<no name>',
        coverImage: deck['image'] ?? '',
        color: deck['color'] ?? '#ffffff',
        description: deck['description'] ?? '<no description>',
        price: deck['price'] ?? 0,
        probability: deck['probability'] ?? 1.0
      ));
    }

    return decks;
  }

  static void _saveUnlockedDecks(List<Deck> decks) {
    ResourceManager.saveStringList(
      'unlocked_decks',
      decks.map((d) => d.id).toList()
    ).catchError((e) {
      print('An error occurred while saving $decks as unlocked decks: $e');
    });
  }

  static Future<Set<String>> _loadUnlockedDecks() async {
    return (await ResourceManager.loadStringList('unlocked_decks'))?.toSet()
        ?? Set();
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
    return (await ResourceManager.loadStringList('selected_decks'))?.toSet()
        ?? Set();
  }
}
