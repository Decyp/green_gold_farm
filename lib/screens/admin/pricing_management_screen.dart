import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/pricing.dart';

class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  State<PricingManagementScreen> createState() =>
      _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _machineTypeController = TextEditingController();
  final _basePriceController = TextEditingController();

  Map<String, double> _durationMultipliers = {
    '1_day': 1.0,
    '3_days': 2.5,
    '1_week': 5.0,
    '2_weeks': 9.0,
    '1_month': 18.0,
  };

  bool _isLoading = false;

  @override
  void dispose() {
    _machineTypeController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPricingDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<Pricing>>(
        stream:
            Provider.of<FirebaseService>(context, listen: false).getPricing(),
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
                  Text('Error loading pricing', style: AppTheme.heading3),
                ],
              ),
            );
          }

          final pricingList = snapshot.data ?? [];

          if (pricingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.price_change,
                      size: 60, color: AppTheme.gray),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text('No pricing configured', style: AppTheme.heading3),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text('Add pricing for machinery rentals',
                      style: AppTheme.caption),
                  const SizedBox(height: AppTheme.paddingLarge),
                  ElevatedButton(
                    onPressed: () => _showAddPricingDialog(),
                    child: const Text('Add Pricing'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: pricingList.length,
            itemBuilder: (context, index) {
              final pricing = pricingList[index];
              return _buildPricingCard(pricing);
            },
          );
        },
      ),
    );
  }

  Widget _buildPricingCard(Pricing pricing) {
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
                        pricing.machineType,
                        style: AppTheme.heading3,
                      ),
                      Text(
                        'GHS ${pricing.basePrice.toStringAsFixed(2)}/day',
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditPricingDialog(pricing);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(pricing);
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
            Text(
              'Duration Discounts:',
              style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Wrap(
              spacing: AppTheme.paddingSmall,
              children: pricing.durationMultipliers.entries.map((entry) {
                final duration = entry.key;
                final multiplier = entry.value;
                final discount = _calculateDiscount(multiplier);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '${_formatDuration(duration)}: ${discount > 0 ? '$discount% off' : 'Full price'}',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPricingDialog() {
    _resetForm();
    _showPricingDialog(null);
  }

  void _showEditPricingDialog(Pricing pricing) {
    _machineTypeController.text = pricing.machineType;
    _basePriceController.text = pricing.basePrice.toString();
    _durationMultipliers = Map.from(pricing.durationMultipliers);
    _showPricingDialog(pricing);
  }

  void _showPricingDialog(Pricing? existingPricing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingPricing == null ? 'Add Pricing' : 'Edit Pricing'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _machineTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Machine Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter machine type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                TextFormField(
                  controller: _basePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Base Price (GHS/day)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter base price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'Duration Multipliers:',
                  style:
                      AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                ..._durationMultipliers.entries.map((entry) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_formatDuration(entry.key)),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: entry.value.toString(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final doubleValue = double.tryParse(value);
                              if (doubleValue != null) {
                                setState(() {
                                  _durationMultipliers[entry.key] = doubleValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _savePricing(existingPricing),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(existingPricing == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _savePricing(Pricing? existingPricing) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final pricing = Pricing(
        id: existingPricing?.id ?? '',
        machineType: _machineTypeController.text.trim(),
        basePrice: double.parse(_basePriceController.text),
        durationMultipliers: _durationMultipliers,
        isActive: true,
        createdAt: existingPricing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existingPricing == null) {
        await Provider.of<FirebaseService>(context, listen: false)
            .addPricing(pricing);
      } else {
        await Provider.of<FirebaseService>(context, listen: false)
            .updatePricing(pricing);
      }

      Navigator.pop(context);
      _showSnackBar(existingPricing == null
          ? 'Pricing added successfully'
          : 'Pricing updated successfully');
    } catch (e) {
      _showSnackBar('Error saving pricing: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(Pricing pricing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pricing'),
        content: Text(
            'Are you sure you want to delete pricing for ${pricing.machineType}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePricing(pricing.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePricing(String pricingId) async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .deletePricing(pricingId);
      _showSnackBar('Pricing deleted successfully');
    } catch (e) {
      _showSnackBar('Error deleting pricing: $e');
    }
  }

  void _resetForm() {
    _machineTypeController.clear();
    _basePriceController.clear();
    _durationMultipliers = {
      '1_day': 1.0,
      '3_days': 2.5,
      '1_week': 5.0,
      '2_weeks': 9.0,
      '1_month': 18.0,
    };
  }

  String _formatDuration(String duration) {
    switch (duration) {
      case '1_day':
        return '1 Day';
      case '3_days':
        return '3 Days';
      case '1_week':
        return '1 Week';
      case '2_weeks':
        return '2 Weeks';
      case '1_month':
        return '1 Month';
      default:
        return duration;
    }
  }

  double _calculateDiscount(double multiplier) {
    final maxMultiplier =
        _durationMultipliers.values.reduce((a, b) => a > b ? a : b);
    if (multiplier == maxMultiplier) return 0.0;
    final discountMultiplier = maxMultiplier / multiplier;
    return ((1 - discountMultiplier) * 100).roundToDouble();
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
}
