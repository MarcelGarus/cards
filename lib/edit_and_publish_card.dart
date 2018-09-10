import 'package:flutter/material.dart';
import 'bloc/model.dart';
import 'inline_card.dart';


/// Screen for editing a card.
class EditCardScreen extends StatelessWidget {
  EditCardScreen({ @required this.card }) : assert(card != null);
  
  /// The card to be edited.
  final ContentCard card;


  /// Animates to the publish screen.
  void _goToPublishScreen(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, _, __) {
        return PublishCardScreen(card: card);
      },
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child
        );
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    final materialCard = Padding(
      padding: EdgeInsets.all(16.0),
      child: Hero(
        tag: card.toString(),
        child: InlineCard(
          card: card,
          bottomBarLeading: SizedBox(
            height: 24.0,
            width: 24.0,
            child: CircularProgressIndicator(),
          ),
          editable: true,
          showPublishStatus: true,
        )
      )
    );

    return Scaffold(
      appBar: AppBar(title: Text('Edit card')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cloud_upload),
        elevation: 12.0,
        onPressed: () => _goToPublishScreen(context),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            materialCard,
            Guidelines()
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
    final cardWidget = Padding(
      padding: EdgeInsets.all(16.0),
      child: Hero(
        tag: card.toString(),
        child: InlineCard(
          card: card,
          showFollowup: false,
          showBottomBar: false,
        )
      )
    );

    final followup = card.hasFollowup
    ? Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: InlineCard(
          card: card.createFollowup(),
          showBottomBar: false,
        )
      )
    : Container();
    
    return Scaffold(
      appBar: AppBar(title: Text('Publish card')),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.cloud_upload),
        label: Text('Publish'),
        elevation: 12.0,
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Make sure that your card fulfills all the guidelines below.',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            cardWidget,
            followup,
            Guidelines()
          ]
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
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 48.0 + 2 * 16.0),
      child: ExpansionPanelList(
        expansionCallback: expansionCallback,
        children: guidelines.map((guideline) {
          return ExpansionPanel(
            isExpanded: guideline.isExpanded,
            headerBuilder: (context, isExpanded) => guideline.header,
            body: guideline.body
          );
        }).toList()
      )
    );
  }
}
