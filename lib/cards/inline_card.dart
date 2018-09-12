import 'package:flutter/material.dart';
import '../bloc/model.dart';

/// Listener that listens for changes to either the content, followup or author
/// text fields' contents.
typedef void InlineCardChangedListener(
  BuildContext context,
  String content,
  String followup,
  String author
);

/// A non-fullscreen card that is solemnly used for [GameCard]s that the
/// user creates.
class InlineCard extends StatefulWidget {
  InlineCard({
    @required this.card,
    this.showContent = true,
    this.showFollowup = true,
    this.showAuthor = true,
    this.bottomBarLeading,
    this.bottmoBarTailing,
    this.onTap,
    this.onEdited
  });

  /// The content card.
  final GameCard card;

  // Toggles for whether several parts of the card should be shown or not.
  final bool showContent;
  final bool showFollowup;
  final bool showAuthor;

  /// A widget inserted at the start of the bottom bar.
  final Widget bottomBarLeading;
  final Widget bottmoBarTailing;

  // Callbacks for taps and changes (if editable).
  final VoidCallback onTap;
  final InlineCardChangedListener onEdited;
  bool get editable => onEdited != null;

  _InlineCardState createState() => _InlineCardState();
}

class _InlineCardState extends State<InlineCard> {
  TextEditingController contentController, followupController, authorController;

  void initState() {
    super.initState();

    if (widget.editable) {
      contentController = TextEditingController(text: widget.card.content)
          ..addListener(_onEdited);
      followupController = TextEditingController(text: widget.card.followup)
          ..addListener(_onEdited);
      authorController = TextEditingController(text: widget.card.author)
          ..addListener(_onEdited);
    }
  }

  // Once one of the property is edited, call the provided callback with all of
  // the user-provided content.
  void _onEdited() => widget.onEdited(
    context,
    contentController.text,
    followupController.text,
    authorController.text
  );

  @override
  Widget build(BuildContext context) {
    // Create a modified theme because of black background.
    final textTheme = Theme.of(context).textTheme;
    final themeData = Theme.of(context).copyWith(
      hintColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber)
        ),
      ),
      textTheme: textTheme.copyWith(
        body1: textTheme.body1.copyWith(color: Colors.white, fontSize: 24.0),
      ),
    );

    // List of column widgets, will be filled over time.
    final items = <Widget>[];

    // Add content.
    if (widget.showContent) {
      items.add(widget.editable ? CardInput(
        labelText: 'Content',
        controller: contentController,
        maxLines: 3,
      ) : Text(widget.card.content));
    }
    
    // Add followup.
    if (widget.showFollowup && (widget.card.hasFollowup) || widget.editable) {
      items.add(widget.editable ? CardInput(
        labelText: 'Followup',
        controller: followupController,
        maxLines: 3
      ) : Text(widget.card.followup));
    }

    // Add author.
    if (widget.showAuthor) {
      items.add(widget.editable
      ? CardInput(
        labelText: 'Author',
        controller: authorController,
        maxLines: 1,
      ) : widget.card.hasAuthor ? Text(
        'von ${widget.card.author}',
        style: TextStyle(fontSize: 16.0)
      ) : Container());
    }

    // Add bottom bar.
    items.add(Row(
      children: <Widget>[
        widget.bottomBarLeading ?? Container(),
        Spacer(),
        widget.bottmoBarTailing ?? Container()
      ],
    ));

    return Theme(
      data: themeData,
      child: Hero(
        tag: widget.card,
        child: Material(
          elevation: 4.0,
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          child: LayoutBuilder(
            builder: (context, BoxConstraints constraints) {
              // During the hero animation, the InlineCard is lifted up into
              // the overlay, where it's provided with tight constraints. To
              // avoid overflow errors and visual inconsistencies when
              // animating from a smaller to a larger position (and thus trying
              // to display the larger content in smaller, tight constraints),
              // the content of the card isn't shown during the hero animation.
              return constraints.isTight ? Container() : InkResponse(
                onTap: widget.onTap ?? () {},
                radius: 1000.0, // TODO: do not hardcode
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items
                  )
                ),
              );
            },
          )
        )
      )
    );
  }
}



/// An input on the card.
class CardInput extends StatelessWidget {
  CardInput({
    @required this.labelText,
    this.controller,
    this.maxLines,
  }) :
      assert(labelText != null);

  final String labelText;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.body2.copyWith(
            color: Colors.white
          )
        ),
        style: Theme.of(context).textTheme.body2.copyWith(
          color: Colors.white,
          fontSize: 24.0
        ),
      )
    );
  }
}
