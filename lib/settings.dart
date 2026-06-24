import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  Settings._create();

  static Settings? _singleton;

  static Future<Settings> getInstance() async {
    if (_singleton == null) {
      _singleton = Settings._create();
      _singleton?._preferences = await SharedPreferences.getInstance();
    }
    return _singleton!;
  }

  late SharedPreferences _preferences;

  String get sessionID {
    return _preferences.getString("POESESSID") ?? "";
  }

  set sessionID(String value) {
    _preferences.setString("POESESSID", value);
  }

  String get activeLeague {
    return _preferences.getString("activeLeague") ?? "";
  }

  set activeLeague(String value) {
    _preferences.setString("activeLeague", value);
  }

  List<String> get pricedCategories {
    return _preferences.getStringList("pricedCategories") ?? List.empty();
  }

  set pricedCategories(List<String> value) {
    _preferences.setStringList("pricedCategories", value);
  }
}
