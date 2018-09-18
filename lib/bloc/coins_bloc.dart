import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'model.dart';
import 'resource_manager.dart';

class CoinsBloc {
  BigInt coins = BigInt.zero;

  final coinsSubject = BehaviorSubject<BigInt>();


  void initialize() async {
    _loadCoins().then((loadedCoins) {
      coins += loadedCoins;
    });
    coinsSubject.add(coins);
  }

  void dispose() {
    coinsSubject.close();
  }


  void findCoin() {
    coins += BigInt.one;
    coinsSubject.add(coins);
    _saveCoins(coins);
    print('Got $coins coins now.');
  }

  bool canBuy(Deck deck) {
    return coins >= BigInt.from(deck.price);
  }

  void buy(Deck deck) {
    assert(canBuy(deck));

    coins -= BigInt.from(deck.price);
    coinsSubject.add(coins);
    _saveCoins(coins);
  }
  

  static Future<void> _saveCoins(BigInt coins) {
    ResourceManager.saveString('coins', coins.toString()).catchError((e) {
      print('An error occured while saving $coins as coins: $e');
    });
  }

  static Future<BigInt> _loadCoins() async {
    return BigInt.parse(
      await ResourceManager.loadString('coins') ?? '0'
    );
  }
}
