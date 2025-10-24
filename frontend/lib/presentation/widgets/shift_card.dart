import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/task_model.dart';
import 'task_card.dart';
import 'task_form.dart';
import 'side_sheet.dart';

class ShiftCard extends StatefulWidget {
  final Shift shift;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onTaskUpdated;

  const ShiftCard({
    super.key,
    required this.shift,
    this.onTap,
    this.onEdit,
    this.onTaskUpdated,
  });

  @override
  State<ShiftCard> createState() => _ShiftCardState();
}

class _ShiftCardState extends State<ShiftCard> {
  late Shift _currentShift;

  @override
  void initState() {
    super.initState();
    _currentShift = widget.shift;
  }

  @override
  void didUpdateWidget(ShiftCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shift != oldWidget.shift) {
      _currentShift = widget.shift;
    }
  }


  void _editTask(Task task) {
    showAppSideSheet(
      context: context,
      width: 520,
      barrierColor: Colors.black54,
      child: TaskForm(
        task: task,
        onSaved: () {
          // Reload the shift data to get updated task information
          widget.onTaskUpdated?.call();
        },
        showAppBar: false,
      ),
    );
  }

  void _addNewTask() {
    showAppSideSheet(
      context: context,
      width: 520,
      barrierColor: Colors.black54,
      child: TaskForm(
        shiftId: _currentShift.id,
        onSaved: () {
          // Reload the shift data to get updated task information
          widget.onTaskUpdated?.call();
        },
        showAppBar: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Shift ${_currentShift.date}',
                      style: ThemeService.captionStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _currentShift.formattedDate,
                    style: ThemeService.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (widget.onEdit != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onEdit,
                      icon: const Icon(CupertinoIcons.pencil_circle),
                      iconSize: 18,
                      tooltip: 'Edit shift',
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    CupertinoIcons.time,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentShift.formattedTimeRange,
                    style: ThemeService.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    CupertinoIcons.clock,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentShift.formattedDuration,
                    style: ThemeService.captionStyle.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildStatItem(
                    context,
                    'Tasks',
                    _currentShift.tasks.length.toString(),
                    CupertinoIcons.list_bullet,
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    context,
                    'Robots',
                    _currentShift.tasks.where((t) => t.robotName != null).map((t) => t.robotName!).toSet().length.toString(),
                    CupertinoIcons.cube_box,
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    context,
                    'Executors',
                    _currentShift.tasks.where((t) => t.executor != null).map((t) => t.executor!).toSet().length.toString(),
                    CupertinoIcons.person_2,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Tasks of shift',
                    style: ThemeService.subheadingStyle,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addNewTask,
                    icon: const Icon(CupertinoIcons.add_circled, size: 16),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_currentShift.tasks.isNotEmpty) ...[
                ..._currentShift.tasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskCard(
                    task: task,
                    onEdit: () => _editTask(task),
                  ),
                )),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.list_bullet,
                        size: 32,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tasks yet',
                        style: ThemeService.bodyStyle.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add your first task to get started',
                        style: ThemeService.captionStyle.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: ThemeService.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: ThemeService.captionStyle.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
