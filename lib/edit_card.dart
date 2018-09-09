import 'package:flutter/material.dart';
import 'bloc/model.dart';

class EditCardScreen extends StatelessWidget {
  EditCardScreen({ @required this.card }) : assert(card != null);
  
  final ContentCard card;

  @override
  Widget build(BuildContext context) {
    final contentInput = CardInput(
      labelText: 'Card content',
      maxLines: 3,
      seedValue: card.content ?? '',
    );

    final followupInput = CardInput(
      labelText: 'Followup',
      maxLines: 3,
      seedValue: card.followup ?? '',
    );
    
    final authorInput = CardInput(
      labelText: 'Author',
      seedValue: card.author ?? '',
    );

    final publishBar = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text('Not published yet'),
        IconButton(
          icon: Icon(Icons.cloud_upload, color: Colors.white),
          onPressed: () {}
        )
      ],
    );

    final textTheme = Theme.of(context).textTheme;
    final materialCard = Theme(
      data: Theme.of(context).copyWith(
        hintColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber)
          ),
        ),
        textTheme: textTheme.copyWith(
          body1: textTheme.body1.copyWith(color: Colors.white),
        ),
      ),
      child: Material(
        elevation: 4.0,
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0),
              contentInput,
              SizedBox(height: 16.0),
              followupInput,
              SizedBox(height: 16.0),
              authorInput,
              SizedBox(height: 8.0),
              publishBar
            ],
          )
        )
      )
    );

    return Scaffold(
      appBar: AppBar(title: Text('Edit card')),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: materialCard
            ),
            Guidelines()
          ]
        )
      )
    );
  }
}

class CardInput extends StatefulWidget {
  CardInput({
    @required this.labelText,
    this.maxLines,
    this.seedValue = '',
  }) :
      assert(labelText != null);

  final String labelText;
  final int maxLines;
  final String seedValue;

  @override
  State<StatefulWidget> createState() => _CardInputState();
}

class _CardInputState extends State<CardInput> {
  TextEditingController _controller;
  
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.seedValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: widget.maxLines,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.labelText,
        labelStyle: Theme.of(context).textTheme.body2.copyWith(color: Colors.white)
      ),
      style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),
    );
  }
}

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
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
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
