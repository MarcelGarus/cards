import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../utils.dart';
import 'guidelines.dart';
import 'publish_card.dart';

/// Screen for editing a card.
class EditCardScreen extends StatefulWidget {
  EditCardScreen({ @required this.card }) :
      assert(card != null);
  
  final MyCard card;

  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  String content;
  String followup;
  String author;

  void initState() {
    super.initState();
    content = widget.card.gameCard.content;
    followup = widget.card.gameCard.followup;
    author = widget.card.gameCard.author;
  }

  /// Animates to the publish screen.
  void _goToPublishScreen(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, _, __) {
        return PublishCardScreen(card: _createEditedCard());
      },
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child
        );
      }
    ));
  }

  MyCard _createEditedCard() {
    return MyCard(
      gameCard: GameCard(
        id: widget.card.gameCard.id,
        color: '#FFFFFF',
        content: content,
        followup: followup,
        author: author
      ),
      isEnabled: widget.card.isEnabled
    );
  }

  // Card changed.
  void _onChanged(
    BuildContext context,
    String content,
    String followup,
    String author
  ) {
    print('Saving card with content: $content, followup: $followup, author: '
        '$author');

    this.content = content;
    this.followup = followup;
    this.author = author;

    Bloc.of(context).updateCard(_createEditedCard());
  }

  @override
  Widget build(BuildContext context) {
    
    final materialCard = Padding(
      padding: EdgeInsets.all(16.0),
      child: InlineCard(widget.card.gameCard, onEdited: _onChanged)
    );

    return Theme(
      data: Utils.buildLightTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit card'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.delete), onPressed: () {})
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.cloud_upload),
          label: Text('Publish'),
          elevation: 12.0,
          onPressed: () => _goToPublishScreen(context),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              materialCard,
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0 + 48.0 + 16.0
                ),
                child: Guidelines()
              )
            ]
          )
        ),
      )
    );
  }
}
