import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Map<String, String> _localizedStrings;

  AppLocalizations(this._localizedStrings);

  static Future<AppLocalizations> load(String locale) async {
    String jsonString = await rootBundle.loadString('lib/l10n/translations/$locale.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    return AppLocalizations(jsonMap.map((key, value) => MapEntry(key, value.toString())));
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
