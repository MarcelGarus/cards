import 'package:flutter/material.dart';
import 'create_card.dart';
import 'created_cards.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.verified_user, color: Colors.black),
          title: Text('Log in'),
          subtitle: Text('Log in to synchronize your progress across devices and in order to publish your own cards.'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.add, color: Colors.black),
          title: Text('Write a card'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return CreateCardScreen();
              }
            ));
          },
        ),
        ListTile(
          leading: Icon(Icons.wb_iridescent, color: Colors.black),
          title: Text('My cards'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return CardListScreen();
              }
            ));
          },
        ),
        ListTile(
          leading: Icon(Icons.feedback, color: Colors.black),
          title: Text('Send feedback'),
        ),
        Row(
          children: <Widget>[
            Text('Open-source licenses'),
            Text('Privacy Policy'),
            Text('Terms of Service'),
          ],
        )
      ],
    );
    
    return Material(
      child: GestureDetector(
        onTap: () {},
        child: column
      )
    );
  }
}