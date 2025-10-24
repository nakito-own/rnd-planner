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

class TaskForm extends StatefulWidget {
  final Task? task; 
  final int? shiftId; 
  final VoidCallback? onSaved;
  final bool showAppBar;

  const TaskForm({
    super.key,
    this.task,
    this.shiftId,
    this.onSaved,
    this.showAppBar = true,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
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
  List<Task> _shiftTasks = []; 

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _populateForm();
    } else {
      _selectedTimeStart = const TimeOfDay(hour: 9, minute: 0);
      _selectedTimeEnd = const TimeOfDay(hour: 21, minute: 0);
      _updateControllers();
    }
    _loadData();
  }

  void _populateForm() {
    final task = widget.task!;
    _selectedTimeStart = TimeOfDay(
      hour: task.timeStart.hour,
      minute: task.timeStart.minute,
    );
    _selectedTimeEnd = TimeOfDay(
      hour: task.timeEnd.hour,
      minute: task.timeEnd.minute,
    );
    _selectedTaskType = task.type;
    _geojsonData = task.geojson;
    _tickets.addAll(task.tickets);
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
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final employees = await ApiService.getEmployees();
      final robots = await ApiService.getRobots();
      final transports = await ApiService.getTransports();
      
      List<Task> shiftTasks = [];
      if (widget.task != null && widget.task!.shiftId != null) {
        shiftTasks = await ApiService.getTasksForShift(widget.task!.shiftId!);
      } else if (widget.shiftId != null) {
        shiftTasks = await ApiService.getTasksForShift(widget.shiftId!);
      }
      
      final targetShiftId = widget.task?.shiftId ?? widget.shiftId;
      if (targetShiftId != null) {
        shiftTasks = shiftTasks.where((task) => task.shiftId == targetShiftId).toList();
      }
      
      final taskIds = shiftTasks.map((task) => task.id).toList();
      final uniqueTaskIds = taskIds.toSet();
      if (taskIds.length != uniqueTaskIds.length) {
        final uniqueTasks = <Task>[];
        final seenIds = <int>{};
        for (final task in shiftTasks) {
          if (!seenIds.contains(task.id)) {
            uniqueTasks.add(task);
            seenIds.add(task.id);
          }
        }
        shiftTasks = uniqueTasks;
      }

      if (mounted) {
        Employee? selectedEmployee;
        Robot? selectedRobot;
        Transport? selectedTransport;
        
        if (widget.task != null) {
          if (widget.task!.executor != null) {
            try {
              selectedEmployee = employees.firstWhere(
                (e) => e.id == widget.task!.executor,
              );
            } catch (e) {
              selectedEmployee = employees.isNotEmpty ? employees.first : null;
            }
          }
          if (widget.task!.robotName != null) {
            try {
              selectedRobot = robots.firstWhere(
                (r) => r.id == widget.task!.robotName,
              );
            } catch (e) {
              selectedRobot = robots.isNotEmpty ? robots.first : null;
            }
          }
          if (widget.task!.transportId != null) {
            try {
              selectedTransport = transports.firstWhere(
                (t) => t.id == widget.task!.transportId,
              );
            } catch (e) {
              selectedTransport = transports.isNotEmpty ? transports.first : null;
            }
          }
        }
        
        setState(() {
          _employees = employees;
          _robots = robots;
          _transports = transports;
          _shiftTasks = shiftTasks;
          _selectedEmployee = selectedEmployee;
          _selectedRobot = selectedRobot;
          _selectedTransport = selectedTransport;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading data: $e';
        });
      }
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
    if (ticket.isEmpty) {
      return;
    }
    
    if (_tickets.contains(ticket)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This ticket is already added to this task'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final ticketsInShift = <String>{};
    for (final task in _shiftTasks) {
      if (widget.task == null || task.id != widget.task!.id) {
        ticketsInShift.addAll(task.tickets);
      }
    }
    
    if (ticketsInShift.contains(ticket)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This ticket is already used in another task in this shift'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _tickets.add(ticket);
      _ticketsController.clear();
    });
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
  List<Employee> _getAvailableEmployees() {
    // При редактировании задачи текущий исполнитель должен быть доступен
    int? currentTaskExecutorId;
    if (widget.task != null && widget.task!.executor != null) {
      currentTaskExecutorId = widget.task!.executor;
    }
    
    // Если мы создаем новую задачу и еще нет задач в смене, все сотрудники доступны
    if (widget.task == null && _shiftTasks.isEmpty) {
      return _employees;
    }
    
    // Если мы редактируем задачу, но список задач пуст (еще не загружен), возвращаем пустой список
    if (widget.task != null && _shiftTasks.isEmpty) {
      return [];
    }
    
    final tasksForFiltering = _shiftTasks.where((task) => 
      widget.task == null || task.id != widget.task!.id
    ).toList();
    
    final usedEmployeeIdsForFiltering = tasksForFiltering
        .where((task) => task.executor != null)
        .map((task) => task.executor!)
        .toSet();
    
    final availableEmployees = _employees.where((employee) {
      // Если это текущий исполнитель редактируемой задачи, он доступен
      if (currentTaskExecutorId != null && employee.id == currentTaskExecutorId) {
        return true;
      }
      // Остальные проверяем, не заняты ли они в других задачах
      return !usedEmployeeIdsForFiltering.contains(employee.id);
    }).toList();
    
    return availableEmployees;
  }

  List<Robot> _getAvailableRobots() {
    return _robots.where((robot) => !robot.hasBlockers).toList();
  }

  List<Transport> _getAvailableTransports() {
    if (_selectedEmployee == null) {
      return _transports;
    }
    
    final transportUsage = <int, int>{};
    final tasksForFiltering = _shiftTasks.where((task) => 
      widget.task == null || task.id != widget.task!.id
    ).toList();
    
    for (final task in tasksForFiltering) {
      if (task.transportId != null) {
        transportUsage[task.transportId!] = (transportUsage[task.transportId!] ?? 0) + 1;
      }
    }
    
    List<Transport> filteredTransports = _transports.where((transport) {
      final employee = _selectedEmployee!;
      final usageCount = transportUsage[transport.id] ?? 0;
      
      if (usageCount >= 2) {
        return false;
      }
      
      if (usageCount == 0) {
        if (!employee.drive && transport.carsharing) {
          return false;
        }
        
        if (!employee.accesToAutoVc && transport.autoVc) {
          return false;
        }
        
        if ((!employee.telemedicine || !employee.attorney) && transport.corporate) {
          return false;
        }
      }
      
      
      return true;
    }).toList();
    
    return filteredTransports;
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

    final availableEmployees = _getAvailableEmployees();
    if (!availableEmployees.any((emp) => emp.id == _selectedEmployee!.id)) {
      setState(() {
        _errorMessage = 'Selected employee is already assigned to another task in this shift';
      });
      return;
    }

    if (_selectedTransport != null) {
      final availableTransports = _getAvailableTransports();
      if (!availableTransports.any((trans) => trans.id == _selectedTransport!.id)) {
        setState(() {
          _errorMessage = 'Selected transport is already used in 2 tasks in this shift';
        });
        return;
      }
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

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final taskData = <String, dynamic>{};
      
      if (widget.task != null) {
        if (widget.task!.shiftId != (widget.task?.shiftId ?? widget.shiftId)) {
          taskData['shift_id'] = widget.task?.shiftId ?? widget.shiftId;
        }
        if (widget.task!.executor != _selectedEmployee!.id) {
          taskData['executor'] = _selectedEmployee!.id;
        }
        if (widget.task!.robotName != _selectedRobot?.id) {
          taskData['robot_name'] = _selectedRobot?.id;
        }
        if (widget.task!.transportId != _selectedTransport?.id) {
          taskData['transport_id'] = _selectedTransport?.id;
        }
        if (widget.task!.timeStart != startDateTime) {
          taskData['time_start'] = startDateTime.toIso8601String();
        }
        if (widget.task!.timeEnd != endDateTime) {
          taskData['time_end'] = endDateTime.toIso8601String();
        }
        if (widget.task!.type != _selectedTaskType) {
          taskData['type'] = _selectedTaskType.name;
        }
        if (widget.task!.geojson != _geojsonData) {
          taskData['geojson'] = _geojsonData;
        }
        if (widget.task!.tickets.toString() != _tickets.toString()) {
          taskData['tickets'] = _tickets;
        }
      } else {
        taskData['shift_id'] = widget.shiftId;
        taskData['executor'] = _selectedEmployee!.id;
        taskData['robot_name'] = _selectedRobot?.id;
        taskData['transport_id'] = _selectedTransport?.id;
        taskData['time_start'] = startDateTime.toIso8601String();
        taskData['time_end'] = endDateTime.toIso8601String();
        taskData['type'] = _selectedTaskType.name;
        taskData['geojson'] = _geojsonData;
        taskData['tickets'] = _tickets;
      }

      if (widget.task != null) {
        await ApiService.updateTask(widget.task!.id, taskData);
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSaved?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task successfully updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ApiService.createTask(taskData);
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSaved?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task successfully created'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    if (widget.task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text(
          'Are you sure you want to delete this task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await ApiService.deleteTask(widget.task!.id);
      
      if (mounted) {
        Navigator.of(context).pop();
        // Then call the callback to update parent
        widget.onSaved?.call();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task successfully deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(
          widget.task != null ? 'Edit task' : 'New task',
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
                    _buildSectionTitle('Task information'),
                    _buildEmployeeField(),
                    _buildRobotField(),
                    _buildTransportField(),
                    _buildTaskTypeField(),
                    
                    if (_selectedTaskType == TaskType.route) ...[
                      const SizedBox(height: 16),
                      _buildGeojsonField(),
                    ],
                    
                    const SizedBox(height: 16),
                    _buildTimeStartField(),
                    _buildTimeEndField(),
                    
                    const SizedBox(height: 16),
                    _buildTicketsField(),
                    
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
                            onPressed: _isLoading ? null : _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              widget.task != null ? 'Save' : 'Create',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (widget.task != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _deleteTask,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        else
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

  Widget _buildEmployeeField() {
    final availableEmployees = _getAvailableEmployees();
    
    // Проверяем, что выбранный сотрудник есть в списке доступных
    Employee? validValue = _selectedEmployee;
    if (_selectedEmployee != null && !availableEmployees.any((emp) => emp.id == _selectedEmployee!.id)) {
      // Если выбранный сотрудник не в списке доступных, сбрасываем значение
      validValue = null;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<Employee>(
            value: validValue,
            decoration: InputDecoration(
              labelText: 'Executor *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            ),
            items: availableEmployees.map((employee) {
              return DropdownMenuItem<Employee>(
                value: employee,
                child: Text(employee.fullName),
              );
            }).toList(),
            onChanged: (Employee? value) {
              setState(() {
                _selectedEmployee = value;
                // Сбрасываем выбранный транспорт при смене сотрудника
                _selectedTransport = null;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Select executor';
              }
              return null;
            },
          ),
          if (availableEmployees.length < _employees.length) ...[
            const SizedBox(height: 4),
            Text(
              'Only employees not assigned to other tasks in this shift are shown',
              style: ThemeService.captionStyle.copyWith(
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRobotField() {
    final availableRobots = _getAvailableRobots();
    final usedRobotIds = _shiftTasks
        .where((task) => widget.task == null || task.id != widget.task!.id)
        .where((task) => task.robotName != null)
        .map((task) => task.robotName!)
        .toSet();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<Robot>(
            value: _selectedRobot,
            decoration: InputDecoration(
              labelText: 'Robot',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            ),
            items: [
              const DropdownMenuItem<Robot>(
                value: null,
                child: Text('Not selected'),
              ),
              ..._robots.map((robot) {
                final isUsed = usedRobotIds.contains(robot.id);
                final isAvailable = availableRobots.any((r) => r.id == robot.id);
                
                return DropdownMenuItem<Robot>(
                  value: robot,
                  enabled: isAvailable,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (robot.hasBlockers) ...[
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isUsed) ...[
                        const Icon(
                          CupertinoIcons.clock,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          robot.displayName,
                          style: TextStyle(
                            color: isAvailable ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (Robot? value) {
              setState(() {
                _selectedRobot = value;
              });
            },
          ),
          if (usedRobotIds.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Robots already used in this shift are marked with clock icon',
              style: ThemeService.captionStyle.copyWith(
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransportField() {
    final availableTransports = _getAvailableTransports();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<Transport>(
            value: _selectedTransport,
            decoration: InputDecoration(
              labelText: 'Transport',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            ),
            items: [
              const DropdownMenuItem<Transport>(
                value: null,
                child: Text('Not selected'),
              ),
              ...availableTransports.map((transport) {
                return DropdownMenuItem<Transport>(
                  value: transport,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (transport.hasBlockers) ...[
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(child: Text(transport.displayName)),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (Transport? value) {
              setState(() {
                _selectedTransport = value;
              });
            },
          ),
          if (availableTransports.length < _transports.length) ...[
            const SizedBox(height: 4),
            Text(
              'Only transports used less than 2 times in this shift are shown',
              style: ThemeService.captionStyle.copyWith(
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskTypeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<TaskType>(
        value: _selectedTaskType,
        decoration: InputDecoration(
          labelText: 'Task type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
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
    );
  }

  Widget _buildGeojsonField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GeoJSON *',
            style: ThemeService.bodyStyle.copyWith(
              fontWeight: FontWeight.w500,
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
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
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
      ),
    );
  }

  Widget _buildTimeStartField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _timeStartController,
        keyboardType: TextInputType.numberWithOptions(decimal: false),
        decoration: InputDecoration(
          labelText: 'Start time *',
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
            return 'Enter start time';
          }
          if (!_isValidTimeFormat(value)) {
            return 'Enter time in format HH:MM';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTimeEndField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _timeEndController,
        keyboardType: TextInputType.numberWithOptions(decimal: false),
        decoration: InputDecoration(
          labelText: 'End time *',
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
            return 'Enter end time';
          }
          if (!_isValidTimeFormat(value)) {
            return 'Enter time in format HH:MM';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTicketsField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tickets *',
            style: ThemeService.bodyStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ticketsController,
                  decoration: InputDecoration(
                    labelText: 'Enter ticket',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
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
      ),
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
