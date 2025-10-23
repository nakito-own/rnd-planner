import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../pages/main_page.dart';
import '../pages/dashboards_page.dart';
import '../pages/shifts_page.dart';
import '../pages/tables_page.dart';
import '../pages/crews_page.dart';
import '../pages/robots_page.dart';
import '../pages/transports_page.dart';
import '../pages/tg_scenarios_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 60),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.house_fill,
            title: 'Main page',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.chart_bar_alt_fill,
            title: 'Dashboards',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardsPage()),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.time_solid,
            title: 'Shifts',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShiftsPage()),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.table_fill,
            title: 'Tables',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TablesPage()),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.group_solid,
            title: 'Crews',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CrewsPage()),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.square_stack_3d_up,
            title: 'Robots',
            pngIcon: 'assets/images/robot_icon.png',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RobotsPage()),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.car,
            title: 'Transports',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TransportsPage()),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.chat_bubble_2_fill,
            title: 'TG Scenarios',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TgScenariosPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? pngIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final surfaceVariant = colorScheme.surfaceVariant;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                pngIcon != null
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          pngIcon,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              icon,
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : Icon(
                        icon,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                        size: 24,
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: ThemeService.bodyStyle.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.black.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
