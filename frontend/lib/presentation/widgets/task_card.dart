import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
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
              // Заголовок задачи
              Row(
                children: [
                  // Иконка типа задачи
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getTaskTypeColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        task.typeIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Информация о задаче
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.typeDisplayName,
                          style: ThemeService.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.robotName != null ? 'Робот #${task.robotName}' : 'Робот не назначен',
                          style: ThemeService.captionStyle.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                        if (task.executorName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.executorName!,
                            style: ThemeService.captionStyle.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Время выполнения
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        task.formattedTimeRange,
                        style: ThemeService.captionStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
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
              
              // Дополнительная информация
              Row(
                children: [
                  // Исполнитель
                  _buildInfoChip(
                    context,
                    task.executorName ?? (task.executor != null ? 'Исполнитель #${task.executor}' : 'Исполнитель не назначен'),
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
                      'Транспорт #${task.transportId}',
                      CupertinoIcons.car,
                    ),
                  ],
                  
                  if (task.tickets.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      '${task.tickets.length} тикетов',
                      CupertinoIcons.ticket,
                    ),
                  ],
                ],
              ),
              
              // Геоданные (если есть)
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
                        'Маршрут настроен',
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
}
