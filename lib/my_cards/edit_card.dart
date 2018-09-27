import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../menu.dart';
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
    print(
      'Saving card with content: $content, followup: $followup, author: '
      '$author'
    );

    this.content = content;
    this.followup = followup;
    this.author = author;

    Bloc.of(context).updateCard(_createEditedCard());
  }

  @override
  Widget build(BuildContext context) {
    final materialCard = Padding(
      padding: EdgeInsets.all(16.0),
      child: InlineCard(widget.card.gameCard,
        onEdited: _onChanged,
        bottomBarTailing: _buildPublishStatus()
      )
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

  Widget _buildPublishStatus() {
    return StreamBuilder(
      stream: Bloc.of(context).account,
      builder: (context, AsyncSnapshot<AccountState> snapshot) {
        if (!snapshot.hasData)
          return Container();
        
        final account = snapshot.data;
        final isSignedIn = account.connectionState == AccountConnectionState.SIGNED_IN;
        final text = Text(
          isSignedIn ? 'Tap to publish' : 'Sign in to publish',
          style: TextStyle(color: Colors.white)
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            text,
            IconButton(
              icon: Icon(Icons.cloud_upload, color: Colors.white),
              onPressed: () => isSignedIn
                  ? _goToPublishScreen()
                  : _showSignInMenu(),
            )
          ]
        );
      },
    );
  }
}
