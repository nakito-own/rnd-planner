import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/shift_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shift_card.dart';
import '../widgets/shift_form.dart';
import '../widgets/side_sheet.dart';

class ShiftsPage extends StatefulWidget {
  const ShiftsPage({super.key});

  @override
  State<ShiftsPage> createState() => _ShiftsPageState();
}

class _ShiftsPageState extends State<ShiftsPage> {
  Shift? _currentShift;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  
  // Cache for shifts
  final Map<String, Shift?> _shiftCache = {};

  @override
  void initState() {
    super.initState();
    _loadShiftsWithCache(_selectedDate);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Future<void> _loadShiftsWithCache(DateTime date) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedDate = date;
    });

    try {
      // First check server connection
      final isConnected = await ApiService.testConnection();
      if (!isConnected) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Unable to connect to server. Make sure the backend is running on http://localhost:8000';
          });
        }
        return;
      }

      // Load current date and cache
      final currentShift = await ApiService.getShiftByDate(date);
      _shiftCache[_dateKey(date)] = currentShift;
      
      // Preload adjacent days in background
      _preloadAdjacentShifts(date);

      if (mounted) {
        setState(() {
          _currentShift = currentShift;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading shift: $e';
        });
      }
    }
  }

  Future<void> _preloadAdjacentShifts(DateTime date) async {
    final yesterday = date.subtract(const Duration(days: 1));
    final tomorrow = date.add(const Duration(days: 1));
    
    final yesterdayKey = _dateKey(yesterday);
    final tomorrowKey = _dateKey(tomorrow);
    
    // Load only if not cached
    if (!_shiftCache.containsKey(yesterdayKey)) {
      try {
        final shift = await ApiService.getShiftByDate(yesterday);
        _shiftCache[yesterdayKey] = shift;
      } catch (e) {
        // Silent fail for preloading
      }
    }
    
    if (!_shiftCache.containsKey(tomorrowKey)) {
      try {
        final shift = await ApiService.getShiftByDate(tomorrow);
        _shiftCache[tomorrowKey] = shift;
      } catch (e) {
        // Silent fail for preloading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shifts',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Create shift',
            child: IconButton(
              icon: const Icon(CupertinoIcons.add),
              onPressed: _createShift,
            ),
          ),
          Tooltip(
            message: 'Select date',
            child: IconButton(
              icon: const Icon(CupertinoIcons.calendar),
              onPressed: _selectDate,
            ),
          ),
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: () => _loadShiftsWithCache(_selectedDate),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? Column(
              children: [
                _buildDateHeader(),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            )
          : Column(
            
              children: [
                _buildDateHeader(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: _errorMessage != null
                        ? _buildErrorState()
                        : _currentShift == null
                            ? _buildEmptyState()
                            : _buildShiftView(),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            datePickerTheme: DatePickerThemeData(
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                return null;
              }),
              todayForegroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary,
              ),
              todayBackgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
              headerHeadlineStyle: ThemeService.headingStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              headerHelpStyle: ThemeService.bodyStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              weekdayStyle: ThemeService.captionStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              dayStyle: ThemeService.bodyStyle,
              headerForegroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      _loadShiftsWithCache(picked);
    }
  }

  void _navigateToYesterday() {
    final yesterday = _selectedDate.subtract(const Duration(days: 1));
    final yesterdayKey = _dateKey(yesterday);
    
    // Check cache first
    if (_shiftCache.containsKey(yesterdayKey)) {
      setState(() {
        _selectedDate = yesterday;
        _currentShift = _shiftCache[yesterdayKey];
      });
      // Preload new adjacent days
      _preloadAdjacentShifts(yesterday);
    } else {
      _loadShiftsWithCache(yesterday);
    }
  }

  void _navigateToTomorrow() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    final tomorrowKey = _dateKey(tomorrow);
    
    // Check cache first
    if (_shiftCache.containsKey(tomorrowKey)) {
      setState(() {
        _selectedDate = tomorrow;
        _currentShift = _shiftCache[tomorrowKey];
      });
      // Preload new adjacent days
      _preloadAdjacentShifts(tomorrow);
    } else {
      _loadShiftsWithCache(tomorrow);
    }
  }


  Widget _buildDateHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.calendar,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift on ${_formatDate(_selectedDate)}',
                  style: ThemeService.subheadingStyle.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  _currentShift != null
                      ? '${_currentShift!.tasks.length} tasks'
                      : 'No shift',
                  style: ThemeService.captionStyle.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Yesterday',
            child: IconButton(
              onPressed: _navigateToYesterday,
              icon: const Icon(CupertinoIcons.chevron_left),
            ),
          ),
          Tooltip(
            message: 'Tomorrow',
            child: IconButton(
              onPressed: _navigateToTomorrow,
              icon: const Icon(CupertinoIcons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: ValueKey('empty_${_dateKey(_selectedDate)}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.time,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'No shifts on ${_formatDate(_selectedDate)}',
            style: ThemeService.displayStyle.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Select another date or create a shift',
            style: ThemeService.bodyStyle.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(CupertinoIcons.calendar),
                label: const Text('Select date'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _createShift,
                icon: const Icon(CupertinoIcons.add),
                label: const Text('Create shift'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      key: ValueKey('error_${_dateKey(_selectedDate)}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            'Error loading',
            style: ThemeService.displayStyle.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Unknown error',
            style: ThemeService.bodyStyle.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _loadShiftsWithCache(_selectedDate),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftView() {
    return RefreshIndicator(
      key: ValueKey('shift_${_dateKey(_selectedDate)}'),
      onRefresh: () async {
        _loadShiftsWithCache(_selectedDate);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 16),
        child: ShiftCard(
          shift: _currentShift!,
          onTap: () {
            // TODO: Add navigation to detailed shift page
          },
          onEdit: () => _editShift(_currentShift!),
          onTaskUpdated: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              _loadShiftsWithCache(_selectedDate);
            }
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _createShift() async {
    showAppSideSheet(
      context: context,
      width: 520,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      barrierColor: Colors.black54,
      child: ShiftForm(
        initialDate: _selectedDate,
        onSaved: () {
          _loadShiftsWithCache(_selectedDate);
        },
        showAppBar: false,
      ),
    );
  }

  Future<void> _editShift(Shift shift) async {
    showAppSideSheet(
      context: context,
      width: 520,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      barrierColor: Colors.black54,
      child: ShiftForm(
        shift: shift,
        onSaved: () {
          _loadShiftsWithCache(_selectedDate);
        },
        showAppBar: false,
      ),
    );
  }

}
