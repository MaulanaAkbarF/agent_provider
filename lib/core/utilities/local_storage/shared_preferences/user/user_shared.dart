import 'package:shared_preferences/shared_preferences.dart';

import '../../../functions/logger_func.dart';

class UserShared {
  static const String initialUser = 'initial';

  static Future<void> saveInitialUser() async {
    clog('SET USER HAS BEEN OPENED THE APP. SKIPPED ONBOARDING');
    await SharedPreferences.getInstance().then((prefs) => prefs.setBool(initialUser, true));
  }

  static Future<bool?> getInitialUser() async {
    return await SharedPreferences.getInstance().then((prefs) => prefs.getBool(initialUser));
  }
}