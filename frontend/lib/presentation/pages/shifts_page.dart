import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/shift_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shift_card.dart';
import 'shift_form_page.dart';

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

  @override
  void initState() {
    super.initState();
    _loadShiftForDate(_selectedDate);
  }

  Future<void> _loadShiftForDate(DateTime date) async {
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

      final shift = await ApiService.getShiftByDate(date);
      if (mounted) {
        setState(() {
          _currentShift = shift;
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
              onPressed: () => _loadShiftForDate(_selectedDate),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _currentShift == null
                  ? _buildEmptyState()
                  : _buildShiftView(),
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      _loadShiftForDate(picked);
    }
  }


  Widget _buildEmptyState() {
    return Center(
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
            onPressed: () => _loadShiftForDate(_selectedDate),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftView() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadShiftForDate(_selectedDate);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
                            '${_currentShift!.tasks.length} tasks',
                          style: ThemeService.captionStyle.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Change date',
                    child: IconButton(
                      onPressed: _selectDate,
                      icon: const Icon(CupertinoIcons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),
            ShiftCard(
              shift: _currentShift!,
              onTap: () {
                // TODO: Add navigation to detailed shift page
              },
              onEdit: () => _editShift(_currentShift!),
              onTaskUpdated: () async {
                // Add a small delay to ensure the task is fully created on the server
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  _loadShiftForDate(_selectedDate);
                }
              },
            ),
          ],
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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const ShiftFormPage(),
      ),
    );
    
    if (result == true) {
      _loadShiftForDate(_selectedDate);
    }
  }

  Future<void> _editShift(Shift shift) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftFormPage(shift: shift),
      ),
    );
    
    if (result == true) {
      _loadShiftForDate(_selectedDate);
    }
  }

}
