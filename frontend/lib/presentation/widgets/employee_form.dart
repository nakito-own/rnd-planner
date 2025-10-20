import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/employee_model.dart';

class EmployeeForm extends StatefulWidget {
  final Employee? employee; // null для создания нового, не null для редактирования
  final VoidCallback? onSaved;
  final bool showAppBar;

  const EmployeeForm({
    super.key,
    this.employee,
    this.onSaved,
    this.showAppBar = true,
  });

  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _tgController = TextEditingController();
  final _staffController = TextEditingController();
  final _bodyController = TextEditingController();
  final _crewController = TextEditingController();

  bool _drive = false;
  bool _parking = false;
  bool _telemedicine = false;
  bool _attorney = false;
  bool _accesToAutoVc = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final employee = widget.employee!;
    _firstnameController.text = employee.firstname;
    _lastnameController.text = employee.lastname;
    _patronymicController.text = employee.patronymic ?? '';
    _tgController.text = employee.tg ?? '';
    _staffController.text = employee.staff ?? '';
    _bodyController.text = employee.body ?? '';
    _crewController.text = employee.crew?.toString() ?? '';
    _drive = employee.drive;
    _parking = employee.parking;
    _telemedicine = employee.telemedicine;
    _attorney = employee.attorney;
    _accesToAutoVc = employee.accesToAutoVc;
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _patronymicController.dispose();
    _tgController.dispose();
    _staffController.dispose();
    _bodyController.dispose();
    _crewController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final employeeData = {
        'firstname': _firstnameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'patronymic': _patronymicController.text.trim().isEmpty 
            ? null 
            : _patronymicController.text.trim(),
        'tg': _tgController.text.trim().isEmpty 
            ? null 
            : _tgController.text.trim(),
        'staff': _staffController.text.trim().isEmpty 
            ? null 
            : _staffController.text.trim(),
        'body': _bodyController.text.trim().isEmpty 
            ? null 
            : _bodyController.text.trim(),
        'crew': _crewController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_crewController.text.trim()),
        'drive': _drive,
        'parking': _parking,
        'telemedicine': _telemedicine,
        'attorney': _attorney,
        'acces_to_auto_vc': _accesToAutoVc,
      };

      if (widget.employee != null) {
        await ApiService.updateEmployee(widget.employee!.id, employeeData);
      } else {
        await ApiService.createEmployee(employeeData);
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        widget.onSaved?.call();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.employee != null 
                  ? 'Employee successfully updated' 
                  : 'Employee successfully created',
            ),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _deleteEmployee() async {
    if (widget.employee == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text(
          'Are you sure you want to delete the employee ${widget.employee!.fullName}?',
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

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.deleteEmployee(widget.employee!.id);
      
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        widget.onSaved?.call();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Employee successfully deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting employee: $e'),
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
          widget.employee != null ? 'Edit employee' : 'New employee',
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
                    _buildSectionTitle('Main information'),
                    _buildTextField(
                      controller: _firstnameController,
                      label: 'Name *',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _lastnameController,
                      label: 'Last name *',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _patronymicController,
                      label: 'Patronymic',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Contact information'),
                    _buildTextField(
                      controller: _tgController,
                      label: 'Telegram *',
                    ),
                    _buildTextField(
                      controller: _staffController,
                      label: 'Staff nickname',
                    ),
                    _buildTextField(
                      controller: _bodyController,
                      label: 'Body',
                    ),
                    _buildTextField(
                      controller: _crewController,
                      label: 'Crew ID',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Rights and abilities'),
                    _buildCheckboxRow('Yandex Drive carsharing access', _drive, (value) {
                      setState(() {
                        _drive = value;
                      });
                    }),
                    _buildCheckboxRow('Parking', _parking, (value) {
                      setState(() {
                        _parking = value;
                      });
                    }),
                    _buildCheckboxRow('Telemedicine', _telemedicine, (value) {
                      setState(() {
                        _telemedicine = value;
                      });
                    }),
                    _buildCheckboxRow('Attorney', _attorney, (value) {
                      setState(() {
                        _attorney = value;
                      });
                    }),
                    _buildCheckboxRow('Access to Autonomous vehicle', _accesToAutoVc, (value) {
                      setState(() {
                        _accesToAutoVc = value;
                      });
                    }),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveEmployee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              widget.employee != null ? 'Save' : 'Create',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (widget.employee != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _deleteEmployee,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
