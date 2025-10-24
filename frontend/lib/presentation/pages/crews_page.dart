import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/employee_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/employee_form.dart';
import '../widgets/side_sheet.dart';

class CrewsPage extends StatefulWidget {
  const CrewsPage({super.key});

  @override
  State<CrewsPage> createState() => _CrewsPageState();
}

class _CrewsPageState extends State<CrewsPage> {
  List<Employee> _employees = [];
  List<Employee> _allEmployees = [];
  bool _isLoading = true;
  String? _error;
  
  String? _selectedBody;
  int? _selectedCrewId;
  bool _parkingFilter = false;
  bool _driveFilter = false;
  bool _telemedicineFilter = false;
  bool _accessFilter = false;
  
  // Поиск по ФИО
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  
  List<String> _availableBodies = [];
  List<int> _availableCrewIds = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final employees = await ApiService.getEmployees();
      if (mounted) {
        setState(() {
          _allEmployees = employees;
          _employees = employees;
          
          _availableBodies = employees
              .where((e) => e.body != null && e.body!.isNotEmpty)
              .map((e) => e.body!)
              .toSet()
              .toList()
            ..sort();
              
          _availableCrewIds = employees
              .where((e) => e.crew != null)
              .map((e) => e.crew!)
              .toSet()
              .toList()
            ..sort();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    
    setState(() {
      _employees = _allEmployees.where((employee) {
        // Поиск по ФИО
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          final fullName = employee.fullName.toLowerCase();
          if (!fullName.contains(searchText)) {
            return false;
          }
        }

        if (_selectedBody != null && employee.body != _selectedBody) {
          return false;
        }

        if (_selectedCrewId != null && employee.crew != _selectedCrewId) {
          return false;
        }

        if (_parkingFilter && !employee.parking) {
          return false;
        }

        if (_driveFilter && !employee.drive) {
          return false;
        }

        if (_telemedicineFilter && !employee.telemedicine) {
          return false;
        }

        if (_accessFilter && !employee.accesToAutoVc) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedBody = null;
      _selectedCrewId = null;
      _parkingFilter = false;
      _driveFilter = false;
      _telemedicineFilter = false;
      _accessFilter = false;
      _searchController.clear();
      _isSearchVisible = false;
      _employees = _allEmployees;
    });
  }

  void _openEmployeeForm({Employee? employee}) {
    showAppSideSheet(
      context: context,
      width: 520,
      barrierColor: Colors.black54,
      child: EmployeeForm(
        employee: employee,
        onSaved: _loadEmployees,
        showAppBar: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crews and Employees',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            onPressed: _openEmployeeForm,
            tooltip: 'Add new employee',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Update data',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading employees...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: ThemeService.subheadingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: ThemeService.bodyStyle.copyWith(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allEmployees.isEmpty) {
      return Column(
        children: [
          _buildFiltersPanel(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.person_2,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total employees: 0',
                  style: ThemeService.subheadingStyle,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.person_2,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No employees in database',
                    style: ThemeService.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first employee to get started',
                    style: ThemeService.bodyStyle.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_employees.isEmpty) {
      return Column(
        children: [
          _buildFiltersPanel(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.person_2,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total employees: 0',
                  style: ThemeService.subheadingStyle,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_allEmployees.length} total)',
                  style: ThemeService.bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.person_2,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No employees match current filters',
                    style: ThemeService.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or clear them to see all employees',
                    style: ThemeService.bodyStyle.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(CupertinoIcons.clear),
                    label: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFiltersPanel(),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.person_2,
                size: 24,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                'Total employees: ${_employees.length}',
                style: ThemeService.subheadingStyle,
              ),
              if (_employees.length != _allEmployees.length) ...[
                const SizedBox(width: 8),
                Text(
                  '(${_allEmployees.length} total)',
                  style: ThemeService.bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _employees.length,
            itemBuilder: (context, index) {
              final employee = _employees[index];
              return _buildEmployeeCard(employee);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    employee.firstname[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ФИО и дополнительная информация справа от ФИО
                          Row(
                            children: [
                              Text(
                                employee.fullName,
                                style: ThemeService.subheadingStyle,
                              ),
                              const SizedBox(width: 16),
                              // Информация справа от ФИО, выровненная по левому краю
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (employee.body != null && employee.body!.isNotEmpty) ...[
                                    _buildCompactInfoRow('Body', employee.body!),
                                    const SizedBox(width: 12),
                                  ],
                                  if (employee.tg != null && employee.tg!.isNotEmpty) ...[
                                    _buildCompactInfoRow('Telegram', employee.tg!),
                                    const SizedBox(width: 12),
                                  ],
                                  if (employee.crew != null)
                                    _buildCompactInfoRow('Crew', 'ID: ${employee.crew}'),
                                ],
                              ),
                            ],
                          ),
                          // Должность под ФИО
                          if (employee.staff != null && employee.staff!.isNotEmpty)
                            Text(
                              employee.staff!,
                              style: ThemeService.bodyStyle.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.pencil_circle),
                  onPressed: () => _openEmployeeForm(employee: employee),
                  tooltip: 'Edit employee',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (employee.drive)
                  _buildBadge('Drive', Colors.green),
                if (employee.parking)
                  _buildBadge('Parking', Colors.blue),
                if (employee.telemedicine)
                  _buildBadge('Telemedicine', Colors.purple),
                if (employee.attorney)
                  _buildBadge('Attorney', Colors.orange),
                if (employee.accesToAutoVc)
                  _buildBadge('Access to Auto-VC', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '$label: ',
              style: ThemeService.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: ThemeService.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDropdownFilter(
                        'Body',
                        _selectedBody,
                        _availableBodies,
                        (value) {
                          setState(() {
                            _selectedBody = value;
                          });
                          _applyFilters();
                        },
                        isDark,
                      ),
                      const SizedBox(width: 16),
                      
                      _buildDropdownFilter(
                        'Crew',
                        _selectedCrewId?.toString(),
                        _availableCrewIds.map((id) => id.toString()).toList(),
                        (value) {
                          setState(() {
                            _selectedCrewId = value != null ? int.tryParse(value) : null;
                          });
                          _applyFilters();
                        },
                        isDark,
                      ),
                      const SizedBox(width: 16),
                      
                      _buildCheckboxRow(isDark),
                    ],
                  ),
                ),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                        if (!_isSearchVisible) {
                          _searchController.clear();
                          _applyFilters();
                        }
                      });
                    },
                    icon: Icon(
                      _isSearchVisible ? CupertinoIcons.search_circle_fill : CupertinoIcons.search,
                      size: 14,
                      color: _isSearchVisible ? Colors.blue : Colors.grey[600],
                    ),
                    label: Text(
                      'Search',
                      style: TextStyle(
                        color: _isSearchVisible ? Colors.blue : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: Icon(
                      CupertinoIcons.clear, 
                      size: 14,
                      color: Colors.red[600],
                    ),
                    label: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Поле поиска по ФИО
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 60 : 0,
            child: _isSearchVisible ? _buildSearchField(isDark) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return Container(
      width: 150,
      child: DropdownButtonFormField<String?>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              'All $label',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
          ...options.map((option) => DropdownMenuItem<String?>(
            value: option,
            child: Text(
              option,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          )),
        ],
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        icon: Icon(
          CupertinoIcons.chevron_down,
          color: isDark ? Colors.white70 : Colors.black54,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(bool isDark) {
    return Row(
      children: [
        _buildCompactCheckbox(
          'Parking',
          _parkingFilter,
          (value) {
            setState(() {
              _parkingFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
        const SizedBox(width: 12),
        _buildCompactCheckbox(
          'Drive',
          _driveFilter,
          (value) {
            setState(() {
              _driveFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
        const SizedBox(width: 12),
        _buildCompactCheckbox(
          'Telemedicine',
          _telemedicineFilter,
          (value) {
            setState(() {
              _telemedicineFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
        const SizedBox(width: 12),
        _buildCompactCheckbox(
          'Auto-VC',
          _accessFilter,
          (value) {
            setState(() {
              _accessFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
      ],
    );
  }

  Widget _buildCompactCheckbox(
    String label,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (newValue) => onChanged(newValue ?? false),
          activeColor: Colors.blue,
          checkColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: isDark ? Colors.white70 : Colors.black54,
            size: 18,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    CupertinoIcons.clear,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 16,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        onChanged: (value) {
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildCompactInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$label: ',
            style: ThemeService.bodyStyle.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: ThemeService.bodyStyle.copyWith(
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}