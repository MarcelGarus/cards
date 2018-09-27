import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../localize.dart';
import '../menu.dart';
import '../utils.dart';
import 'guidelines.dart';
import 'publish_card.dart';
import 'published_card.dart';

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

    Bloc.of(context).myCards.listen((myCards) {
      final card = myCards
          .singleWhere((card) => card.gameCard.id == widget.card.gameCard.id);

      if (card.isPublished) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PublishedCardScreen(card: card)
        ));
      }
    });
  }

  /// Shows the menu with a prompt to sign in.
  void _showSignInMenu() {
    showModalBottomSheet(context: context, builder: (_) => SignInMenu());
  }

  /// Animates to the publish screen.
  void _goToPublishScreen() {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, _, __) {
        return PublishCardScreen(card: _createEditedCard());
      },
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      }
    ));
  }

  /// Creates a card from the current content, followup and author.
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
    final appBar = AppBar(
      title: LocalizedText(TextId.edit_card_title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            Bloc.of(context).deleteCard(widget.card);
            Navigator.of(context).pop();
          },
        )
      ],
    );

    final card = Padding(
      padding: EdgeInsets.all(16.0),
      child: InlineCard(widget.card.gameCard,
        onEdited: _onChanged,
        bottomBarTailing: _buildPublishStatus()
      )
    );

    final guidelines = Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Guidelines()
    );

    return Theme(
      data: Utils.myCardsTheme,
      child: Scaffold(
        appBar: appBar,
        body: SafeArea(child: ListView( children: [ card, guidelines ])),
      )
    );
  }


  Widget _buildPublishStatus() {
    return StreamBuilder(
      stream: Bloc.of(context).account,
      builder: (context, AsyncSnapshot<AccountState> snapshot) {
        if (!snapshot.hasData)
          return Container();
        
        final account = snapshot.data;
        final isSignedIn = account.signInState == SignInState.SIGNED_IN;
        final text = LocalizedText(
          isSignedIn ? TextId.edit_card_publish : TextId.edit_card_sign_in,
          style: TextStyle(color: Colors.white)
        );

        return FlatButton(
          onPressed: isSignedIn ? _goToPublishScreen : _showSignInMenu,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              text,
              SizedBox(width: 8.0),
              Icon(Icons.cloud_upload, color: Colors.white),
            ]
          )
        );
      },
    );
  }
}
