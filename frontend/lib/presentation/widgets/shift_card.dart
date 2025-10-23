import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../data/models/shift_model.dart';
import 'task_card.dart';

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ShiftCard({
    super.key,
    required this.shift,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: onTap,
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
                      'Shift ${shift.date}',
                      style: ThemeService.captionStyle.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    shift.formattedDate,
                    style: ThemeService.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(CupertinoIcons.pencil),
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
                    shift.formattedTimeRange,
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
                    shift.formattedDuration,
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
                    shift.tasks.length.toString(),
                    CupertinoIcons.list_bullet,
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    context,
                    'Robots',
                    shift.tasks.where((t) => t.robotName != null).map((t) => t.robotName!).toSet().length.toString(),
                    CupertinoIcons.cube_box,
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    context,
                    'Executors',
                    shift.tasks.where((t) => t.executor != null).map((t) => t.executor!).toSet().length.toString(),
                    CupertinoIcons.person_2,
                  ),
                ],
              ),
              
              if (shift.tasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Tasks of shift',
                  style: ThemeService.subheadingStyle,
                ),
                const SizedBox(height: 12),
                ...shift.tasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskCard(task: task),
                )),
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
