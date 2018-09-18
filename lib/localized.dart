import 'package:flutter/material.dart';
import 'bloc/bloc.dart';

class Localized extends StatelessWidget {
  Localized({ @required this.child }) : assert(child != null);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).locale,
      builder: (context, _) => child,
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
    return Localized(child: Text(Bloc.of(context).getText(id), style: style));
  }
}
