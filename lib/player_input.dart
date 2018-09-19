import 'package:flutter/material.dart';
import 'bloc/bloc.dart';
import 'localize.dart';

/// A list of names as well as the input below.
class PlayerInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).players,
      builder: (context, snapshot) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildNames(context, snapshot),
            _buildInput(context, snapshot)
          ]
        );
      },
    );
  }

  Widget _buildNames(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.data == null || snapshot.data.length == 0) {
      return Container(
        height: 32.0,
        alignment: Alignment.center,
        child: Text('Pretty empty here...')
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        children: List.generate(snapshot.data?.length ?? 0, (i) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: PlayerChip(name: snapshot.data[i])
          );
        })
      )
    );
  }

  Widget _buildInput(
    BuildContext context,
    AsyncSnapshot<List<String>> snapshot
  ) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: NameInput(players: snapshot.data ?? [])
    );
  }
}



/// A single player chip, animating from the right as it is created.
class PlayerChip extends StatefulWidget {
  PlayerChip({ @required this.name });

  final String name;

  @override
  _PlayerChipState createState() => _PlayerChipState();
}

class _PlayerChipState extends State<PlayerChip>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation animation;
  double animationValue = 0.0;

  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )..forward();
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOut)
        ..addListener(() => setState(() {
          animationValue = animation.value;
        }));
  }

  Offset getOffset() {
    return Offset(
      (1.0 - animationValue) * MediaQuery.of(context).size.width,
      0.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: getOffset(),
      child: InputChip(
        label: Text(widget.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)
        ),
        backgroundColor: Colors.black,
        deleteIconColor: Colors.white,
        onDeleted: () => Bloc.of(context).removePlayer(widget.name)
      ),
    );
  }
}



/// The input field where players can input their names.
class NameInput extends StatefulWidget {
  NameInput({ @required this.players });

  /// List of players, used to validate input.
  final List<String> players;

  @override
  _NameInputState createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String get _name => _controller.text;


  String get errorText {
    final showError = Bloc.of(context).isPlayerInputErroneous(_name);
    return !showError ? null : Bloc.of(context)
        .getText(TextId.add_player_error)
        .replaceFirst('\$author', _name);
  }

  @override
  Widget build(BuildContext context) {
    return Localized(
      builder: (context) {
        return TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: Bloc.of(context).getText(TextId.add_player_label),
            hintText: Bloc.of(context).getText(TextId.add_player_hint),
            errorText: errorText
          ),
          onChanged: (String text) => setState(() {}),
          onSubmitted: (String text) {
            if (Bloc.of(context).isPlayerInputValid(_name)) {
              Bloc.of(context).addPlayer(_name);
              _controller.clear();
              FocusScope.of(context).requestFocus(_focusNode);
            }
          },
        );
      }
    );
  }
}
