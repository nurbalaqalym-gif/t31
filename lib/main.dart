import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeModel = ThemeModel();
  await themeModel.load();

  runApp(ChangeNotifierProvider.value(value: themeModel, child: const MyApp()));
}

// Таңдауға болатын түстер
const List<Color> kSeeds = [
  Colors.teal,
  Colors.blue,
  Colors.deepPurple,
  Colors.pink,
  Colors.orange,
  Colors.green,
];

// Тақырып баптаулары: 10-сабақтағы ChangeNotifier + 8-сабақтағы сақтау
class ThemeModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  int _seedIndex = 0;

  ThemeMode get mode => _mode;
  int get seedIndex => _seedIndex;
  Color get seed => kSeeds[_seedIndex];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('themeMode') ?? 0;
    final seedIndex = prefs.getInt('seedIndex') ?? 0;

    // Сақталған сан тізімнен асып кетпеуін тексереміз
    if (modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
      _mode = ThemeMode.values[modeIndex];
    }
    if (seedIndex >= 0 && seedIndex < kSeeds.length) {
      _seedIndex = seedIndex;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setSeed(int index) async {
    _seedIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedIndex', index);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Тақырып өзгергенде бүкіл MaterialApp қайта салынады
    return Consumer<ThemeModel>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'Title',
          debugShowCheckedModeBanner: false,
          themeMode: theme.mode,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: theme.seed),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: theme.seed,
          ),
          home: const SettingsPage(),
        );
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Mode', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.phone_android),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {theme.mode},
            onSelectionChanged: (selection) {
              context.read<ThemeModel>().setMode(selection.first);
            },
          ),
          const SizedBox(height: 24),
          const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < kSeeds.length; i++)
                GestureDetector(
                  onTap: () => context.read<ThemeModel>().setSeed(i),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: kSeeds[i],
                    child: theme.seedIndex == i
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Color is for everything'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Button'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Contour'),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (_) {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
