import 'package:flutter/material.dart';
import 'bloc/bloc.dart';
import 'localize.dart';
import 'utils.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  TextEditingController controller = TextEditingController();
  
  void _sendFeedback() {
    if (_isValid) {
      Bloc.of(context).sendFeedback(controller.text);
    }
  }

  bool get _isValid => (controller?.text?.length ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Utils.feedbackTheme,
      child: Scaffold(
        appBar: AppBar(
          title: LocalizedText(TextId.feedback_title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _isValid ? _sendFeedback : null
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Localized(
              builder: (context, localizer) {
                TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (text) => setState(() {}),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: localizer.getItem(TextId.feedback_hint)
                  ),
                  maxLines: null,
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                );
              }
            ),
          )
        )
      )
    );
  }
}
