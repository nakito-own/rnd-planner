import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/services/theme_service.dart';
import '../../data/models/task_model.dart';
import 'dart:html' as html;

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getTaskTypeColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        task.typeIcon,
                        size: 16,
                        color: _getTaskTypeColor(context),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.typeDisplayName,
                          style: ThemeService.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.robotName != null ? 'Robot #${task.robotName}' : 'Robot not assigned',
                          style: ThemeService.captionStyle.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.executorName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.executorName!,
                            style: ThemeService.captionStyle.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            task.formattedTimeRange,
                            style: ThemeService.captionStyle.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (onEdit != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: onEdit,
                              icon: const Icon(CupertinoIcons.pencil_circle),
                              iconSize: 16,
                              tooltip: 'Edit task',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        task.formattedDuration,
                        style: ThemeService.captionStyle.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    task.executorName ?? (task.executor != null ? 'Executor #${task.executor}' : 'Executor not assigned'),
                    CupertinoIcons.person,
                  ),
                  
                  if (task.transportName != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      task.transportGovNumber != null 
                        ? '${task.transportName} (${task.transportGovNumber})'
                        : task.transportName!,
                      CupertinoIcons.car,
                    ),
                  ] else if (task.transportId != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      'Transport #${task.transportId}',
                      CupertinoIcons.car,
                    ),
                  ],
                  
                  if (task.tickets.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => TaskCard.openTicketLink(task.tickets.first),
                      child: _buildInfoChip(
                        context,
                        '${task.tickets.length} tickets',
                        CupertinoIcons.ticket,
                      ),
                    ),
                  ],
                ],
              ),
              
              if (task.geojson != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.map,
                        size: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Route configured',
                        style: ThemeService.captionStyle.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
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

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: ThemeService.captionStyle.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskTypeColor(BuildContext context) {
    switch (task.type) {
      case TaskType.route:
        return Colors.blue;
      case TaskType.carpet:
        return Colors.green;
      case TaskType.demo:
        return Colors.orange;
      case TaskType.custom:
        return Colors.purple;
    }
  }

  static void openTicketLink(String ticket) {
    if (kIsWeb) {
      // Формируем полный URL
      String url = ticket;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      html.window.open(url, '_blank');
    }
  }
}
