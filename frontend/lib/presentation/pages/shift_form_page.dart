import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/task_model.dart';
import '../widgets/task_form_widget.dart';

class ShiftFormPage extends StatefulWidget {
  final Shift? shift;

  const ShiftFormPage({super.key, this.shift});

  @override
  State<ShiftFormPage> createState() => _ShiftFormPageState();
}

class _ShiftFormPageState extends State<ShiftFormPage> {
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
      
      _selectedDate = DateTime.now();
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
        Navigator.pop(context, true); 
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error saving: $e';
      });
    }
  }

  Future<void> _createTask() async {
    if (widget.shift == null) return;

    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormWidget(
          shiftId: widget.shift!.id,
          onTaskCreated: (task) {
           
          },
        ),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task successfully created'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.shift != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit shift' : 'Create shift',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.time_solid,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing ? 'Edit shift' : 'Create new shift',
                      style: ThemeService.subheadingStyle.copyWith(
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing 
                        ? 'Change shift parameters'
                        : 'Fill in the data for a new shift',
                      style: ThemeService.bodyStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildDateField(),

              const SizedBox(height: 16),

              _buildTimeStartField(),

              const SizedBox(height: 16),

              _buildTimeEndField(),

              const SizedBox(height: 24),

              if (widget.shift != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.add_circled_solid,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Task management',
                            style: ThemeService.subheadingStyle.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create tasks for this shift',
                        style: ThemeService.bodyStyle.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createTask,
                          icon: const Icon(CupertinoIcons.add),
                          label: const Text('Create task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (_errorMessage != null)
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

              if (_errorMessage != null) const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveShift,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Save' : 'Create'),
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift date',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select date',
            prefixIcon: const Icon(CupertinoIcons.calendar),
            suffixIcon: const Icon(CupertinoIcons.chevron_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
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
    );
  }

  Widget _buildTimeStartField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start time',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _timeStartController,
          keyboardType: TextInputType.numberWithOptions(decimal: false),
          decoration: InputDecoration(
            hintText: 'HH:MM (e.g., 09:00)',
            prefixIcon: const Icon(CupertinoIcons.clock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
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
    );
  }

  Widget _buildTimeEndField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'End time',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _timeEndController,
          keyboardType: TextInputType.numberWithOptions(decimal: false),
          decoration: InputDecoration(
            hintText: 'HH:MM (e.g., 21:00)',
            prefixIcon: const Icon(CupertinoIcons.clock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
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
    );
  }
}
