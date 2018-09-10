import 'package:flutter/material.dart' hide Card;
import 'package:hex/hex.dart';
import 'bloc/model.dart';


/// A fullscreen card in the game.
class RawCard extends StatelessWidget {
  RawCard({
    @required this.card,
    this.backgroundColor = Colors.black,
    this.borderRadius,
    this.safeAreaTop = 0.0,
    this.leading,
    this.tailing
  }) :
      assert(card != null),
      assert(backgroundColor != null),
      assert(safeAreaTop != null);

  /// The card to display.
  final Card card;

  /// The color of the material.
  final Color backgroundColor;

  /// The border radius of the material.
  final BorderRadius borderRadius;

  /// The size of the safe area at the top of the card.
  final double safeAreaTop;

  /// A leading widget in the app bar.
  final Widget leading;

  /// A tailing widget in the app bar.
  final Widget tailing;


  @override
  Widget build(BuildContext context) {
    final appBarItems = <Widget>[];
    appBarItems.add(leading ?? Container());
    appBarItems.add(Spacer());
    appBarItems.add(tailing ?? Container());

    // A list of all content stuff. Common safe area and app bar stuff is
    // already added, the card handler adds more stuff.
    final content = <Widget>[
      SizedBox(height: safeAreaTop),
      Row(children: appBarItems)
    ];

    // Call the correct handler based on the card's type.
    if (card is EmptyCard)
      content.addAll(_buildEmptyCard(context, card));
    else if (card is IntroductionCard)
      content.addAll(_buildIntroductionCard(context, card));
    else if (card is ContentCard)
      content.addAll(_buildContentCard(context, card));
    else if (card is CoinCard)
      content.addAll(_buildCoinCard(context, card));

    // Returns the actual card.
    return Material(
      color: backgroundColor,
      elevation: 8.0,
      animationDuration: Duration.zero,
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Column(children: content),
    );
  }


  /// Builds an empty card.
  List<Widget> _buildEmptyCard(BuildContext context, EmptyCard card) => [];


  /// Builds a welcome card.
  List<Widget> _buildIntroductionCard(BuildContext context, IntroductionCard card) {
    return [
      Expanded(child: Container()),
      Text(card.text, style: TextStyle(color: Colors.white, fontSize: 24.0)),
      Expanded(child: Container())
    ];
  }


  /// Builds a content card.
  List<Widget> _buildContentCard(BuildContext context, ContentCard card) {
    final rgb = HEX.decode(card.color.substring(1));
    final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
    
    return [
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FittedText(
            text: card.content,
            style: TextStyle(color: color)
          )
        )
      ),
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(card.hasAuthor ? 'von ${card.author}' : '',
              style: TextStyle(color: color)
            ),
            Text(card.id,
              style: TextStyle(color: Color.lerp(color, Colors.black, 0.9))
            ),
          ],
        )
      )
    ];
  }


  /// Builds a coin card.
  List<Widget> _buildCoinCard(BuildContext context, CoinCard card) {
    return [
      Expanded(child: Container()),
      Icon(Icons.code, color: Colors.white),
      Text(card.text, style: TextStyle(color: Colors.white)),
      Expanded(child: Container()),
    ];
  }
}



/// Tries to change the font size of the given style to match the text in the
/// widget's constraints, while displaying it as large as possible and ahering
/// to material design standards.
class FittedText extends StatefulWidget {
  FittedText({
    @required this.text,
    @required this.style
  }) :
      assert(text != null),
      assert(style != null);

  /// The text to be displayed.
  final String text;

  /// The style of the text. The style's fontSize property will be overwritten.
  final TextStyle style;

  @override
  _FittedTextState createState() => _FittedTextState();
}

class _FittedTextState extends State<FittedText> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight * 0.9
        );
        return Center(
          child: Text(
            widget.text,
            style: _styleToFitTextInSize(size),
            overflow: TextOverflow.fade,
          )
        );
      }
    );
  }

  // Starts with a large font size, then decreases it and returns a style with
  // the first size which makes the text fit in the size.
  TextStyle _styleToFitTextInSize(Size size) {
    for (double fontSize = 48.0; fontSize > 4; fontSize -= 4) {
      final textStyle = widget.style.copyWith(fontSize: fontSize);
      final textSpan = TextSpan(text: widget.text, style: textStyle);
      final richText = RichText(text: textSpan);
      final renderObject = richText.createRenderObject(context);
      final textHeight = renderObject.getMaxIntrinsicHeight(size.width);

      if (textHeight <= size.height) {
        //print('Text ${widget.text} with font size $fontSize is $textHeight <= ${size.height} high. Style was $textStyle (fontFamily ${textStyle.fontFamily}).');
        return textStyle.copyWith(fontSize: fontSize - 4);
      }
    }
  }
}
