import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/task_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shift_card.dart';

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedDate = date;
    });

    try {
      // Сначала проверяем подключение к серверу
      final isConnected = await ApiService.testConnection();
      if (!isConnected) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Не удается подключиться к серверу. Убедитесь, что бекенд запущен на http://localhost:8000';
        });
        return;
      }

      final shift = await ApiService.getShiftByDate(date);
      setState(() {
        _currentShift = shift;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки смены: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Смены',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.calendar),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () => _loadShiftForDate(_selectedDate),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.wifi),
            onPressed: _testConnection,
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
              : _currentShift == null || _currentShift!.tasks.isEmpty
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
    );
    if (picked != null && picked != _selectedDate) {
      _loadShiftForDate(picked);
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isConnected = await ApiService.testConnection();
      setState(() {
        _isLoading = false;
        if (isConnected) {
          _errorMessage = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Подключение к серверу успешно!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _errorMessage = 'Не удается подключиться к серверу. Проверьте, что бекенд запущен.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка проверки подключения: $e';
      });
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
            'Нет смен на ${_formatDate(_selectedDate)}',
            style: ThemeService.displayStyle.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Выберите другую дату или создайте смену',
            style: ThemeService.bodyStyle.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _selectDate,
            icon: const Icon(CupertinoIcons.calendar),
            label: const Text('Выбрать дату'),
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
            'Ошибка загрузки',
            style: ThemeService.displayStyle.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Неизвестная ошибка',
            style: ThemeService.bodyStyle.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _loadShiftForDate(_selectedDate),
            child: const Text('Повторить'),
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
            // Информация о выбранной дате
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Смена на ${_formatDate(_selectedDate)}',
                          style: ThemeService.subheadingStyle.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          '${_currentShift!.tasks.length} задач',
                          style: ThemeService.captionStyle.copyWith(
                            color: Theme.of(context).primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _selectDate,
                    icon: const Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
            ),
            // Карточка смены
            ShiftCard(
              shift: _currentShift!,
              onTap: () {
                // TODO: Добавить навигацию к детальной странице смены
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

}
