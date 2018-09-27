import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../localize.dart';
import 'raw_card.dart';

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
  InlineCard(this.card, {
    this.showContent = true,
    this.showFollowup = true,
    this.showAuthor = true,
    this.bottomBarLeading,
    this.bottomBarTailing,
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
  final Widget bottomBarTailing;
  bool get hasBottomBar => bottomBarLeading != null || bottomBarTailing != null;

  // Callbacks for taps and changes (if editable).
  final VoidCallback onTap;
  final InlineCardChangedListener onEdited;
  bool get editable => onEdited != null;

  _InlineCardState createState() => _InlineCardState();
}

class _InlineCardState extends State<InlineCard> {
  TextEditingController contentController;
  TextEditingController followupController;
  TextEditingController authorController;

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
  // the user-provided content. This happens every time the content changes.
  void _onEdited() => widget.onEdited(
    context,
    contentController.text,
    followupController.text,
    authorController.text
  );

  @override
  Widget build(BuildContext context) {
    final rgb = HEX.decode(widget.card.color.substring(1));
    final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
    final signatureStyle = TextStyle(
      color: color,
      fontFamily: 'Signature',
      fontSize: 24.0,
      fontWeight: FontWeight.w700
    );
    final normalStyle = TextStyle(color: color, fontSize: 16.0);

    // List of column widgets, will be filled over time.
    final items = <Widget>[];

    // Add content.
    if (widget.showContent) {
      items.add(widget.editable ? Localized(
        builder: (context, localizer) {
          return CardInput(
            labelText: localizer.getItem(TextId.edit_card_content) ?? '',
            controller: contentController,
            maxLines: 4
          );
        },
      ) : Text(widget.card.content, style: signatureStyle));
    }
    
    // Add followup.
    if (widget.showFollowup && widget.card.hasFollowup || widget.editable) {
      items.add(widget.editable ? Localized(
        builder: (context, localizer) {
          return CardInput(
            labelText: localizer.getItem(TextId.edit_card_followup) ?? '',
            controller: followupController,
            maxLines: 4
          );
        },
      ) : Text(widget.card.followup, style: signatureStyle));
    }

    // Add author.
    if (widget.showAuthor) {
      items.add(widget.editable
      ? Localized(
        builder: (context, localizer) {
          return CardInput(
            labelText: localizer.getItem(TextId.edit_card_author) ?? '',
            controller: authorController,
            maxLines: 1,
          );
        }
      ) : widget.card.hasAuthor ? Localized(
        builder: (context, localizer) {
          return Text(
            (localizer.getItem(TextId.game_card_author) as String ?? '')
                .replaceAll('\$author', widget.card.author),
            style: normalStyle);
        }
      ) : Container());
    }

    // Add bottom bar.
    if (widget.hasBottomBar) {
      items.add(Row(
        children: <Widget>[
          widget.bottomBarLeading ?? Container(),
          Spacer(),
          widget.bottomBarTailing ?? Container()
        ],
      ));
    }

    return RawCard(
      heroTag: widget.card.id,
      borderRadius: BorderRadius.circular(8.0),
      expand: false,
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
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
        inputFormatters: [
          BlacklistingTextInputFormatter('|'),
          BlacklistingTextInputFormatter.singleLineFormatter,
          LengthLimitingTextInputFormatter(1000)
        ],
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
          fontFamily: 'Signature',
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 24.0
        ),
      )
    );
  }
}
