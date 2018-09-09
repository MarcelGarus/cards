import 'package:flutter/material.dart';

class CreateCardScreen extends StatefulWidget {
  @override
  _CreateCardScreenState createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  @override
  Widget build(BuildContext context) {
    final contentInput = TextField(
      autofocus: true,
      maxLines: 3,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red)
        ),
        fillColor: Colors.white,
        labelText: 'Card content',
        labelStyle: TextStyle(color: Colors.white),
      ),
      style: TextStyle(color: Colors.white),
    );

    final followupInput = TextField(
      maxLines: 3,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Followup',
        labelStyle: TextStyle(color: Colors.white)
      ),
      style: TextStyle(color: Colors.white),
    );

    final authorInput = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Author',
        labelStyle: TextStyle(color: Colors.white)
      ),
      style: TextStyle(color: Colors.white),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Create card'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Guidelines(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Material(
                elevation: 4.0,
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      contentInput,
                      SizedBox(height: 8.0),
                      followupInput,
                      SizedBox(height: 8.0),
                      authorInput
                    ],
                  )
                )
              )
            ),
          ]
        )
      ),
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