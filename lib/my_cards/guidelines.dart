import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../localize.dart';

/// An item in the guidelines list.
class GuidelineItem {
  GuidelineItem({
    this.title,
    this.content,
    this.positiveExamples = const [],
    this.negativeExamples = const [],
  });

  final String title;
  final String content;
  final List<String> positiveExamples;
  final List<String> negativeExamples;
  bool isExpanded = false;

  Widget get header {
    return Row(
      children: <Widget>[
        SizedBox(width: 16.0),
        Expanded(
          child: Text(title,
            style: TextStyle(
              fontFamily: 'Signature',
              fontSize: 16.0,
              fontWeight: FontWeight.w700
            )
          )
        )
      ],
    );
  }

  Widget get body {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(content),
          SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _buildExamples(positiveExamples, Colors.green)),
              SizedBox(width: 8.0),
              Expanded(child: _buildExamples(negativeExamples, Colors.red))
            ],
          )
        ]
      )
    );
  }

  Widget _buildExamples(List<String> examples, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(examples.length * 2 - 1, (i) {
        return i.isOdd ? SizedBox(height: 8.0)
            : _buildExample(examples[i ~/ 2], color);
      }).toList(),
    );
  }

  Widget _buildExample(String text, Color color) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700))
      ),
    );
  }
}

class Guidelines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Localized(
      builder: (context, localizer) => ExpandableGuidelines(localizer)
    );
  }
}

/// The guidelines.
class ExpandableGuidelines extends StatefulWidget {
  ExpandableGuidelines(this.localizer);

  // Guidelines from yaml.
  final Localizer localizer;

  @override
  State<StatefulWidget> createState() => _GuidelinesState();
}

class _GuidelinesState extends State<ExpandableGuidelines> {
  Localizer localizer;
  List<GuidelineItem> guidelines = [];

  void _loadGuidelines(Localizer localizer) {
    this.localizer = localizer;

    guidelines = (localizer.getItem(TextId.guidelines) as List ?? [])
      .map((guideline) => GuidelineItem(
        title: guideline['title'],
        content: guideline['body'],
        positiveExamples: guideline['positive'].map<String>((e) => e['text'] as String).toList(),
        negativeExamples: guideline['negative'].map<String>((e) => e['text'] as String).toList()
      )).toList();
  }

  void expansionCallback(int index, bool isExpanded) {
    final guideline = guidelines[index];
    setState(() {
      guideline.isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (localizer != widget.localizer)
      _loadGuidelines(widget.localizer);

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
