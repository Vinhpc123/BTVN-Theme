import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

enum AppTheme { light, dark, pink }

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.light) {
    loadTheme();
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('appTheme') ?? 0;
    state = AppTheme.values[index];
  }

  void setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('appTheme', theme.index);
    state = theme;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  ThemeData getPinkTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.pink,
      scaffoldBackgroundColor: Colors.pink.shade50,
      appBarTheme: AppBarTheme(backgroundColor: Colors.pink.shade200),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme Demo',
      theme: appTheme == AppTheme.pink ? getPinkTheme() : ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: appTheme == AppTheme.dark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Setting")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Choosing the right theme sets the tone and personality of your app",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeButton(
                  color: Colors.white,
                  onTap: () => themeNotifier.setTheme(AppTheme.light),
                ),
                ThemeButton(
                  color: Colors.black,
                  onTap: () => themeNotifier.setTheme(AppTheme.dark),
                ),
                ThemeButton(
                  color: Colors.pink.shade200,
                  onTap: () => themeNotifier.setTheme(AppTheme.pink),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DetailScreen(),
                  ),
                );
              },
              child: const Text("Apply"),
            )
          ],
        ),
      ),
    );
  }
}

class ThemeButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const ThemeButton({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final themeText = theme.name.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text("Theme-Applied Detail")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              themeText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Choosing the right theme sets the tone and personality of your app, enhancing user experience and reinforcing your brand identity",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            )
          ],
        ),
      ),
    );
  }
}