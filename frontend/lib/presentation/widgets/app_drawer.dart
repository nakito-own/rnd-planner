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
    // Detect the current route
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    
    // List of routes for comparison (using named routes)
    final isMainPage = currentRoute == '/' || currentRoute.isEmpty;
    final isDashboardsPage = currentRoute == '/dashboards';
    final isShiftsPage = currentRoute == '/shifts';
    final isTablesPage = currentRoute == '/tables';
    final isCrewsPage = currentRoute == '/crews';
    final isRobotsPage = currentRoute == '/robots';
    final isTransportsPage = currentRoute == '/transports';
    final isTgScenariosPage = currentRoute == '/tg_scenarios';
    
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
            isActive: isMainPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                  settings: const RouteSettings(name: '/'),
                ),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.chart_bar_alt_fill,
            title: 'Dashboards',
            isActive: isDashboardsPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardsPage(),
                  settings: const RouteSettings(name: '/dashboards'),
                ),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.time_solid,
            title: 'Shifts',
            isActive: isShiftsPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShiftsPage(),
                  settings: const RouteSettings(name: '/shifts'),
                ),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.table_fill,
            title: 'Tables',
            isActive: isTablesPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TablesPage(),
                  settings: const RouteSettings(name: '/tables'),
                ),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.group_solid,
            title: 'Crews',
            isActive: isCrewsPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CrewsPage(),
                  settings: const RouteSettings(name: '/crews'),
                ),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.square_stack_3d_up,
            title: 'Robots',
            pngIcon: 'assets/images/robot_icon.png',
            isActive: isRobotsPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RobotsPage(),
                  settings: const RouteSettings(name: '/robots'),
                ),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.car,
            title: 'Transports',
            isActive: isTransportsPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransportsPage(),
                  settings: const RouteSettings(name: '/transports'),
                ),
              );
            },
          ),
          _buildDrawerButton(
            context,
            icon: CupertinoIcons.chat_bubble_2_fill,
            title: 'TG Scenarios',
            isActive: isTgScenariosPage,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TgScenariosPage(),
                  settings: const RouteSettings(name: '/tg_scenarios'),
                ),
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
    bool isActive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final surfaceVariant = colorScheme.surfaceVariant;
    
    // Get theme colors
    final primaryColor = colorScheme.primary;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        elevation: isActive ? 2 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isActive 
                ? Border.all(color: primaryColor, width: 2)
                : null,
          ),
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
                            isActive ? primaryColor : textColor,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            pngIcon,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                icon,
                                color: isActive ? primaryColor : textColor,
                                size: 24,
                              );
                            },
                          ),
                        )
                      : Icon(
                          icon,
                          color: isActive ? primaryColor : textColor,
                          size: 24,
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: ThemeService.bodyStyle.copyWith(
                        color: isActive ? primaryColor : textColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: isActive 
                        ? primaryColor 
                        : colorScheme.outline,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
