import 'package:flutter/material.dart';

class ValueSlider extends StatelessWidget {
  final int value, min, max;
  final void Function(int) onChange;
  final String Function(int) buildText;

  ValueSlider(
      {@required this.value,
      @required this.min,
      @required this.max,
      @required this.onChange,
      @required this.buildText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          width: 60,
          child: Text(buildText(value)),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            onChanged: (v) {
              this.onChange(v.round());
            },
            min: min.toDouble(),
            max: max.toDouble(),
          ),
        )
      ],
    );
  }
}
