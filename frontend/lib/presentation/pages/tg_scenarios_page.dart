import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../widgets/app_drawer.dart';

class TgScenariosPage extends StatelessWidget {
  const TgScenariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TG Scenarios',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.chat_bubble_2,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'TG Scenarios',
              style: ThemeService.displayStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Страница находится в разработке',
              style: ThemeService.bodyStyle.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
