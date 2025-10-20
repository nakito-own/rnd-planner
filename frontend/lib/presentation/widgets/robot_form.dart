import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/robot_model.dart';

class RobotForm extends StatefulWidget {
  final Robot? robot; // null для создания нового, не null для редактирования
  final VoidCallback? onSaved;
  final bool showAppBar;

  const RobotForm({
    super.key,
    this.robot,
    this.onSaved,
    this.showAppBar = true,
  });

  @override
  State<RobotForm> createState() => _RobotFormState();
}

class _RobotFormState extends State<RobotForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _seriesController = TextEditingController();

  bool _hasBlockers = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.robot != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final robot = widget.robot!;
    _nameController.text = robot.name.toString();
    _seriesController.text = robot.series.toString();
    _hasBlockers = robot.hasBlockers;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    super.dispose();
  }

  Future<void> _saveRobot() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final robotData = {
        'name': int.parse(_nameController.text.trim()),
        'series': int.parse(_seriesController.text.trim()),
        'has_blockers': _hasBlockers,
      };

      if (widget.robot != null) {
        await ApiService.updateRobot(widget.robot!.id, robotData);
      } else {
        await ApiService.createRobot(robotData);
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        widget.onSaved?.call();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.robot != null 
                  ? 'Robot successfully updated' 
                  : 'Robot successfully created',
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

  Future<void> _deleteRobot() async {
    if (widget.robot == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text(
          'Are you sure you want to delete the robot ${widget.robot!.displayName}?',
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
      await ApiService.deleteRobot(widget.robot!.id);
      
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        widget.onSaved?.call();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Robot successfully deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting robot: $e'),
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
          widget.robot != null ? 'Edit robot' : 'New robot',
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
                    _buildSectionTitle('Robot information'),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Robot name (number) *',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Robot name is required';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Robot name must be a number';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _seriesController,
                      label: 'Series *',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Series is required';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Series must be a number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Status'),
                    _buildCheckboxRow('Has blockers', _hasBlockers, (value) {
                      setState(() {
                        _hasBlockers = value;
                      });
                    }),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveRobot,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              widget.robot != null ? 'Save' : 'Create',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (widget.robot != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _deleteRobot,
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
