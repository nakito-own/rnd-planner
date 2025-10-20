import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/transport_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/transport_form.dart';
import '../widgets/side_sheet.dart';

class TransportsPage extends StatefulWidget {
  const TransportsPage({super.key});

  @override
  State<TransportsPage> createState() => _TransportsPageState();
}

class _TransportsPageState extends State<TransportsPage> {
  List<Transport> _transports = [];
  List<Transport> _allTransports = [];
  bool _isLoading = true;
  String? _error;
  
  bool _carsharingFilter = false;
  bool _corporateFilter = false;
  bool _autoVcFilter = false;
  bool _hasBlockersFilter = false;
  
  // Поиск по названию
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _loadTransports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final transports = await ApiService.getTransports();
      setState(() {
        _allTransports = transports;
        _transports = transports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _transports = _allTransports.where((transport) {
        // Поиск по названию
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          final name = transport.name.toLowerCase();
          final model = transport.model?.toLowerCase() ?? '';
          final govNumber = transport.govNumber?.toLowerCase() ?? '';
          
          if (!name.contains(searchText) && 
              !model.contains(searchText) && 
              !govNumber.contains(searchText)) {
            return false;
          }
        }

        if (_carsharingFilter && !transport.carsharing) {
          return false;
        }

        if (_corporateFilter && !transport.corporate) {
          return false;
        }

        if (_autoVcFilter && !transport.autoVc) {
          return false;
        }

        if (_hasBlockersFilter && !transport.hasBlockers) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _carsharingFilter = false;
      _corporateFilter = false;
      _autoVcFilter = false;
      _hasBlockersFilter = false;
      _searchController.clear();
      _isSearchVisible = false;
      _transports = _allTransports;
    });
  }

  void _openTransportForm({Transport? transport}) {
    showAppSideSheet(
      context: context,
      width: 480,
      barrierColor: Colors.black54,
      child: TransportForm(
        transport: transport,
        onSaved: _loadTransports,
        showAppBar: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transport',
          style: ThemeService.subheadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            onPressed: _openTransportForm,
            tooltip: 'Add new transport',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: _loadTransports,
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
            Text('Loading transports...'),
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
              onPressed: _loadTransports,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allTransports.isEmpty) {
      return Column(
        children: [
          _buildFiltersPanel(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.car,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total transports: 0',
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
                    CupertinoIcons.car,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transports in database',
                    style: ThemeService.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first transport to get started',
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

    if (_transports.isEmpty) {
      return Column(
        children: [
          _buildFiltersPanel(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.car,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total transports: 0',
                  style: ThemeService.subheadingStyle,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_allTransports.length} total)',
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
                    CupertinoIcons.car,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transports match current filters',
                    style: ThemeService.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or clear them to see all transports',
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
                CupertinoIcons.car,
                size: 24,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                'Total transports: ${_transports.length}',
                style: ThemeService.subheadingStyle,
              ),
              if (_transports.length != _allTransports.length) ...[
                const SizedBox(width: 8),
                Text(
                  '(${_allTransports.length} total)',
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
            itemCount: _transports.length,
            itemBuilder: (context, index) {
              final transport = _transports[index];
              return _buildTransportCard(transport);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransportCard(Transport transport) {
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
                    transport.name[0].toUpperCase(),
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
                      Row(
                        children: [
                          Text(
                            transport.displayName,
                            style: ThemeService.subheadingStyle,
                          ),
                          const SizedBox(width: 16),
                          if (transport.govNumber != null && transport.govNumber!.isNotEmpty)
                            _buildCompactInfoRow('Гос. номер', transport.govNumber!),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.pencil_circle),
                  onPressed: () => _openTransportForm(transport: transport),
                  tooltip: 'Edit transport',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (transport.carsharing)
                  _buildBadge('Carsharing', Colors.green),
                if (transport.corporate)
                  _buildBadge('Corporate', Colors.blue),
                if (transport.autoVc)
                  _buildBadge('Auto-VC', Colors.purple),
                if (transport.hasBlockers)
                  _buildBadge('Has Blockers', Colors.orange),
              ],
            ),
          ],
        ),
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
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
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
          
          // Поле поиска по названию
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 60 : 0,
            child: _isSearchVisible ? _buildSearchField(isDark) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(bool isDark) {
    return Row(
      children: [
        _buildCompactCheckbox(
          'Carsharing',
          _carsharingFilter,
          (value) {
            setState(() {
              _carsharingFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
        const SizedBox(width: 12),
        _buildCompactCheckbox(
          'Corporate',
          _corporateFilter,
          (value) {
            setState(() {
              _corporateFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
        const SizedBox(width: 12),
        _buildCompactCheckbox(
          'Auto-VC',
          _autoVcFilter,
          (value) {
            setState(() {
              _autoVcFilter = value;
            });
            _applyFilters();
          },
          isDark,
        ),
        const SizedBox(width: 12),
        _buildCompactCheckbox(
          'Has Blockers',
          _hasBlockersFilter,
          (value) {
            setState(() {
              _hasBlockersFilter = value;
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
          hintText: 'Search by name, model, or license plate...',
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