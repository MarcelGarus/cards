import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../localize.dart';
import '../utils.dart';
import 'edit_card.dart';
import 'published_card.dart';

class MyCardsScreen extends StatefulWidget {
  @override
  _MyCardsScreenState createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  void _openDetails(BuildContext context, MyCard card) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, _, __) {
        return card.isPublished
            ? PublishedCardScreen(card: card)
            : EditCardScreen(card: card);
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
    final card = Bloc.of(context).createCard();
    _openDetails(context, card);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Utils.myCardsTheme,
      child: Scaffold(
        appBar: AppBar(title: LocalizedText(TextId.my_cards_title)),
        body: SafeArea(
          child: StreamBuilder(
            stream: Bloc.of(context).myCards,
            builder: (context, AsyncSnapshot<List<MyCard>> snapshot) {
              return _buildCardsList(snapshot.data ?? []);
            }
          )
        )
      )
    );
  }

  Widget _buildCardsList(List<MyCard> cards) {
    final items = <Widget>[];

    for (final card in cards) {
      items.add(SizedBox(height: 16.0));
      items.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: InlineCard(card.gameCard,
          showFollowup: false,
          showAuthor: false,
          onTap: () => _openDetails(context, card)
        )
      ));
    }

    if (cards.isEmpty) {
      items.add(Center(child: LocalizedText(TextId.my_cards_empty)));
    }

    items.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: OutlineButton(
        highlightColor: Theme.of(context).primaryColor,
        highlightElevation: 0.0,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.add),
              SizedBox(width: 8.0),
              LocalizedText(TextId.my_cards_add)
            ],
          )
        ),
        onPressed: () => _addNewCard(context),
        borderSide: BorderSide(color: Colors.black),
      )
    ));

    return ListView(children: items);
  }
}
