import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/robot_model.dart';
import '../../data/models/transport_model.dart';
import '../../data/models/task_model.dart';

class TaskFormWidget extends StatefulWidget {
  final int shiftId;
  final Function(Task) onTaskCreated;

  const TaskFormWidget({
    super.key,
    required this.shiftId,
    required this.onTaskCreated,
  });

  @override
  State<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _timeStartController = TextEditingController();
  final _timeEndController = TextEditingController();
  final _ticketsController = TextEditingController();

  TimeOfDay? _selectedTimeStart;
  TimeOfDay? _selectedTimeEnd;
  Employee? _selectedEmployee;
  Robot? _selectedRobot;
  Transport? _selectedTransport;
  TaskType _selectedTaskType = TaskType.route;
  Map<String, dynamic>? _geojsonData;
  final List<String> _tickets = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Employee> _employees = [];
  List<Robot> _robots = [];
  List<Transport> _transports = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _selectedTimeStart = const TimeOfDay(hour: 9, minute: 0);
    _selectedTimeEnd = const TimeOfDay(hour: 21, minute: 0);
    _updateControllers();
  }

  @override
  void dispose() {
    _timeStartController.dispose();
    _timeEndController.dispose();
    _ticketsController.dispose();
    super.dispose();
  }

  void _updateControllers() {
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final employees = await ApiService.getEmployees();
      final robots = await ApiService.getRobots();
      final transports = await ApiService.getTransports();

      setState(() {
        _employees = employees;
        _robots = robots;
        _transports = transports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: $e';
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

  void _addTicket() {
    final ticket = _ticketsController.text.trim();
    if (ticket.isNotEmpty && !_tickets.contains(ticket)) {
      setState(() {
        _tickets.add(ticket);
        _ticketsController.clear();
      });
    }
  }

  void _removeTicket(String ticket) {
    setState(() {
      _tickets.remove(ticket);
    });
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.route:
        return CupertinoIcons.arrow_swap;
      case TaskType.carpet:
        return CupertinoIcons.map;
      case TaskType.demo:
        return CupertinoIcons.bolt_fill;
      case TaskType.custom:
        return CupertinoIcons.gear;
    }
  }

  String _getTaskTypeDisplayName(TaskType type) {
    switch (type) {
      case TaskType.route:
        return 'Route';
      case TaskType.carpet:
        return 'Carpet';
      case TaskType.demo:
        return 'Demo';
      case TaskType.custom:
        return 'Custom';
    }
  }

  Future<void> _selectGeojsonFile() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _GeojsonInputDialog(),
    );

    if (result != null) {
      setState(() {
        _geojsonData = result;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEmployee == null) {
      setState(() {
        _errorMessage = 'Select executor';
      });
      return;
    }

    if (_selectedTimeStart == null || _selectedTimeEnd == null) {
      setState(() {
        _errorMessage = 'Fill in the start and end time';
      });
      return;
    }

    if (_tickets.isEmpty) {
      setState(() {
        _errorMessage = 'Add at least one ticket';
      });
      return;
    }

    if (_selectedTaskType == TaskType.route && _geojsonData == null) {
      setState(() {
        _errorMessage = 'For the "Route" type, you need to load GeoJSON';
      });
      return;
    }

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTimeStart!.hour,
      _selectedTimeStart!.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTimeEnd!.hour,
      _selectedTimeEnd!.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      setState(() {
        _errorMessage = 'The end time must be greater than the start time';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskData = {
        'shift_id': widget.shiftId,
        'executor': _selectedEmployee!.id,
        'robot_name': _selectedRobot?.id,
        'transport_id': _selectedTransport?.id,
        'time_start': startDateTime.toIso8601String(),
        'time_end': endDateTime.toIso8601String(),
        'type': _selectedTaskType.name,
        'geojson': _geojsonData,
        'tickets': _tickets,
      };

      final task = await ApiService.createTask(taskData);

      widget.onTaskCreated(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error creating task: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create task',
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
                      CupertinoIcons.add_circled_solid,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create new task',
                      style: ThemeService.subheadingStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the data for a new task',
                      style: ThemeService.bodyStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildEmployeeField(),

              const SizedBox(height: 16),

              _buildRobotField(),

              const SizedBox(height: 16),

              _buildTransportField(),

              const SizedBox(height: 16),

              _buildTaskTypeField(),

              const SizedBox(height: 16),

              if (_selectedTaskType == TaskType.route) ...[
                _buildGeojsonField(),
                const SizedBox(height: 16),
              ],

              _buildTimeStartField(),
              const SizedBox(height: 16),
              _buildTimeEndField(),

              const SizedBox(height: 16),

              _buildTicketsField(),

              const SizedBox(height: 24),

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
                      onPressed: _isLoading ? null : _saveTask,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Create'),
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

  Widget _buildEmployeeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Executor *',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Employee>(
          value: _selectedEmployee,
          decoration: InputDecoration(
            hintText: 'Select executor',
            prefixIcon: const Icon(CupertinoIcons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: _employees.map((employee) {
            return DropdownMenuItem<Employee>(
              value: employee,
              child: Text(employee.fullName),
            );
          }).toList(),
          onChanged: (Employee? value) {
            setState(() {
              _selectedEmployee = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Select executor';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRobotField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Robot',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Robot>(
          value: _selectedRobot,
          decoration: InputDecoration(
            hintText: 'Select robot (optional)',
            prefixIcon: const Icon(CupertinoIcons.gear),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: [
            const DropdownMenuItem<Robot>(
              value: null,
              child: Text('Not selected'),
            ),
            ..._robots.map((robot) {
              return DropdownMenuItem<Robot>(
                value: robot,
                child: Text(robot.displayName),
              );
            }).toList(),
          ],
          onChanged: (Robot? value) {
            setState(() {
              _selectedRobot = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTransportField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transport',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Transport>(
          value: _selectedTransport,
          decoration: InputDecoration(
            hintText: 'Select transport (optional)',
            prefixIcon: const Icon(CupertinoIcons.car),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: [
            const DropdownMenuItem<Transport>(
              value: null,
              child: Text('Not selected'),
            ),
            ..._transports.map((transport) {
              return DropdownMenuItem<Transport>(
                value: transport,
                child: Text(transport.displayName),
              );
            }).toList(),
          ],
          onChanged: (Transport? value) {
            setState(() {
              _selectedTransport = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTaskTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task type',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskType>(
          value: _selectedTaskType,
          decoration: InputDecoration(
            prefixIcon: const Icon(CupertinoIcons.tag),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: TaskType.values.map((type) {
            return DropdownMenuItem<TaskType>(
              value: type,
              child: Row(
                children: [
                  Icon(_getTaskTypeIcon(type), size: 16),
                  const SizedBox(width: 8),
                  Text(_getTaskTypeDisplayName(type)),
                ],
              ),
            );
          }).toList(),
          onChanged: (TaskType? value) {
            setState(() {
              _selectedTaskType = value!;
              if (value != TaskType.route) {
                _geojsonData = null;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildGeojsonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GeoJSON *',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.map, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _geojsonData != null ? 'GeoJSON loaded' : 'Click to load GeoJSON',
                  style: ThemeService.bodyStyle,
                ),
              ),
              TextButton(
                onPressed: _selectGeojsonFile,
                    child: const Text('Load'),
              ),
            ],
          ),
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
              return 'Enter start time';
            }
            if (!_isValidTimeFormat(value)) {
              return 'Enter time in format HH:MM';
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
              return 'Enter end time';
            }
            if (!_isValidTimeFormat(value)) {
              return 'Enter time in format HH:MM';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTicketsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tickets *',
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ticketsController,
                decoration: InputDecoration(
                  hintText: 'Enter ticket',
                  prefixIcon: const Icon(CupertinoIcons.ticket),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onFieldSubmitted: (_) => _addTicket(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addTicket,
              child: const Text('Add'),
            ),
          ],
        ),
        if (_tickets.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tickets.map((ticket) {
              return Chip(
                label: Text(ticket),
                deleteIcon: const Icon(CupertinoIcons.xmark, size: 16),
                onDeleted: () => _removeTicket(ticket),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _GeojsonInputDialog extends StatefulWidget {
  @override
  _GeojsonInputDialogState createState() => _GeojsonInputDialogState();
}

class _GeojsonInputDialogState extends State<_GeojsonInputDialog> {
  final _controller = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadSampleGeojson() {
    setState(() {
      _controller.text = '''{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "name": "Sample Route"
      },
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [37.6173, 55.7558],
          [37.6200, 55.7600],
          [37.6250, 55.7650]
        ]
      }
    }
  ]
}''';
      _errorMessage = null;
    });
  }

  void _validateAndSubmit() {
    try {
      final jsonData = json.decode(_controller.text);
      if (jsonData is Map<String, dynamic>) {
        Navigator.pop(context, jsonData);
      } else {
        setState(() {
            _errorMessage = 'GeoJSON must be an object';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid JSON format: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Input GeoJSON'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter GeoJSON data for the route:',
              style: ThemeService.bodyStyle,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Insert GeoJSON data...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: _loadSampleGeojson,
                  child: const Text('Load example'),
                ),
                const Spacer(),
                if (_errorMessage != null)
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: ThemeService.bodyStyle.copyWith(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: const Text('Load'),
        ),
      ],
    );
  }
}
