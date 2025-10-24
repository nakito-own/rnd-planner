import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/shift_model.dart';

class ShiftForm extends StatefulWidget {
  final Shift? shift; // null для создания нового, не null для редактирования
  final VoidCallback? onSaved;
  final bool showAppBar;
  final DateTime? initialDate; // Начальная дата для создания новой смены

  const ShiftForm({
    super.key,
    this.shift,
    this.onSaved,
    this.showAppBar = true,
    this.initialDate,
  });

  @override
  State<ShiftForm> createState() => _ShiftFormState();
}

class _ShiftFormState extends State<ShiftForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeStartController = TextEditingController();
  final _timeEndController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeStart;
  TimeOfDay? _selectedTimeEnd;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.shift != null) {
      _selectedDate = widget.shift!.date;
      _selectedTimeStart = TimeOfDay(hour: widget.shift!.timeStart.hour, minute: widget.shift!.timeStart.minute);
      _selectedTimeEnd = TimeOfDay(hour: widget.shift!.timeEnd.hour, minute: widget.shift!.timeEnd.minute);
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTimeStart = const TimeOfDay(hour: 9, minute: 0);
      _selectedTimeEnd = const TimeOfDay(hour: 21, minute: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_dateController.text.isEmpty || _timeStartController.text.isEmpty || _timeEndController.text.isEmpty) {
      _updateControllers();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeStartController.dispose();
    _timeEndController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    if (_selectedDate != null) {
      _dateController.text = _formatDate(_selectedDate!);
    }
    if (_selectedTimeStart != null) {
      _timeStartController.text = _formatTime(_selectedTimeStart!);
    }
    if (_selectedTimeEnd != null) {
      _timeEndController.text = _formatTime(_selectedTimeEnd!);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _updateControllers();
      });
    }
  }

  void _onTimeStartChanged(String value) {
    if (_isValidTimeFormat(value)) {
      final parts = value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      _selectedTimeStart = TimeOfDay(hour: hour, minute: minute);
    } else {
      _selectedTimeStart = null;
    }
  }

  void _onTimeEndChanged(String value) {
    if (_isValidTimeFormat(value)) {
      final parts = value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      _selectedTimeEnd = TimeOfDay(hour: hour, minute: minute);
    } else {
      _selectedTimeEnd = null;
    }
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!regex.hasMatch(time)) {
      return false;
    }
    
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  Future<void> _saveShift() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTimeStart == null || _selectedTimeEnd == null) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTimeStart!.hour,
      _selectedTimeStart!.minute,
    );
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTimeEnd!.hour,
      _selectedTimeEnd!.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      setState(() {
        _errorMessage = 'End time must be greater than start time';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shiftData = {
        'date': _selectedDate!.toIso8601String(),
        'time_start': startDateTime.toIso8601String(),
        'time_end': endDateTime.toIso8601String(),
      };

      if (widget.shift != null) {
        await ApiService.updateShift(widget.shift!.id, shiftData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift successfully updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ApiService.createShift(shiftData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift successfully created'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        if (widget.showAppBar) {
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context);
        }
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error saving: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.shift != null;
    
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(
          isEditing ? 'Edit shift' : 'Create shift',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Shift information'),
                    _buildDateField(),
                    _buildTimeStartField(),
                    _buildTimeEndField(),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: ThemeService.bodyStyle.copyWith(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveShift,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              isEditing ? 'Save' : 'Create',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: ThemeService.subheadingStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Shift date *',
              prefixIcon: const Icon(CupertinoIcons.calendar),
              suffixIcon: const Icon(CupertinoIcons.chevron_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            ),
            onTap: _selectDate,
            validator: (value) {
              if (_selectedDate == null) {
                return 'Please select a date';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStartField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _timeStartController,
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              labelText: 'Start time *',
              hintText: 'HH:MM (e.g., 09:00)',
              prefixIcon: const Icon(CupertinoIcons.clock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            ),
            onChanged: _onTimeStartChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter start time';
              }
              if (!_isValidTimeFormat(value)) {
                return 'Please enter time in HH:MM format';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEndField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _timeEndController,
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              labelText: 'End time *',
              hintText: 'HH:MM (e.g., 21:00)',
              prefixIcon: const Icon(CupertinoIcons.clock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            ),
            onChanged: _onTimeEndChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter end time';
              }
              if (!_isValidTimeFormat(value)) {
                return 'Please enter time in HH:MM format';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

