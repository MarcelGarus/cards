import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../utils.dart';
import 'edit_card.dart';

class CardsListScreen extends StatefulWidget {
  @override
  _CardsListScreenState createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen> {
  void _goToEditScreen(BuildContext context, GameCard card) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, _, __) {
        return EditCardScreen(card: card);
      },
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child
        );
      }
    ));
  }

  void _addNewCard(BuildContext context) async {
    final card = Bloc.of(context).createNewCard();
    _goToEditScreen(context, card);
  }

  @override
  Widget build(BuildContext context) {
    print('Building cards list.');
    return Theme(
      data: Utils.buildLightTheme(),
      child: Scaffold(
        appBar: AppBar(title: Text('Your cards')),
        body: SafeArea(
          child: StreamBuilder(
            stream: Bloc.of(context).myCards,
            builder: (context, AsyncSnapshot<List<GameCard>> snapshot) {
              return _buildCardsList(snapshot.data ?? []);
            }
          )
        )
      )
    );
  }

  Widget _buildCardsList(List<GameCard> cards) {
    final items = <Widget>[];
    print('Created cards are $cards.');

    for (final card in cards) {
      print('Creating card $card.');
      items.add(SizedBox(height: 16.0));
      items.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: InlineCard(
          card: card,
          showFollowup: false,
          showAuthor: false,
          onTap: () => _goToEditScreen(context, card)
        )
      ));
    }

    if (cards.isEmpty) {
      items.add(Center(child: Text('Pretty empty here...')));
    }

    items.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: OutlineButton(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.add),
              SizedBox(width: 8.0),
              Text('Add new card')
            ],
          )
        ),
        onPressed: () => _addNewCard(context),
        borderSide: BorderSide(color: Colors.black),
      )
    ));

    print('Returning list view with ${items.length} items.');
    return ListView(children: items);
  }
}
