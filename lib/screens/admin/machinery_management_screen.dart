import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/machinery.dart';
import '../../models/category.dart';

class MachineryManagementScreen extends StatefulWidget {
  const MachineryManagementScreen({super.key});

  @override
  State<MachineryManagementScreen> createState() =>
      _MachineryManagementScreenState();
}

class _MachineryManagementScreenState extends State<MachineryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _machineryTypeController = TextEditingController();
  final _modelController = TextEditingController();
  final _horsepowerController = TextEditingController();
  final _priceController = TextEditingController();
  final _conditionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Technical Specifications Controllers
  final _cabinTypeController = TextEditingController();
  final _workingWeightController = TextEditingController();
  final _workingLengthController = TextEditingController();
  final _workingWidthController = TextEditingController();
  final _workingHeightController = TextEditingController();
  final _trackWidthController = TextEditingController();
  final _bladeTypeController = TextEditingController();
  final _bladeCapacityController = TextEditingController();
  final _bladeWidthController = TextEditingController();
  final _ripperTypeController = TextEditingController();
  final _engineManufacturerController = TextEditingController();
  final _engineTypeController = TextEditingController();
  final _enginePowerController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _yearOfManufactureController = TextEditingController();
  final _serialNumberController = TextEditingController();

  // Tractor-specific Controllers
  final _powerKWController = TextEditingController();
  final _powerHPController = TextEditingController();
  final _wheelArrangementController = TextEditingController();
  final _crankshaftRatedSpeedController = TextEditingController();
  final _numberOfCylindersController = TextEditingController();
  final _fuelTankCapacityController = TextEditingController();
  final _numberOfGearsController = TextEditingController();
  final _liftingCapacityController = TextEditingController();
  final _operatingWeightController = TextEditingController();
  final _tractorBaseController = TextEditingController();
  final _agrotechnicalClearanceController = TextEditingController();

  String _selectedType = 'rental';
  bool _isAvailable = true;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedType = _tabController.index == 0 ? 'rental' : 'sale';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _modelController.dispose();
    _horsepowerController.dispose();
    _priceController.dispose();
    _conditionController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machinery Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMachineryDialog(),
          ),
          // Debug: Add test machinery for sale
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => _addTestMachinery(),
            tooltip: 'Add Test Machinery',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
          indicatorColor: AppTheme.white,
          tabs: const [
            Tab(text: 'Rental'),
            Tab(text: 'For Sale'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMachineryList('rental'),
          _buildMachineryList('sale'),
        ],
      ),
    );
  }

  Widget _buildMachineryList(String type) {
    return StreamBuilder<List<Machinery>>(
      stream: Provider.of<FirebaseService>(context, listen: false)
          .getMachinery(type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: AppTheme.gray),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('Error loading machinery', style: AppTheme.heading3),
              ],
            ),
          );
        }

        final machineryList = snapshot.data ?? [];

        if (machineryList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.agriculture, size: 60, color: AppTheme.gray),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('No ${type == 'rental' ? 'rental' : 'sale'} machinery',
                    style: AppTheme.heading3),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                    'Add your first ${type == 'rental' ? 'rental' : 'sale'} equipment',
                    style: AppTheme.caption),
                const SizedBox(height: AppTheme.paddingLarge),
                ElevatedButton(
                  onPressed: () => _showAddMachineryDialog(),
                  child: Text(
                      'Add ${type == 'rental' ? 'Rental' : 'Sale'} Equipment'),
                ),
                // Debug: Show total machinery count
                const SizedBox(height: AppTheme.paddingMedium),
                StreamBuilder<List<Machinery>>(
                  stream: Provider.of<FirebaseService>(context, listen: false)
                      .getMachinery(),
                  builder: (context, allMachinerySnapshot) {
                    if (allMachinerySnapshot.hasData) {
                      final allMachinery = allMachinerySnapshot.data!;
                      final rentalCount =
                          allMachinery.where((m) => m.type == 'rental').length;
                      final saleCount =
                          allMachinery.where((m) => m.type == 'sale').length;
                      return Container(
                        padding: const EdgeInsets.all(AppTheme.paddingSmall),
                        decoration: BoxDecoration(
                          color: AppTheme.gray.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          'Debug: Total: ${allMachinery.length}, Rental: $rentalCount, Sale: $saleCount',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.gray,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: machineryList.length,
          itemBuilder: (context, index) {
            final machinery = machineryList[index];
            return _buildMachineryCard(machinery);
          },
        );
      },
    );
  }

  Widget _buildMachineryCard(Machinery machinery) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machinery.name,
                        style: AppTheme.heading3,
                      ),
                      Text(
                        machinery.model,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditMachineryDialog(machinery);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(machinery);
                        break;
                      case 'toggle':
                        _toggleMachineryAvailability(machinery);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            machinery.isAvailable
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(machinery.isAvailable ? 'Disable' : 'Enable'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                // Mode indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: machinery.type == 'rental'
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: machinery.type == 'rental'
                          ? AppTheme.primaryGreen
                          : Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        machinery.type == 'rental'
                            ? Icons.schedule
                            : Icons.shopping_cart,
                        size: 12,
                        color: machinery.type == 'rental'
                            ? AppTheme.primaryGreen
                            : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        machinery.type == 'rental' ? 'Rental' : 'Sale',
                        style: AppTheme.caption.copyWith(
                          color: machinery.type == 'rental'
                              ? AppTheme.primaryGreen
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${machinery.horsepower} HP',
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Condition: ${machinery.condition}',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'GHS ${machinery.price.toStringAsFixed(2)}',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      machinery.type == 'rental' ? '/day' : 'for sale',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.gray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: Text(
                    machinery.location,
                    style: AppTheme.caption,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: machinery.isAvailable
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : AppTheme.gray.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    machinery.isAvailable ? 'Available' : 'Unavailable',
                    style: AppTheme.caption.copyWith(
                      color: machinery.isAvailable
                          ? AppTheme.primaryGreen
                          : AppTheme.gray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (machinery.description.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                machinery.description,
                style: AppTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Debug: Show image URLs if available
            if (machinery.imageUrls.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image,
                      size: 12,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Images: ${machinery.imageUrls.length} uploaded',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryGreen,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddMachineryDialog() {
    _resetForm();
    _showMachineryDialog(null);
  }

  void _showEditMachineryDialog(Machinery machinery) {
    _nameController.text = machinery.name;
    _machineryTypeController.text = machinery.machineryType;
    _modelController.text = machinery.model;
    _horsepowerController.text = machinery.horsepower.toString();
    _priceController.text = machinery.price.toString();
    _conditionController.text = machinery.condition;
    _descriptionController.text = machinery.description;
    _locationController.text = machinery.location;
    _selectedType = machinery.type;
    _isAvailable = machinery.isAvailable;

    // Populate technical specifications
    _cabinTypeController.text = machinery.cabinType ?? '';
    _workingWeightController.text = machinery.workingWeight?.toString() ?? '';
    _workingLengthController.text = machinery.workingLength?.toString() ?? '';
    _workingWidthController.text = machinery.workingWidth?.toString() ?? '';
    _workingHeightController.text = machinery.workingHeight?.toString() ?? '';
    _trackWidthController.text = machinery.trackWidth?.toString() ?? '';
    _bladeTypeController.text = machinery.bladeType ?? '';
    _bladeCapacityController.text = machinery.bladeCapacity?.toString() ?? '';
    _bladeWidthController.text = machinery.bladeWidth?.toString() ?? '';
    _ripperTypeController.text = machinery.ripperType ?? '';
    _engineManufacturerController.text = machinery.engineManufacturer ?? '';
    _engineTypeController.text = machinery.engineType ?? '';
    _enginePowerController.text = machinery.enginePower?.toString() ?? '';
    _fuelTypeController.text = machinery.fuelType ?? '';
    _yearOfManufactureController.text =
        machinery.yearOfManufacture?.toString() ?? '';
    _serialNumberController.text = machinery.serialNumber ?? '';

    // Populate tractor-specific specifications
    _powerKWController.text = machinery.powerKW?.toString() ?? '';
    _powerHPController.text = machinery.powerHP?.toString() ?? '';
    _wheelArrangementController.text = machinery.wheelArrangement ?? '';
    _crankshaftRatedSpeedController.text =
        machinery.crankshaftRatedSpeed?.toString() ?? '';
    _numberOfCylindersController.text =
        machinery.numberOfCylinders?.toString() ?? '';
    _fuelTankCapacityController.text =
        machinery.fuelTankCapacity?.toString() ?? '';
    _numberOfGearsController.text = machinery.numberOfGears ?? '';
    _liftingCapacityController.text =
        machinery.liftingCapacity?.toString() ?? '';
    _operatingWeightController.text =
        machinery.operatingWeight?.toString() ?? '';
    _tractorBaseController.text = machinery.tractorBase?.toString() ?? '';
    _agrotechnicalClearanceController.text =
        machinery.agrotechnicalClearance?.toString() ?? '';

    _showMachineryDialog(machinery);
  }

  void _showMachineryDialog(Machinery? existingMachinery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            existingMachinery == null ? 'Add Machinery' : 'Edit Machinery'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height *
              0.75, // Slightly smaller height
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Upload Section
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                          color: AppTheme.gray.withValues(alpha: 0.3)),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : InkWell(
                            onTap: _pickImage,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppTheme.gray,
                                ),
                                const SizedBox(height: AppTheme.paddingSmall),
                                Text(
                                  'Tap to add machinery image',
                                  style: AppTheme.caption
                                      .copyWith(color: AppTheme.gray),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Machine Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter machine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  StreamBuilder<List<Category>>(
                    stream: Provider.of<FirebaseService>(context, listen: false)
                        .getCategories('machinery'),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];

                      if (categories.isEmpty) {
                        return TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Machinery Type',
                            border: OutlineInputBorder(),
                            helperText:
                                'No machinery types available. Please add types first.',
                          ),
                          enabled: false,
                        );
                      }

                      // Check if the current machinery type exists in the categories
                      final currentValue = _machineryTypeController.text.isEmpty
                          ? null
                          : _machineryTypeController.text;

                      final valueExists =
                          categories.any((cat) => cat.name == currentValue);
                      final dropdownValue = valueExists ? currentValue : null;

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Machinery Type',
                          border: OutlineInputBorder(),
                        ),
                        value: dropdownValue,
                        hint: const Text('Select machinery type'),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _machineryTypeController.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select machinery type';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  // Rental/Sale Mode Selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Mode',
                      border: OutlineInputBorder(),
                      helperText:
                          'Choose whether this machinery is for rental or sale',
                    ),
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: 'rental',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16),
                            SizedBox(width: 8),
                            Text('Rental'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'sale',
                        child: Row(
                          children: [
                            Icon(Icons.shopping_cart, size: 16),
                            SizedBox(width: 8),
                            Text('For Sale'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select mode';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter model';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Expanded(
                        child: TextFormField(
                          controller: _horsepowerController,
                          decoration: const InputDecoration(
                            labelText: 'Horsepower',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter horsepower';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: _selectedType == 'rental'
                                ? 'Daily Rental Price (GHS)'
                                : 'Sale Price (GHS)',
                            border: const OutlineInputBorder(),
                            helperText: _selectedType == 'rental'
                                ? 'Price per day for rental'
                                : 'Total price for purchase',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Expanded(
                        child: TextFormField(
                          controller: _conditionController,
                          decoration: const InputDecoration(
                            labelText: 'Condition',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter condition';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value!;
                          });
                        },
                      ),
                      const Text('Available'),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),

                  // Technical Specifications Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Technical Specifications (Optional)',
                          style: AppTheme.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Basic Specs
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cabinTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Cabin Type',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _workingWeightController,
                                decoration: const InputDecoration(
                                  labelText: 'Working Weight (t)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Dimensions
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _workingLengthController,
                                decoration: const InputDecoration(
                                  labelText: 'Length (m)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _workingWidthController,
                                decoration: const InputDecoration(
                                  labelText: 'Width (m)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _workingHeightController,
                                decoration: const InputDecoration(
                                  labelText: 'Height (m)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Blade Specifications
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bladeTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Blade Type',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _bladeCapacityController,
                                decoration: const InputDecoration(
                                  labelText: 'Blade Capacity (m³)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _bladeWidthController,
                                decoration: const InputDecoration(
                                  labelText: 'Blade Width (m)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Engine Specifications
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _engineManufacturerController,
                                decoration: const InputDecoration(
                                  labelText: 'Engine Manufacturer',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _engineTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Engine Type',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _enginePowerController,
                                decoration: const InputDecoration(
                                  labelText: 'Engine Power (kW)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Additional Specs
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fuelTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Fuel Type',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _yearOfManufactureController,
                                decoration: const InputDecoration(
                                  labelText: 'Year of Manufacture',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _serialNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Serial Number',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Ripper and Track
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ripperTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Ripper Type',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: TextFormField(
                                controller: _trackWidthController,
                                decoration: const InputDecoration(
                                  labelText: 'Track Width (mm)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),

                        // Tractor-specific Specifications
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                                color:
                                    AppTheme.accentGold.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tractor Specifications',
                                style: AppTheme.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                              const SizedBox(height: AppTheme.paddingSmall),

                              // Power Specifications
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _powerKWController,
                                      decoration: const InputDecoration(
                                        labelText: 'Power (KW)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingSmall),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _powerHPController,
                                      decoration: const InputDecoration(
                                        labelText: 'Power (HP)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingSmall),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _wheelArrangementController,
                                      decoration: const InputDecoration(
                                        labelText: 'Wheel Arrangement',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.paddingSmall),

                              // Engine Details
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          _crankshaftRatedSpeedController,
                                      decoration: const InputDecoration(
                                        labelText: 'Crankshaft Speed (rpm)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingSmall),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _numberOfCylindersController,
                                      decoration: const InputDecoration(
                                        labelText: 'Number of Cylinders',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingSmall),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fuelTankCapacityController,
                                      decoration: const InputDecoration(
                                        labelText: 'Fuel Tank (litres)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.paddingSmall),

                              // Transmission and Capacity
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _numberOfGearsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Number of Gears',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingSmall),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _liftingCapacityController,
                                      decoration: const InputDecoration(
                                        labelText: 'Lifting Capacity (kg)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingSmall),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _operatingWeightController,
                                      decoration: const InputDecoration(
                                        labelText: 'Operating Weight (kg)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.paddingSmall),

                              // Tractor Dimensions
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _tractorBaseController,
                                      decoration: const InputDecoration(
                                        labelText: 'Tractor Base (m)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.paddingSmall),
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          _agrotechnicalClearanceController,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Agrotechnical Clearance (m)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Add a subtle indicator that content is scrollable
        contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed:
                _isLoading ? null : () => _saveMachinery(existingMachinery),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(existingMachinery == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _saveMachinery(Machinery? existingMachinery) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> imageUrls = existingMachinery?.imageUrls ?? [];

      // Upload image if selected
      if (_selectedImage != null) {
        _showSnackBar('Uploading image...');
        final imageUrl = await _uploadImage(_selectedImage!);
        imageUrls = [imageUrl]; // For now, replace with new image
        _showSnackBar('Image uploaded successfully!');
      }

      final machinery = Machinery(
        id: existingMachinery?.id ?? '',
        name: _nameController.text.trim(),
        type: _selectedType,
        machineryType: _machineryTypeController.text.trim(),
        model: _modelController.text.trim(),
        horsepower: int.parse(_horsepowerController.text),
        price: double.parse(_priceController.text),
        condition: _conditionController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls,
        isAvailable: _isAvailable,
        location: _locationController.text.trim(),
        createdAt: existingMachinery?.createdAt ?? DateTime.now(),
        // Technical Specifications
        cabinType: _cabinTypeController.text.trim().isEmpty
            ? null
            : _cabinTypeController.text.trim(),
        workingWeight: _workingWeightController.text.trim().isEmpty
            ? null
            : double.tryParse(_workingWeightController.text.trim()),
        workingLength: _workingLengthController.text.trim().isEmpty
            ? null
            : double.tryParse(_workingLengthController.text.trim()),
        workingWidth: _workingWidthController.text.trim().isEmpty
            ? null
            : double.tryParse(_workingWidthController.text.trim()),
        workingHeight: _workingHeightController.text.trim().isEmpty
            ? null
            : double.tryParse(_workingHeightController.text.trim()),
        trackWidth: _trackWidthController.text.trim().isEmpty
            ? null
            : double.tryParse(_trackWidthController.text.trim()),
        bladeType: _bladeTypeController.text.trim().isEmpty
            ? null
            : _bladeTypeController.text.trim(),
        bladeCapacity: _bladeCapacityController.text.trim().isEmpty
            ? null
            : double.tryParse(_bladeCapacityController.text.trim()),
        bladeWidth: _bladeWidthController.text.trim().isEmpty
            ? null
            : double.tryParse(_bladeWidthController.text.trim()),
        ripperType: _ripperTypeController.text.trim().isEmpty
            ? null
            : _ripperTypeController.text.trim(),
        engineManufacturer: _engineManufacturerController.text.trim().isEmpty
            ? null
            : _engineManufacturerController.text.trim(),
        engineType: _engineTypeController.text.trim().isEmpty
            ? null
            : _engineTypeController.text.trim(),
        enginePower: _enginePowerController.text.trim().isEmpty
            ? null
            : double.tryParse(_enginePowerController.text.trim()),
        fuelType: _fuelTypeController.text.trim().isEmpty
            ? null
            : _fuelTypeController.text.trim(),
        yearOfManufacture: _yearOfManufactureController.text.trim().isEmpty
            ? null
            : int.tryParse(_yearOfManufactureController.text.trim()),
        serialNumber: _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
        // Tractor-specific specifications
        powerKW: _powerKWController.text.trim().isEmpty
            ? null
            : double.tryParse(_powerKWController.text.trim()),
        powerHP: _powerHPController.text.trim().isEmpty
            ? null
            : double.tryParse(_powerHPController.text.trim()),
        wheelArrangement: _wheelArrangementController.text.trim().isEmpty
            ? null
            : _wheelArrangementController.text.trim(),
        crankshaftRatedSpeed:
            _crankshaftRatedSpeedController.text.trim().isEmpty
                ? null
                : int.tryParse(_crankshaftRatedSpeedController.text.trim()),
        numberOfCylinders: _numberOfCylindersController.text.trim().isEmpty
            ? null
            : int.tryParse(_numberOfCylindersController.text.trim()),
        fuelTankCapacity: _fuelTankCapacityController.text.trim().isEmpty
            ? null
            : double.tryParse(_fuelTankCapacityController.text.trim()),
        numberOfGears: _numberOfGearsController.text.trim().isEmpty
            ? null
            : _numberOfGearsController.text.trim(),
        liftingCapacity: _liftingCapacityController.text.trim().isEmpty
            ? null
            : double.tryParse(_liftingCapacityController.text.trim()),
        operatingWeight: _operatingWeightController.text.trim().isEmpty
            ? null
            : double.tryParse(_operatingWeightController.text.trim()),
        tractorBase: _tractorBaseController.text.trim().isEmpty
            ? null
            : double.tryParse(_tractorBaseController.text.trim()),
        agrotechnicalClearance: _agrotechnicalClearanceController.text
                .trim()
                .isEmpty
            ? null
            : double.tryParse(_agrotechnicalClearanceController.text.trim()),
      );

      if (existingMachinery == null) {
        await Provider.of<FirebaseService>(context, listen: false)
            .addMachinery(machinery);
      } else {
        await Provider.of<FirebaseService>(context, listen: false)
            .updateMachinery(machinery);
      }

      Navigator.pop(context);
      _showSnackBar(existingMachinery == null
          ? 'Machinery added successfully'
          : 'Machinery updated successfully');
    } catch (e) {
      _showErrorDialog(
        'Save Error',
        'Failed to save machinery. Please try again.\n\nError: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Selected image file does not exist');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'machinery/${timestamp}_${imageFile.path.split('/').last}';

      // Get storage reference
      final ref = Provider.of<FirebaseService>(context, listen: false)
          .storage
          .ref()
          .child(fileName);

      // Upload file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(imageFile, metadata);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // print('Image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showSnackBar('Image selected successfully');
      }
    } catch (e) {
      _showErrorDialog(
        'Image Selection Error',
        'Unable to select image. Please try again.\n\nError: $e',
      );
    }
  }

  void _showDeleteConfirmation(Machinery machinery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Machinery'),
        content: Text('Are you sure you want to delete ${machinery.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMachinery(machinery.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteMachinery(String machineryId) async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .deleteMachinery(machineryId);
      _showSnackBar('Machinery deleted successfully');
    } catch (e) {
      _showSnackBar('Error deleting machinery: $e');
    }
  }

  void _toggleMachineryAvailability(Machinery machinery) async {
    try {
      final updatedMachinery =
          machinery.copyWith(isAvailable: !machinery.isAvailable);
      await Provider.of<FirebaseService>(context, listen: false)
          .updateMachinery(updatedMachinery);
      _showSnackBar(
          'Machinery ${machinery.isAvailable ? 'disabled' : 'enabled'} successfully');
    } catch (e) {
      _showSnackBar('Error updating machinery: $e');
    }
  }

  void _resetForm() {
    _nameController.clear();
    _machineryTypeController.clear();
    _modelController.clear();
    _horsepowerController.clear();
    _priceController.clear();
    _conditionController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _selectedType = 'rental';
    _isAvailable = true;
    _selectedImage = null;

    // Clear technical specifications
    _cabinTypeController.clear();
    _workingWeightController.clear();
    _workingLengthController.clear();
    _workingWidthController.clear();
    _workingHeightController.clear();
    _trackWidthController.clear();
    _bladeTypeController.clear();
    _bladeCapacityController.clear();
    _bladeWidthController.clear();
    _ripperTypeController.clear();
    _engineManufacturerController.clear();
    _engineTypeController.clear();
    _enginePowerController.clear();
    _fuelTypeController.clear();
    _yearOfManufactureController.clear();
    _serialNumberController.clear();

    // Clear tractor-specific specifications
    _powerKWController.clear();
    _powerHPController.clear();
    _wheelArrangementController.clear();
    _crankshaftRatedSpeedController.clear();
    _numberOfCylindersController.clear();
    _fuelTankCapacityController.clear();
    _numberOfGearsController.clear();
    _liftingCapacityController.clear();
    _operatingWeightController.clear();
    _tractorBaseController.clear();
    _agrotechnicalClearanceController.clear();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(
              child: Text(
                title,
                style: AppTheme.heading3.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addTestMachinery() async {
    // Show confirmation dialog
    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Test Machinery'),
        content: const Text(
          'This will add 2 test machinery items:\n'
          '• 1 John Deere Tractor for Sale\n'
          '• 1 Caterpillar Dozer for Rental\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Test Data'),
          ),
        ],
      ),
    );

    if (shouldAdd != true) return;

    // First, ensure we have machinery types
    await _ensureMachineryTypes();

    // Add test machinery for sale
    final testSaleMachinery = Machinery(
      id: '', // New ID will be generated
      name: 'John Deere Tractor for Sale',
      type: 'sale',
      machineryType: 'Tractor',
      model: 'John Deere 5075E', // Actual model name
      horsepower: 150,
      price: 1000000.0, // Example price
      condition: 'New',
      description: 'This is a test tractor available for purchase.',
      imageUrls: [],
      isAvailable: true,
      location: 'Test Location',
      createdAt: DateTime.now(),
      // Technical Specifications
      cabinType: 'Cabin Type',
      workingWeight: 10.0,
      workingLength: 5.0,
      workingWidth: 2.0,
      workingHeight: 2.0,
      trackWidth: 1200.0,
      bladeType: 'Blade Type',
      bladeCapacity: 1.5,
      bladeWidth: 1.0,
      ripperType: 'Ripper Type',
      engineManufacturer: 'John Deere',
      engineType: 'PowerTech PSS',
      enginePower: 100.0,
      fuelType: 'Diesel',
      yearOfManufacture: 2023,
      serialNumber: '123456789',
      // Tractor-specific specifications
      powerKW: 100.0,
      powerHP: 150.0,
      wheelArrangement: '4WD',
      crankshaftRatedSpeed: 1500,
      numberOfCylinders: 4,
      fuelTankCapacity: 200.0,
      numberOfGears: '12F/12R',
      liftingCapacity: 1000.0,
      operatingWeight: 2000.0,
      tractorBase: 2.0,
      agrotechnicalClearance: 0.5,
    );

    // Add test machinery for rental
    final testRentalMachinery = Machinery(
      id: '', // New ID will be generated
      name: 'Caterpillar Dozer for Rental',
      type: 'rental',
      machineryType: 'Dozer',
      model: 'Caterpillar D6T', // Actual model name
      horsepower: 200,
      price: 5000.0, // Daily rental price
      condition: 'Good',
      description: 'This is a test dozer available for rental.',
      imageUrls: [],
      isAvailable: true,
      location: 'Test Location',
      createdAt: DateTime.now(),
      // Technical Specifications
      cabinType: 'ROPS/FOPS',
      workingWeight: 15.0,
      workingLength: 6.0,
      workingWidth: 2.5,
      workingHeight: 2.5,
      trackWidth: 1500.0,
      bladeType: 'Semi-U',
      bladeCapacity: 2.0,
      bladeWidth: 1.5,
      ripperType: 'Single Shank',
      engineManufacturer: 'Caterpillar',
      engineType: 'C9.3',
      enginePower: 150.0,
      fuelType: 'Diesel',
      yearOfManufacture: 2022,
      serialNumber: '987654321',
      // Tractor-specific specifications
      powerKW: 150.0,
      powerHP: 200.0,
      wheelArrangement: 'Track',
      crankshaftRatedSpeed: 1800,
      numberOfCylinders: 6,
      fuelTankCapacity: 300.0,
      numberOfGears: '6F/3R',
      liftingCapacity: 1500.0,
      operatingWeight: 3000.0,
      tractorBase: 2.5,
      agrotechnicalClearance: 0.6,
    );

    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .addMachinery(testSaleMachinery);
      await Provider.of<FirebaseService>(context, listen: false)
          .addMachinery(testRentalMachinery);
      _showSnackBar('Test machinery added successfully! (1 sale, 1 rental)');
    } catch (e) {
      _showErrorDialog(
        'Add Error',
        'Failed to add test machinery. Please try again.\n\nError: $e',
      );
    }
  }

  Future<void> _ensureMachineryTypes() async {
    try {
      final categories =
          await Provider.of<FirebaseService>(context, listen: false)
              .getCategories('machinery')
              .first;

      if (categories.isEmpty) {
        // Add default machinery types
        final defaultTypes = [
          'Tractor',
          'Dozer',
          'Excavator',
          'Loader',
          'Harvester'
        ];

        for (final type in defaultTypes) {
          final category = Category(
            id: '',
            name: type,
            type: 'machinery',
            description: 'Default machinery type',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await Provider.of<FirebaseService>(context, listen: false)
              .addCategory(category);
        }
      }
    } catch (e) {
      // print('Error ensuring machinery types: $e');
    }
  }
}
