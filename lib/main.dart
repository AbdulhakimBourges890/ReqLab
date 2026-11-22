import 'package:material_ui/material_ui.dart';

import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tester_screen.dart';
import 'services/settings_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsController();
  await settings.load();

  runApp(ReqLabApp(settings: settings));
}

class ReqLabApp extends StatelessWidget {
  const ReqLabApp({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'ReqLab',
        debugShowCheckedModeBanner: false,
        themeMode:
            ThemeMode.values.byName(settings.themeMode.name) as ThemeMode?,
        theme: AppTheme.build(Brightness.light, settings.accent) as ThemeData?,
        darkTheme:
            AppTheme.build(Brightness.dark, settings.accent) as ThemeData?,
        home: Shell(settings: settings),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            const TesterScreen(),
            const AboutScreen(),
            SettingsScreen(settings: widget.settings),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Request',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
