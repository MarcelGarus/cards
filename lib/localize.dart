import 'package:flutter/material.dart';
import 'bloc/bloc.dart';

typedef LocalizedBuilder(BuildContext context, Localizer localizer);

class Localized extends StatelessWidget {
  Localized({ @required this.builder }) : assert(builder != null);

  final LocalizedBuilder builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).localizer,
      builder: (context, snapshot) {
        return builder(context, snapshot.data ?? Localizer.empty);
      },
    );
  }
}

class LocalizedText extends StatelessWidget {
  LocalizedText(this.id, { this.style, this.textAlign });
  
  final TextId id;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Localized(
      builder: (context, localizer) {
        return Text(
          localizer.getItem(id) ?? '<$id missing>',
          style: style,
          textAlign: textAlign,
        );
      }
    );
  }
}
