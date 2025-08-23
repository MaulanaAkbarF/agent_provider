import 'package:shared_preferences/shared_preferences.dart';

class UserShared {
  static const String initialUser = 'initial';

  static Future<void> saveInitialUser() async {
    await SharedPreferences.getInstance().then((prefs) => prefs.setBool(initialUser, true));
  }

  static Future<bool?> getInitialUser() async {
    return await SharedPreferences.getInstance().then((prefs) => prefs.getBool(initialUser));
  }
}