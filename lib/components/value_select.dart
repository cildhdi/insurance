import 'package:flutter/material.dart';

class ValueSelect extends StatelessWidget {
  final int value, min, max;
  final void Function(int) onChange;
  final String Function(int) buildText;

  ValueSelect(
      {@required this.value,
      @required this.min,
      @required this.max,
      @required this.onChange,
      @required this.buildText});

  @override
  Widget build(BuildContext context) {
    List<Widget> selections = [];
    for (int index = min; index <= max; index++) {
      var text = Container(
        child: Text(
          buildText(index),
        ),
        padding: EdgeInsets.all(2),
        color: Colors.white,
      );
      selections.add(GestureDetector(
        onTap: () {
          onChange(index);
        },
        child: Container(
          padding: EdgeInsets.all(5),
          child: Container(
              color: index == value ? Colors.blue.shade500 : Colors.white,
              padding: EdgeInsets.all(2),
              child: text),
        ),
      ));
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: selections,
    );
  }
}
