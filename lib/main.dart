import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:insurance/pages/main.dart';

void main() => runApp(MaterialApp(
      title: "保了么",
      home: new Main(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('zh')],
    ));
