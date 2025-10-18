import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../widgets/app_drawer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final List<String> _features;
  
  @override
  void initState() {
    super.initState();
    _features = [
      'Планирование исследований',
      'Управление проектами',
      'Отслеживание прогресса',
      'Аналитика и отчеты',
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'R&D Planner',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(ThemeService.getThemeIcon()),
            onPressed: () async {
              await ThemeService.toggleTheme();
            },
            tooltip: 'Переключить тему (${ThemeService.getThemeName()})',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.lab_flask,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Добро пожаловать в R&D Planner',
                    style: ThemeService.displayStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Приложение находится в разработке',
                    style: ThemeService.bodyStyle.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Функциональность',
              style: ThemeService.subheadingStyle,
            ),
            const SizedBox(height: 10),
            _buildFeatureList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureList() {
    return Column(
      children: _features.map((feature) => _FeatureItem(
        text: feature,
        key: ValueKey(feature),
      )).toList(),
    );
  }

}

class _FeatureItem extends StatelessWidget {
  final String text;
  
  const _FeatureItem({
    required this.text,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: ThemeService.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
}
