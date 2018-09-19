import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'resource_manager.dart';

class PlayersBloc {
  bool isPlayerInputErroneous(String player) => players?.contains(player) ?? false;
  bool isPlayerInputValid(String player) =>
      player != '' && !isPlayerInputErroneous(player);
  List<String> players;

  final playersSubject = BehaviorSubject<List<String>>(seedValue: []);


  Future<void> initialize() async {
    players = await _loadPlayers();
    print('Loaded players are $players.');
    playersSubject.add(players);
  }

  void dispose() {
    playersSubject.close();
  }

  void addPlayer(String player) {
    assert(player != null);
    assert(isPlayerInputValid(player));

    players.add(player);
    playersSubject.add(players);
    _savePlayers(players);
  }

  void removePlayer(String player) {
    assert(player != null);
    assert(players.contains(player));

    players.remove(player);
    playersSubject.add(players);
    _savePlayers(players);
  }


  static void _savePlayers(List<String> players) {
    ResourceManager.saveStringList('players', players).catchError((e) {
      print('An error occured while saving $players as players: $e');
    });
  }

  static Future<List<String>> _loadPlayers() async {
    return (await ResourceManager.loadStringList('players')) ?? [];
  }
}
