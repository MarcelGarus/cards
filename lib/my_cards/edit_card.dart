import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import 'guidelines.dart';
import 'publish_card.dart';

/// Screen for editing a card.
class EditCardScreen extends StatefulWidget {
  EditCardScreen({ @required this.card }) :
      assert(card != null);
  
  final GameCard card;

  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  String content;
  String followup;
  String author;

  void initState() {
    super.initState();
    content = widget.card.content;
    followup = widget.card.followup;
    author = widget.card.author;
  }

  /// Animates to the publish screen.
  void _goToPublishScreen(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
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

  GameCard _createEditedCard() {
    return GameCard(
      id: widget.card.id,
      color: '#FFFFFF',
      content: content,
      followup: followup,
      author: author
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
      child: InlineCard(
        card: widget.card,
        onEdited: _onChanged,
      )
    );

    return Scaffold(
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
    );
  }
}
