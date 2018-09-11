import 'package:flutter/material.dart';
import 'bloc/bloc.dart';
import 'bloc/model.dart';
import 'inline_card.dart';


/// Screen for editing a card.
class EditCardScreen extends StatefulWidget {
  EditCardScreen({ @required this.card }) :
      assert(card != null);
  
  final ContentCard card;

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
          editable: true,
          onChanged: _onChanged,
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



/// The screen for publishing the card.
class PublishCardScreen extends StatelessWidget {
  PublishCardScreen({ @required this.card }) : assert(card != null);
  
  final ContentCard card;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('Make sure that your card fulfills all the guidelines below.',
        style: TextStyle(fontSize: 24.0),
      ),
    ));

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: Hero(
        tag: card.toString(),
        child: InlineCard(
          card: card,
          showFollowup: false,
        )
      )
    ));

    if (card.hasFollowup) {
      content.add(Center(
        child: Material(
          color: Colors.white,
          elevation: 2.0,
          shape: StadiumBorder(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text('Then, after some time:')
          )
        )
      ));
      content.add(Padding(
        padding: EdgeInsets.all(16.0),
        child: InlineCard(
          card: card.createFollowup(),
        )
      ));
    }

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: Guidelines()
    ));

    content.add(Container(
      padding: EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: FloatingActionButton.extended(
        icon: Icon(Icons.cloud_upload),
        label: Text('Publish'),
        elevation: 12.0,
        onPressed: () {},
      )
    ));

    return Scaffold(
      appBar: AppBar(title: Text('Publish card')),
      body: SafeArea(
        child: ListView(
          children: content
        )
      ),
    );
  }
}



/// An item in the guidelines list.
class GuidelineItem {
  GuidelineItem({ this.icon, this.title, this.content });

  final Icon icon;
  final String title;
  final String content;
  bool isExpanded = false;

  Widget get header {
    return Row(
      children: <Widget>[
        SizedBox(width: 16.0),
        icon,
        SizedBox(width: 8.0),
        Expanded(child: Text(title))
      ],
    );
  }

  Widget get body {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Text(content)
    );
  }
}

/// The guidelines.
class Guidelines extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GuidelinesState();
}

class _GuidelinesState extends State<Guidelines> {
  final guidelines = [
    GuidelineItem(
      icon: Icon(Icons.people_outline),
      title: 'How to include players',
      content: 'You can use Alice and Bob as placeholders for names. During the game, these will be replaced by actual names.'
    ),
    GuidelineItem(
      icon: Icon(Icons.description),
      title: 'Guidelines',
      content: 'Write numbers as digits (except one)\nNew lined text.'
    )
  ];

  void expansionCallback(int index, bool isExpanded) {
    final guideline = guidelines[index];
    setState(() {
      guideline.isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: expansionCallback,
      children: guidelines.map((guideline) {
        return ExpansionPanel(
          isExpanded: guideline.isExpanded,
          headerBuilder: (context, isExpanded) => guideline.header,
          body: guideline.body
        );
      }).toList()
    );
  }
}
