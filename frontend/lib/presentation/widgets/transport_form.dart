import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/api_service.dart';
import '../../data/models/transport_model.dart';

class TransportForm extends StatefulWidget {
  final Transport? transport; // null для создания нового, не null для редактирования
  final VoidCallback? onSaved;
  final bool showAppBar;

  const TransportForm({
    super.key,
    this.transport,
    this.onSaved,
    this.showAppBar = true,
  });

  @override
  State<TransportForm> createState() => _TransportFormState();
}

class _TransportFormState extends State<TransportForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _govNumberController = TextEditingController();

  bool _carsharing = false;
  bool _corporate = false;
  bool _autoVc = false;
  bool _hasBlockers = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transport != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final transport = widget.transport!;
    _nameController.text = transport.name;
    _modelController.text = transport.model ?? '';
    _govNumberController.text = transport.govNumber ?? '';
    _carsharing = transport.carsharing;
    _corporate = transport.corporate;
    _autoVc = transport.autoVc;
    _hasBlockers = transport.hasBlockers;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _govNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveTransport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transportData = {
        'name': _nameController.text.trim(),
        'model': _modelController.text.trim().isEmpty 
            ? null 
            : _modelController.text.trim(),
        'gov_number': _govNumberController.text.trim().isEmpty 
            ? null 
            : _govNumberController.text.trim(),
        'carsharing': _carsharing,
        'corporate': _corporate,
        'auto_vc': _autoVc,
        'has_blockers': _hasBlockers,
      };

      if (widget.transport != null) {
        await ApiService.updateTransport(widget.transport!.id, transportData);
      } else {
        await ApiService.createTransport(transportData);
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        widget.onSaved?.call();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.transport != null 
                  ? 'Transport successfully updated' 
                  : 'Transport successfully created',
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

  Future<void> _deleteTransport() async {
    if (widget.transport == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text(
          'Are you sure you want to delete the transport "${widget.transport!.displayName}"?',
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
      await ApiService.deleteTransport(widget.transport!.id);
      
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        widget.onSaved?.call();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Transport successfully deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transport: $e'),
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
          widget.transport != null ? 'Edit transport' : 'New transport',
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
                      controller: _nameController,
                      label: 'Name *',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _modelController,
                      label: 'Model',
                    ),
                    _buildTextField(
                      controller: _govNumberController,
                      label: 'License plate',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Transport type'),
                    _buildCheckboxRow('Carsharing', _carsharing, (value) {
                      setState(() {
                        _carsharing = value;
                      });
                    }),
                    _buildCheckboxRow('Corporate', _corporate, (value) {
                      setState(() {
                        _corporate = value;
                      });
                    }),
                    _buildCheckboxRow('Auto-VC', _autoVc, (value) {
                      setState(() {
                        _autoVc = value;
                      });
                    }),
                    _buildCheckboxRow('Has Blockers', _hasBlockers, (value) {
                      setState(() {
                        _hasBlockers = value;
                      });
                    }),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveTransport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              widget.transport != null ? 'Save' : 'Create',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (widget.transport != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _deleteTransport,
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
