import 'package:flutter/material.dart';
import 'bloc/bloc.dart';

class Localized extends StatelessWidget {
  Localized({ @required this.builder }) : assert(builder != null);

  final Function builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).locale,
      builder: (context, _) => builder(context),
    );
  }
}

class LocalizedText extends StatelessWidget {
  LocalizedText({
    @required this.id,
    this.style
  });
  
  final TextId id;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Localized(
      builder: (context) => Text(Bloc.of(context).getText(id), style: style)
    );
  }
}
