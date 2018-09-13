import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'resource_manager.dart';

class PlayersBloc {
  List<String> players;

  final playersSubject = BehaviorSubject<List<String>>(seedValue: []);


  void initialize() async {
    players = await _loadPlayers();
    playersSubject.add(players);
  }

  void dispose() {
    playersSubject.close();
  }


  void addPlayer(String player) {
    assert(player != null);
    assert(player != '');

    players.add(player);
    playersSubject.add(players);
    _savePlayers(players);
  }

  void removePlayer(String player) {
    assert(player != null);

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
