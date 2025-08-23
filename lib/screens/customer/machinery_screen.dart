import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/machinery.dart';
import '../../models/booking.dart';
import '../../models/purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MachineryScreen extends StatefulWidget {
  const MachineryScreen({super.key});

  @override
  State<MachineryScreen> createState() => _MachineryScreenState();
}

class _MachineryScreenState extends State<MachineryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'rental';
  String _selectedMachineType = '';
  String _location = '';
  DateTime? _selectedDate;
  String _selectedDuration = '1_day';
  bool _isCheckingAvailability = false;
  bool _isBooking = false;

  final TextEditingController _locationController = TextEditingController();

  final Map<String, String> _durationOptions = {
    '1_day': '1 Day',
    '3_days': '3 Days',
    '1_week': '1 Week',
    '2_weeks': '2 Weeks',
    '1_month': '1 Month',
  };

  // Dynamic pricing from Firebase
  final Map<String, double> _baseCosts = {};
  Map<String, double> _durationMultipliers = {
    '1_day': 1.0,
    '3_days': 2.5,
    '1_week': 5.0,
    '2_weeks': 9.0,
    '1_month': 18.0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedType = _tabController.index == 0 ? 'rental' : 'sale';
      });
    });
    _loadPricing();
  }

  void _loadPricing() async {
    try {
      final pricingList =
          await Provider.of<FirebaseService>(context, listen: false)
              .getPricing()
              .first;

      setState(() {
        for (final pricing in pricingList) {
          _baseCosts[pricing.machineType] = pricing.basePrice;
          _durationMultipliers = pricing.durationMultipliers;
        }
      });
    } catch (e) {
      // print('Error loading pricing: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machinery'),
      ),
      body: Column(
        children: [
          _buildTypeTabs(),
          if (_selectedType == 'rental') _buildRentalSection(),
          if (_selectedType == 'sale') _buildSaleSection(),
        ],
      ),
    );
  }

  Widget _buildTypeTabs() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.gray,
        labelStyle: AppTheme.bodyText.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: AppTheme.bodyText.copyWith(
          fontSize: 16,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Rental'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('For Sale'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalSection() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildBookingCard(),
            _buildMachineryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.agriculture,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Book Machinery',
                style: AppTheme.heading3,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Machine Type Dropdown
          StreamBuilder<List<String>>(
            stream: Provider.of<FirebaseService>(context, listen: false)
                .getMachineTypes(),
            builder: (context, snapshot) {
              final machineTypes = snapshot.data ?? [];

              // Ensure selected value is valid
              String? validSelectedValue;
              if (machineTypes.isNotEmpty) {
                if (_selectedMachineType.isEmpty ||
                    !machineTypes.contains(_selectedMachineType)) {
                  validSelectedValue = machineTypes.first;
                  _selectedMachineType = machineTypes.first;
                } else {
                  validSelectedValue = _selectedMachineType;
                }
              }

              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Machine Type',
                  prefixIcon: Icon(Icons.agriculture),
                  border: OutlineInputBorder(),
                ),
                value: validSelectedValue,
                items: machineTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: machineTypes.isNotEmpty
                    ? (value) {
                        setState(() {
                          _selectedMachineType = value!;
                        });
                      }
                    : null,
                hint: snapshot.connectionState == ConnectionState.waiting
                    ? const Text('Loading machine types...')
                    : machineTypes.isEmpty
                        ? const Text('No machine types available')
                        : const Text('Select Machine Type'),
              );
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Location Input
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _location = value;
              });
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Date Picker
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.gray),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.gray),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    _selectedDate != null
                        ? 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                    style: AppTheme.bodyText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Duration Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Rental Duration',
              prefixIcon: Icon(Icons.schedule),
              border: OutlineInputBorder(),
            ),
            value: _selectedDuration,
            items: _durationOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDuration = value!;
              });
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Price Display
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Cost',
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _baseCosts.containsKey(_selectedMachineType)
                          ? 'GHS ${_calculateEstimatedCost().toStringAsFixed(2)}'
                          : 'Contact for pricing',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                  '${_durationOptions[_selectedDuration]} rental',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.gray,
                  ),
                ),
                if (_baseCosts.containsKey(_selectedMachineType) &&
                    _durationMultipliers[_selectedDuration]! <
                        _getMaxMultiplier())
                  Text(
                    'Discount applied for longer rental',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (!_baseCosts.containsKey(_selectedMachineType))
                  Text(
                    'Pricing not configured for this machine type',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.gray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Check Availability Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingAvailability ? null : _checkAvailability,
              icon: _isCheckingAvailability
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_isCheckingAvailability
                  ? 'Checking...'
                  : 'Check Availability'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleSection() {
    return Expanded(
      child: _buildMachineryList(),
    );
  }

  Widget _buildMachineryList() {
    return StreamBuilder<List<Machinery>>(
      stream: Provider.of<FirebaseService>(context, listen: false)
          .getMachinery(type: _selectedType, availableOnly: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingList();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final machinery = snapshot.data ?? [];

        if (machinery.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
          child: Column(
            children: [
              ...machinery
                  .map((machine) => _buildMachineryCard(machine))
                  ,
            ],
          ),
        );
      },
    );
  }

  Widget _buildMachineryCard(Machinery machinery) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: () {
            _showMachineryDetails(machinery);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Row(
              children: [
                // Machinery Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: machinery.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          child: CachedNetworkImage(
                            imageUrl: machinery.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.agriculture,
                                color: AppTheme.gray,
                                size: 30,
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.agriculture,
                            color: AppTheme.gray,
                            size: 30,
                          ),
                        ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                // Machinery Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machinery.name,
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text(
                        machinery.model,
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text(
                        '${machinery.horsepower} HP',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text(
                        'GHS ${machinery.price.toStringAsFixed(2)}',
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Button
                Column(
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.gray,
                      size: 16,
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: machinery.isAvailable
                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                            : AppTheme.gray.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
          decoration: AppTheme.cardDecoration,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.gray,
            size: 60,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Failed to load machinery',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Please check your connection and try again',
            style: AppTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.agriculture, size: 60, color: AppTheme.gray),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'No ${_selectedType == 'rental' ? 'rental' : 'sale'} machinery available',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Check back later for new equipment',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _checkAvailability() async {
    if (_selectedMachineType.isEmpty ||
        _location.isEmpty ||
        _selectedDate == null) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (!_baseCosts.containsKey(_selectedMachineType)) {
      _showSnackBar(
          'Pricing not configured for this machine type. Please contact admin.');
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
    });

    try {
      // Get existing bookings for the selected machine type and date
      final bookings =
          await Provider.of<FirebaseService>(context, listen: false)
              .getAllBookings()
              .first;

      // Check for conflicts
      final conflictingBookings = bookings.where((booking) {
        // Check if booking is for the same machine type
        if (booking.machineryType != _selectedMachineType) return false;

        // Check if booking date conflicts with selected date
        final bookingDate = booking.startDate;
        final selectedDate = _selectedDate!;

        // Check if dates overlap (same day or within duration)
        return bookingDate.year == selectedDate.year &&
            bookingDate.month == selectedDate.month &&
            bookingDate.day == selectedDate.day;
      }).toList();

      setState(() {
        _isCheckingAvailability = false;
      });

      // Show availability result
      _showAvailabilityDialog(conflictingBookings.isEmpty);
    } catch (e) {
      setState(() {
        _isCheckingAvailability = false;
      });
      _showSnackBar('Error checking availability: $e');
    }
  }

  void _showAvailabilityDialog(bool isAvailable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAvailable ? 'Available!' : 'Not Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Machine Type: $_selectedMachineType'),
            Text('Location: $_location'),
            Text(
                'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            Text('Duration: ${_durationOptions[_selectedDuration]}'),
            const SizedBox(height: AppTheme.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: isAvailable
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle : Icons.cancel,
                    color: isAvailable ? AppTheme.primaryGreen : Colors.red,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Expanded(
                    child: Text(
                      isAvailable
                          ? 'Available for booking!'
                          : 'Machine is already booked for this date',
                      style: AppTheme.bodyText.copyWith(
                        color: isAvailable ? AppTheme.primaryGreen : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isAvailable) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                'Estimated Cost: GHS ${_calculateEstimatedCost().toStringAsFixed(2)}',
                style: AppTheme.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing Breakdown:',
                      style: AppTheme.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Base Rate: GHS ${_baseCosts[_selectedMachineType]}/day',
                      style: AppTheme.caption,
                    ),
                    Text(
                      'Duration: ${_durationOptions[_selectedDuration]}',
                      style: AppTheme.caption,
                    ),
                    if (_durationMultipliers[_selectedDuration]! <
                        _getMaxMultiplier())
                      Text(
                        'Discount: ${_calculateDiscountPercentage()}% off',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (isAvailable)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bookMachinery();
              },
              child: const Text('Book Now'),
            ),
        ],
      ),
    );
  }

  double _calculateEstimatedCost() {
    final baseCost = _baseCosts[_selectedMachineType] ?? 500.0;
    final multiplier = _durationMultipliers[_selectedDuration] ?? 1.0;

    return (baseCost * multiplier).roundToDouble();
  }

  double _getMaxMultiplier() {
    return _durationMultipliers.values.reduce((a, b) => a > b ? a : b);
  }

  double _calculateDiscountPercentage() {
    final baseCost = _baseCosts[_selectedMachineType] ?? 500.0;
    final multiplier = _durationMultipliers[_selectedDuration] ?? 1.0;
    final maxMultiplier = _getMaxMultiplier();

    if (multiplier == maxMultiplier) {
      return 0.0;
    }

    final discountMultiplier = maxMultiplier / multiplier;
    final discountPercentage = (1 - discountMultiplier) * 100;
    return discountPercentage.roundToDouble();
  }

  void _purchaseMachinery() async {
    setState(() {
      _isBooking = true;
    });

    try {
      // Get user information
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Please sign in to purchase machinery');
        setState(() {
          _isBooking = false;
        });
        return;
      }

      // Show purchase form dialog
      final purchaseData = await _showPurchaseDialog();
      if (purchaseData == null) {
        setState(() {
          _isBooking = false;
        });
        return;
      }

      // Create purchase object
      final purchase = Purchase(
        id: '', // Will be generated by Firebase
        userId: user.uid,
        userName: user.displayName ?? 'Unknown User',
        userEmail: user.email ?? '',
        machineryId:
            '', // We'll use a placeholder since we're purchasing by type
        machineryName: _selectedMachineType,
        machineryType: _selectedMachineType,
        machineryModel: _selectedMachineType,
        price: _baseCosts[_selectedMachineType] ?? 5000.0,
        status: 'pending',
        notes: purchaseData['notes'] ?? '',
        phoneNumber: purchaseData['phoneNumber'] ?? '',
        deliveryAddress: purchaseData['deliveryAddress'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create purchase in Firebase
      await Provider.of<FirebaseService>(context, listen: false)
          .createPurchase(purchase);

      setState(() {
        _isBooking = false;
      });

      _showSnackBar('Purchase request submitted! We will contact you soon.');

      // Reset form
      setState(() {
        _selectedMachineType = '';
        _location = '';
        _selectedDate = null;
        _selectedDuration = '1_day';
        _locationController.clear();
      });
    } catch (e) {
      setState(() {
        _isBooking = false;
      });
      _showSnackBar('Purchase failed: $e');
    }
  }

  Future<Map<String, String>?> _showPurchaseDialog() async {
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Machinery'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isEmpty ||
                  addressController.text.isEmpty) {
                _showSnackBar('Please fill in all required fields');
                return;
              }
              Navigator.pop(context, {
                'phoneNumber': phoneController.text,
                'deliveryAddress': addressController.text,
                'notes': notesController.text,
              });
            },
            child: const Text('Submit Purchase'),
          ),
        ],
      ),
    );
  }

  void _bookMachinery() async {
    if (_selectedMachineType.isEmpty ||
        _location.isEmpty ||
        _selectedDate == null) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Get user information
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Please sign in to book machinery');
        setState(() {
          _isBooking = false;
        });
        return;
      }

      // Calculate duration in days
      int durationDays = 1;
      switch (_selectedDuration) {
        case '1_day':
          durationDays = 1;
          break;
        case '3_days':
          durationDays = 3;
          break;
        case '1_week':
          durationDays = 7;
          break;
        case '2_weeks':
          durationDays = 14;
          break;
        case '1_month':
          durationDays = 30;
          break;
      }

      // Calculate end date
      final endDate = _selectedDate!.add(Duration(days: durationDays));

      // Create booking object
      final booking = Booking(
        id: '', // Will be generated by Firebase
        userId: user.uid,
        userName: user.displayName ?? 'Unknown User',
        userEmail: user.email ?? '',
        machineryId: '', // We'll use a placeholder since we're booking by type
        machineryName: _selectedMachineType,
        machineryType: _selectedMachineType,
        machineryModel: _selectedMachineType,
        dailyRate: _baseCosts[_selectedMachineType] ?? 500.0,
        duration: durationDays,
        totalAmount: _calculateEstimatedCost(),
        startDate: _selectedDate!,
        endDate: endDate,
        status: 'pending',
        notes: 'Booked through machinery rental screen',
        phoneNumber: '', // Could be added to the form
        deliveryAddress: _location,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create booking in Firebase
      await Provider.of<FirebaseService>(context, listen: false)
          .createBooking(booking);

      setState(() {
        _isBooking = false;
      });

      _showSnackBar('Booking successful! We will contact you soon.');

      // Reset form
      setState(() {
        _selectedMachineType = '';
        _location = '';
        _selectedDate = null;
        _selectedDuration = '1_day';
        _locationController.clear();
      });
    } catch (e) {
      setState(() {
        _isBooking = false;
      });
      _showSnackBar('Booking failed: $e');
    }
  }

  void _showMachineryDetails(Machinery machinery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMachineryDetailsSheet(machinery),
    );
  }

  Widget _buildMachineryDetailsSheet(Machinery machinery) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXLarge),
          topRight: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppTheme.paddingMedium),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.gray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machinery.name,
                    style: AppTheme.heading2,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  // Image carousel placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: machinery.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLarge),
                            child: CachedNetworkImage(
                              imageUrl: machinery.imageUrls.first,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.agriculture,
                              color: AppTheme.gray,
                              size: 60,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  _buildDetailRow('Model', machinery.model),
                  _buildDetailRow('Horsepower', '${machinery.horsepower} HP'),
                  _buildDetailRow('Condition', machinery.condition),
                  _buildDetailRow('Location', machinery.location),
                  _buildDetailRow(
                      'Price', 'GHS ${machinery.price.toStringAsFixed(2)}'),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text(
                    'Description',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    machinery.description,
                    style: AppTheme.bodyText,
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isBooking
                          ? null
                          : () {
                              Navigator.pop(context);
                              if (_selectedType == 'rental') {
                                _bookMachinery();
                              } else {
                                _purchaseMachinery();
                              }
                            },
                      child: _isBooking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.white,
                              ),
                            )
                          : Text(
                              _selectedType == 'rental'
                                  ? 'Book Now'
                                  : 'Purchase',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.caption,
          ),
          Text(
            value,
            style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }
}
