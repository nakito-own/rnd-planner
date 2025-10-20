import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/robot_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/robot_form.dart';

class RobotsPage extends StatefulWidget {
  const RobotsPage({super.key});

  @override
  State<RobotsPage> createState() => _RobotsPageState();
}

class _RobotsPageState extends State<RobotsPage> {
  List<Robot> _robots = [];
  List<Robot> _allRobots = [];
  bool _isLoading = true;
  String? _error;
  
  int? _selectedSeries;
  bool _blockersFilter = false;
  
  // Поиск по имени
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  
  List<int> _availableSeries = [];

  @override
  void initState() {
    super.initState();
    _loadRobots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRobots() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final robots = await ApiService.getRobots();
      setState(() {
        _allRobots = robots;
        _robots = robots;
        
        _availableSeries = robots
            .map((r) => r.series)
            .toSet()
            .toList()
          ..sort();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _robots = _allRobots.where((robot) {
        // Поиск по имени
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          final robotName = robot.displayName.toLowerCase();
          if (!robotName.contains(searchText)) {
            return false;
          }
        }

        if (_selectedSeries != null && robot.series != _selectedSeries) {
          return false;
        }

        if (_blockersFilter && !robot.hasBlockers) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSeries = null;
      _blockersFilter = false;
      _searchController.clear();
      _isSearchVisible = false;
      _robots = _allRobots;
    });
  }

  void _openRobotForm({Robot? robot}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RobotForm(
          robot: robot,
          onSaved: _loadRobots,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Robots',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            onPressed: _openRobotForm,
            tooltip: 'Add new robot',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: _loadRobots,
            tooltip: 'Update data',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading robots...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: ThemeService.subheadingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: ThemeService.bodyStyle.copyWith(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRobots,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allRobots.isEmpty) {
      return Column(
        children: [
          _buildFiltersPanel(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.square_stack_3d_up,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total robots: 0',
                  style: ThemeService.subheadingStyle,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.square_stack_3d_up,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No robots in database',
                    style: ThemeService.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first robot to get started',
                    style: ThemeService.bodyStyle.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_robots.isEmpty) {
      return Column(
        children: [
          _buildFiltersPanel(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.square_stack_3d_up,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total robots: 0',
                  style: ThemeService.subheadingStyle,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_allRobots.length} total)',
                  style: ThemeService.bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.square_stack_3d_up,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No robots match current filters',
                    style: ThemeService.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or clear them to see all robots',
                    style: ThemeService.bodyStyle.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(CupertinoIcons.clear),
                    label: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFiltersPanel(),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.square_stack_3d_up,
                size: 24,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                'Total robots: ${_robots.length}',
                style: ThemeService.subheadingStyle,
              ),
              if (_robots.length != _allRobots.length) ...[
                const SizedBox(width: 8),
                Text(
                  '(${_allRobots.length} total)',
                  style: ThemeService.bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _robots.length,
            itemBuilder: (context, index) {
              final robot = _robots[index];
              return _buildRobotCard(robot);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRobotCard(Robot robot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/robot_avatar.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to CircleAvatar with text if image is missing
                        return CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            robot.name.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        robot.displayName,
                        style: ThemeService.subheadingStyle,
                      ),
            Text(
                        robot.seriesInfo,
                        style: ThemeService.bodyStyle.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.pencil_circle),
                  onPressed: () => _openRobotForm(robot: robot),
                  tooltip: 'Edit robot',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (robot.hasBlockers)
                  _buildBadge('Has Blockers', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDropdownFilter(
                        'Series',
                        _selectedSeries?.toString(),
                        _availableSeries.map((s) => s.toString()).toList(),
                        (value) {
                          setState(() {
                            _selectedSeries = value != null ? int.tryParse(value) : null;
                          });
                          _applyFilters();
                        },
                        isDark,
                      ),
                      const SizedBox(width: 16),
                      
                      _buildCheckboxRow(isDark),
                    ],
                  ),
                ),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                        if (!_isSearchVisible) {
                          _searchController.clear();
                          _applyFilters();
                        }
                      });
                    },
                    icon: Icon(
                      _isSearchVisible ? CupertinoIcons.search_circle_fill : CupertinoIcons.search,
                      size: 14,
                      color: _isSearchVisible ? Colors.blue : Colors.grey[600],
                    ),
                    label: Text(
                      'Search',
                      style: TextStyle(
                        color: _isSearchVisible ? Colors.blue : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: Icon(
                      CupertinoIcons.clear, 
                      size: 14,
                      color: Colors.red[600],
                    ),
                    label: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Поле поиска по имени
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 60 : 0,
            child: _isSearchVisible ? _buildSearchField(isDark) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return Container(
      width: 150,
      child: DropdownButtonFormField<String?>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              'All $label',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
          ...options.map((option) => DropdownMenuItem<String?>(
            value: option,
            child: Text(
              option,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          )),
        ],
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        icon: Icon(
          CupertinoIcons.chevron_down,
          color: isDark ? Colors.white70 : Colors.black54,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(bool isDark) {
    return Row(
      children: [
        _buildCompactCheckbox(
          'Has Blockers',
          _blockersFilter,
          (value) {
            setState(() {
              _blockersFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
      ],
    );
  }

  Widget _buildCompactCheckbox(
    String label,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (newValue) => onChanged(newValue ?? false),
          activeColor: Colors.blue,
          checkColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by robot name...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: isDark ? Colors.white70 : Colors.black54,
            size: 18,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    CupertinoIcons.clear,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 16,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        onChanged: (value) {
          _applyFilters();
        },
      ),
    );
  }
}
