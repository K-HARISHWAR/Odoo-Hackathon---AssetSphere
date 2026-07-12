import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/asset_condition.dart';
import '../../data/datasources/assets_mock_datasource.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../domain/usecases/add_asset_usecase.dart';
import '../controllers/asset_registration_controller.dart';

class RegisterAssetPage extends StatefulWidget {
  final AssetRepository? repository;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const RegisterAssetPage({
    super.key, 
    this.repository,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<RegisterAssetPage> createState() => _RegisterAssetPageState();
}

class _RegisterAssetPageState extends State<RegisterAssetPage> {
  final _formKey = GlobalKey<FormState>();
  late final AssetRegistrationController _controller;

  final _nameController = TextEditingController();
  final _serialController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _costController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  DateTime? _warrantyExpiry;
  AssetCondition _condition = AssetCondition.newCondition;
  bool _isShared = false;
  bool _isBookable = false;

  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedDepartment;

  final List<String> _categories = [
    'Laptop',
    'Desktop',
    'Monitor',
    'Tablet',
    'Phone',
    'Printer',
    'Projector',
    'Office Chair',
    'Desk',
    'Vehicle',
    'Server',
    'Networking Gear',
    'Software License',
    'Others',
  ];

  final List<String> _locations = [
    'Main HQ',
    'Branch Office North',
    'Branch Office South',
    'Warehouse A',
    'Remote / Home Office',
    'Client Site',
    'In Transit',
    'Others',
  ];

  final List<String> _departments = [
    'IT / Technology',
    'Human Resources',
    'Finance',
    'Marketing',
    'Sales',
    'Operations',
    'Logistics',
    'Administration',
    'Legal',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    
    final repo = widget.repository ?? AssetRepositoryImpl(
      dataSource: AssetsMockDataSource(),
    );
    
    _controller = AssetRegistrationController(
      repository: repo,
      addAsset: AddAssetUseCase(repo),
    );

    _controller.prepareRegistration();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    _costController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withAlpha(245),
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Register New Asset',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withAlpha(100),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.generatedTag.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderInfo(theme),
                      const SizedBox(height: AppSizes.spacingXl),
                      _buildFormSection(
                        theme: theme,
                        icon: Icons.info_outline,
                        title: 'Basic Information',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Asset Name *',
                                  controller: _nameController,
                                  validator: (v) =>
                                      v?.isEmpty ?? true ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingMd),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Serial Number',
                                  controller: _serialController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: _getInputDecoration('Category *'),
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                                if (newValue != 'Others') {
                                  _categoryController.text = newValue ?? '';
                                } else {
                                  _categoryController.clear();
                                }
                              });
                            },
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          if (_selectedCategory == 'Others') ...[
                            const SizedBox(height: AppSizes.spacingMd),
                            _buildTextField(
                              label: 'Specify Other Category *',
                              controller: _categoryController,
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Please specify category'
                                  : null,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingLg),
                      _buildFormSection(
                        theme: theme,
                        icon: Icons.location_on_outlined,
                        title: 'Deployment & Condition',
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedLocation,
                                      decoration: _getInputDecoration(
                                        'Location *',
                                      ),
                                      items: _locations.map((String loc) {
                                        return DropdownMenuItem<String>(
                                          value: loc,
                                          child: Text(loc),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedLocation = newValue;
                                          if (newValue != 'Others') {
                                            _locationController.text =
                                                newValue ?? '';
                                          } else {
                                            _locationController.clear();
                                          }
                                        });
                                      },
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    if (_selectedLocation == 'Others') ...[
                                      const SizedBox(
                                        height: AppSizes.spacingMd,
                                      ),
                                      _buildTextField(
                                        label: 'Specify Location *',
                                        controller: _locationController,
                                        validator: (v) => v?.isEmpty ?? true
                                            ? 'Required'
                                            : null,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingMd),
                              Expanded(
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedDepartment,
                                      decoration: _getInputDecoration(
                                        'Department *',
                                      ),
                                      items: _departments.map((String dept) {
                                        return DropdownMenuItem<String>(
                                          value: dept,
                                          child: Text(dept),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedDepartment = newValue;
                                          if (newValue != 'Others') {
                                            _departmentController.text =
                                                newValue ?? '';
                                          } else {
                                            _departmentController.clear();
                                          }
                                        });
                                      },
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    if (_selectedDepartment == 'Others') ...[
                                      const SizedBox(
                                        height: AppSizes.spacingMd,
                                      ),
                                      _buildTextField(
                                        label: 'Specify Department *',
                                        controller: _departmentController,
                                        validator: (v) => v?.isEmpty ?? true
                                            ? 'Required'
                                            : null,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          DropdownButtonFormField<AssetCondition>(
                            initialValue: _condition,
                            decoration: _getInputDecoration('Condition *'),
                            items: AssetCondition.values
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.displayName),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _condition = v!),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingLg),
                      _buildFormSection(
                        theme: theme,
                        icon: Icons.payments_outlined,
                        title: 'Acquisition & Warranty',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDatePicker(
                                  label: 'Purchase Date *',
                                  value: _purchaseDate,
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _purchaseDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => _purchaseDate = date);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingMd),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Purchase Cost *',
                                  controller: _costController,
                                  prefixText: '₹ ',
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return 'Required';
                                    final val = double.tryParse(v!);
                                    if (val == null || val <= 0) {
                                      return 'Invalid amount';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          _buildDatePicker(
                            label: 'Warranty Expiry',
                            value: _warrantyExpiry,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    _warrantyExpiry ??
                                    DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _warrantyExpiry = date);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingLg),
                      _buildFormSection(
                        theme: theme,
                        icon: Icons.settings_outlined,
                        title: 'Asset Policy',
                        children: [
                          SwitchListTile(
                            title: const Text('Shared Resource'),
                            subtitle: const Text(
                              'Accessible across departments',
                            ),
                            value: _isShared,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setState(() {
                              _isShared = v;
                              if (!v) _isBookable = false;
                            }),
                          ),
                          SwitchListTile(
                            title: const Text('Bookable'),
                            subtitle: const Text(
                              'Allow time-based reservations',
                            ),
                            value: _isBookable,
                            contentPadding: EdgeInsets.zero,
                            onChanged: _isShared
                                ? (v) => setState(() => _isBookable = v)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingXl),
                      _buildSubmitButton(theme),
                      const SizedBox(height: AppSizes.spacingXl),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(200),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
          const SizedBox(width: AppSizes.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto-Generated Tag',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  _controller.generatedTag.isEmpty
                      ? 'Generating...'
                      : _controller.generatedTag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PENDING',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _getInputDecoration(label).copyWith(prefixText: prefixText),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InputDecorator(
        decoration: _getInputDecoration(label).copyWith(
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year}'
              : 'Select Date',
          style: TextStyle(color: value == null ? Colors.grey : null),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: 12,
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        onPressed: _controller.isLoading ? null : _submit,
        child: _controller.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Complete Registration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.submitRegistration(
        name: _nameController.text,
        serialNumber: _serialController.text.isEmpty
            ? null
            : _serialController.text,
        category: _categoryController.text,
        location: _locationController.text,
        department: _departmentController.text,
        purchaseDate: _purchaseDate,
        purchaseCost: double.parse(_costController.text),
        warrantyExpiry: _warrantyExpiry,
        condition: _condition,
        isShared: _isShared,
        isBookable: _isBookable,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text('Asset successfully added to the registry'),
          ),
        );
        widget.onSuccess?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('Error: ${_controller.error}'),
          ),
        );
      }
    }
  }
}
