import 'package:flutter/material.dart';

class FormItem extends StatelessWidget {
  final String title;
  final Widget content;

  FormItem({@required this.title, @required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.subhead,
            ),
            content
          ],
        ),
      ),
    );
  }
}
