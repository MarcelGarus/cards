import 'package:flutter/material.dart';
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
        return PublishCardScreen(card: widget.card);
      },
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child
        );
      }
    ));
  }

  // Card changed.
  void _onChanged(BuildContext context, String content, String followup, String author) {
    print('Content: $content, followup: $followup, author: $author');

    //Bloc.of(context).
  }

  @override
  Widget build(BuildContext context) {
    /*final bottomBarTailing = if (widget.showPublishStatus) {
      bottomBar.add(Text(
        widget.isPublished ? 'Published' : 'Not published yet',
        style: TextStyle(fontSize: 16.0)
      ));

      bottomBar.add(SizedBox(width: 8.0));
      bottomBar.add(Icon(
        widget.isPublished ? Icons.cloud_done : Icons.cloud_off,
        color: Colors.white
      ));
    }*/

    final materialCard = Padding(
      padding: EdgeInsets.all(16.0),
      child: Hero(
        tag: widget.card.id,
        child: InlineCard(
          card: widget.card,
          bottomBarLeading: SizedBox(
            height: 24.0,
            width: 24.0,
            child: CircularProgressIndicator(),
          ),
          onEdited: _onChanged,
        )
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
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0 + 48.0 + 16.0),
              child: Guidelines()
            )
          ]
        )
      ),
    );
  }
}