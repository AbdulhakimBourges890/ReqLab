import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Holds theme mode + accent color and saves them permanently.
class SettingsController extends ChangeNotifier {
  static const _kMode = 'theme_mode';
  static const _kAccent = 'accent_index';

  late final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  int _accentIndex = 0;

  ThemeMode get themeMode => _themeMode;
  int get accentIndex => _accentIndex;
  Color get accent => accentOptions[_accentIndex].color;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString(_kMode);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    _accentIndex = (_prefs.getInt(_kAccent) ?? 0).clamp(
      0,
      accentOptions.length - 1,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_kMode, mode.name);
  }

  Future<void> setAccent(int index) async {
    _accentIndex = index;
    notifyListeners();
    await _prefs.setInt(_kAccent, index);
  }
}
