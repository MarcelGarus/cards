import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'bloc/bloc.dart';
import 'bloc/model.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Bloc.of(context);

    final topPart = Material(
      elevation: 2.0,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Expanded(child: Container()),
              Image.asset('graphics/style384.png', width: 48.0, height: 48.0),
              Text('Cards', style: TextStyle(fontSize: 24.0)),
              Expanded(child: Container()),
            ]
          ),
          SizedBox(height: 8.0),
          NameSelector(),
        ],
      )
    );

    final bottomPart = StreamBuilder<List<Deck>>(
      stream: bloc.decks,
      builder: (context, snapshot) => DeckSelector(snapshot.data ?? [])
    );

    return Container(
      color: Color(0xFFF0F0F0),
      child: ListView(
        children: <Widget>[ topPart, bottomPart, SizedBox(height: 48.0 + 24.0) ],
      ),
    );
  }
}

class NameSelector extends StatelessWidget {
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
          final name = snapshot.data[i];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: InputChip(
              label: Text(name, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
              deleteIconColor: Colors.white,
              onDeleted: () {
                Bloc.of(context).removePlayer(name);
              },
            ),
          );
        })
      )
    );
  }

  Widget _buildInput(BuildContext context, AsyncSnapshot<List<String>> snapshot) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: NameInput(players: snapshot.data ?? [])
    );
  }
}

class NameInput extends StatefulWidget {
  NameInput({ @required this.players });

  final List<String> players;

  @override
  _NameInputState createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String errorText;

  String get _name => _controller.text;
  bool _isNameValid() => !widget.players.contains(_name);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Add a player',
        hintText: 'Enter the name',
        errorText: errorText
      ),
      onChanged: (String text) {
        setState(() {
          errorText = _isNameValid() || _name == '' ? null
            : 'You already added $_name.';
        });
      },
      onSubmitted: (String text) {
        if (_isNameValid() && text != '') {
          print('Adding player $text');
          Bloc.of(context).addPlayer(text);
          _controller.clear();
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
    );
  }
}

class DeckSelector extends StatelessWidget {
  DeckSelector(this.decks);
  
  final List<Deck> decks;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144.0 + 32.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(8.0),
        children: List.generate(decks.length, (i) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: SelectableDeck(
              deck: decks[i],
              onSelect: () => Bloc.of(context).selectDeck(decks[i]),
              onDeselect: () => Bloc.of(context).deselectDeck(decks[i]),
            )
          );
        })
      )
    );
  }
}

class SelectableDeck extends StatefulWidget {
  SelectableDeck({
    @required this.deck,
    @required this.onSelect,
    @required this.onDeselect
  });

  final Deck deck;
  final VoidCallback onSelect;
  final VoidCallback onDeselect;

  @override
  _SelectableDeckState createState() => _SelectableDeckState();
}

class _SelectableDeckState extends State<SelectableDeck> with SingleTickerProviderStateMixin {
  AnimationController _selectController;
  Animation<double> _selectAnimation;
  double _selectionValue;

  double get _defaultValue => widget.deck.isSelected ? 1.0 : 0.0;

  @override
  void initState() {
    super.initState();
    _selectionValue = _defaultValue;
    _selectController = AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..addListener(() => setState(() {
        _selectionValue = _selectAnimation?.value ?? _defaultValue;
      }));
  }

  @override
  void dispose() {
    _selectController.dispose();
    super.dispose();
  }

  void _toggleSelection() {
    final targetSelect = widget.deck.isSelected ? 0.0 : 1.0;
    _selectAnimation = Tween<double>(begin: _selectionValue, end: targetSelect)
      .animate(_selectController);
    _selectController
      ..value = 0.0
      ..fling(velocity: 2.0);

    if (widget.deck.isSelected)
      widget.onDeselect();
    else
      widget.onSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DeckCover(deck: widget.deck),
        Material(
          color: Colors.black.withOpacity(_selectionValue * 0.5),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          child: InkResponse(
            onTap: _toggleSelection,
            radius: 100.0,
            splashColor: Colors.white12,
            child: Container(
              width: 96.0,
              height: 144.0,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(0.0, 20 * (1 - _selectionValue)),
                child: Opacity(
                  opacity: _selectionValue,
                  child: Icon(Icons.check, color: Colors.white),
                )
              )
            )
          )
        )
      ],
    );
  }
}

class DeckCover extends StatelessWidget {
  DeckCover({ @required this.deck });

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final rgb = HEX.decode(deck.color.substring(1));
    final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);

    return Material(
      color: color,
      elevation: 2.0,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ Colors.white10, Colors.black12 ],
          ),
        ),
        width: 96.0,
        height: 144.0,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(deck.name)
        )
      )
    );
  }
}
