import 'package:flutter/material.dart';

/// An item in the guidelines list.
class GuidelineItem {
  GuidelineItem({
    this.title,
    this.content,
    this.positiveExample = '',
    this.negativeExample = '',
  });

  final String title;
  final String content;
  final String positiveExample;
  final String negativeExample;
  bool isExpanded = false;

  Widget get header {
    return Row(
      children: <Widget>[
        SizedBox(width: 16.0),
        Expanded(child: Text(title))
      ],
    );
  }

  Widget get body {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(content),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              _buildCard(positiveExample, Colors.green),
              SizedBox(width: 8.0),
              _buildCard(negativeExample, Colors.red)
            ],
          )
        ]
      )
    );
  }

  Widget _buildCard(String text, Color color) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: color))
      ),
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
      title: 'How to include players',
      content: 'You can use \$a, \$b etc. as placeholders for names. During '
        'the game, these will be replaced by actual names.',
      positiveExample: '\$a, mach etwas.',
      negativeExample: 'Alice, mach etwas.'
    ),
    GuidelineItem(
      title: 'First person speech',
      content: 'Try to use first person speech whenever possible in order to '
        'be more engaging.',
      positiveExample: '\$a, tu etwas.',
      negativeExample: '\$a muss etwas tun.'
    ),
    GuidelineItem(
      title: 'Punctuation',
      content: 'Even in imperative sentences, use a period instead of an '
        'exclamation mark. Otherwise, players would feel like being shouted '
        'at all the time.',
      positiveExample: '\$a, mach etwas.',
      negativeExample: '\$a mach etwas!'
    ),
    GuidelineItem(
      title: 'Numbers',
      content: 'Write all numbers except one as digits.',
      positiveExample: '\$a, tu 3 Sachen.',
      negativeExample: '\$a tu drei Sachen.'
    ),
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
