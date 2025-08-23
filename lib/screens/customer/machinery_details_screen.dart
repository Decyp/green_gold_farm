import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/machinery.dart';
import '../../models/booking.dart';
import '../../models/purchase.dart';

class MachineryDetailsScreen extends StatefulWidget {
  final Machinery machinery;

  const MachineryDetailsScreen({
    super.key,
    required this.machinery,
  });

  @override
  State<MachineryDetailsScreen> createState() => _MachineryDetailsScreenState();
}

class _MachineryDetailsScreenState extends State<MachineryDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDuration = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMachineryImage(),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildMachineryInfo(),
                  const SizedBox(height: AppTheme.paddingLarge),
                  _buildTabBar(),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildTabBarView(),
                  const SizedBox(height: AppTheme.paddingLarge),
                  if (widget.machinery.type == 'rental') _buildBookingSection(),
                  if (widget.machinery.type == 'sale') _buildPurchaseSection(),
                  // Debug info - remove this later
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    margin: const EdgeInsets.only(top: AppTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: widget.machinery.type == 'sale'
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(
                        color: widget.machinery.type == 'sale'
                            ? Colors.green
                            : AppTheme.gray,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug: Machinery type is "${widget.machinery.type}"',
                          style: AppTheme.caption.copyWith(
                            color: widget.machinery.type == 'sale'
                                ? Colors.green
                                : AppTheme.gray,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.machinery.type == 'sale')
                          Text(
                            '✅ This should show the purchase section',
                            style: AppTheme.caption.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (widget.machinery.type == 'rental')
                          Text(
                            '📅 This should show the booking section',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: AppTheme.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Machinery Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
              ),
              child: widget.machinery.imageUrls.isNotEmpty
                  ? Image.network(
                      widget.machinery.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.agriculture,
                            size: 80,
                            color: AppTheme.gray,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.agriculture,
                        size: 80,
                        color: AppTheme.gray,
                      ),
                    ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
        title: Text(
          widget.machinery.name,
          style: AppTheme.heading2.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMachineryImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: widget.machinery.imageUrls.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: CachedNetworkImage(
                imageUrl: widget.machinery.imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.lightGray,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.lightGray,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: AppTheme.gray,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Image Not Available',
                          style: TextStyle(
                            color: AppTheme.gray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                memCacheWidth: 400,
                memCacheHeight: 400,
              ),
            )
          : Container(
              color: AppTheme.lightGray,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 60,
                      color: AppTheme.gray,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No Image Available',
                      style: TextStyle(
                        color: AppTheme.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMachineryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.machinery.name,
                style: AppTheme.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: widget.machinery.isAvailable
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : AppTheme.gray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                widget.machinery.isAvailable ? 'Available' : 'Unavailable',
                style: AppTheme.caption.copyWith(
                  color: widget.machinery.isAvailable
                      ? AppTheme.primaryGreen
                      : AppTheme.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          widget.machinery.model,
          style: AppTheme.bodyText.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Row(
          children: [
            Text(
              'GHS ${widget.machinery.price.toStringAsFixed(2)}',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            Text(
              widget.machinery.type == 'rental' ? '/day' : 'for sale',
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.gray,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppTheme.gray),
            const SizedBox(width: AppTheme.paddingSmall),
            Text(
              widget.machinery.location,
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.gray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: AppTheme.gray,
        indicatorColor: AppTheme.primaryGreen,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Specifications'),
          Tab(text: 'Images'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSpecificationsTab(),
          _buildImagesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            widget.machinery.description.isNotEmpty
                ? widget.machinery.description
                : 'No description available for this machinery.',
            style: AppTheme.bodyText,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildInfoRow('Type', widget.machinery.machineryType),
          _buildInfoRow('Model', widget.machinery.model),
          _buildInfoRow('Horsepower', '${widget.machinery.horsepower} HP'),
          _buildInfoRow('Condition', widget.machinery.condition),
          _buildInfoRow('Location', widget.machinery.location),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Specifications',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            if (widget.machinery.cabinType != null)
              _buildInfoRow('Cabin Type', widget.machinery.cabinType!),
            if (widget.machinery.workingWeight != null)
              _buildInfoRow(
                  'Working Weight', '${widget.machinery.workingWeight} t'),
            if (widget.machinery.workingLength != null)
              _buildInfoRow('Length', '${widget.machinery.workingLength} m'),
            if (widget.machinery.workingWidth != null)
              _buildInfoRow('Width', '${widget.machinery.workingWidth} m'),
            if (widget.machinery.workingHeight != null)
              _buildInfoRow('Height', '${widget.machinery.workingHeight} m'),
            if (widget.machinery.trackWidth != null)
              _buildInfoRow('Track Width', '${widget.machinery.trackWidth} mm'),
            if (widget.machinery.bladeType != null)
              _buildInfoRow('Blade Type', widget.machinery.bladeType!),
            if (widget.machinery.bladeCapacity != null)
              _buildInfoRow(
                  'Blade Capacity', '${widget.machinery.bladeCapacity} m³'),
            if (widget.machinery.bladeWidth != null)
              _buildInfoRow('Blade Width', '${widget.machinery.bladeWidth} m'),
            if (widget.machinery.ripperType != null)
              _buildInfoRow('Ripper Type', widget.machinery.ripperType!),
            if (widget.machinery.engineManufacturer != null)
              _buildInfoRow(
                  'Engine Manufacturer', widget.machinery.engineManufacturer!),
            if (widget.machinery.engineType != null)
              _buildInfoRow('Engine Type', widget.machinery.engineType!),
            if (widget.machinery.enginePower != null)
              _buildInfoRow(
                  'Engine Power', '${widget.machinery.enginePower} kW'),
            if (widget.machinery.fuelType != null)
              _buildInfoRow('Fuel Type', widget.machinery.fuelType!),
            if (widget.machinery.yearOfManufacture != null)
              _buildInfoRow('Year of Manufacture',
                  '${widget.machinery.yearOfManufacture}'),
            if (widget.machinery.serialNumber != null)
              _buildInfoRow('Serial Number', widget.machinery.serialNumber!),
            // Tractor-specific specifications
            if (widget.machinery.powerKW != null)
              _buildInfoRow('Power (KW)', '${widget.machinery.powerKW}'),
            if (widget.machinery.powerHP != null)
              _buildInfoRow('Power (HP)', '${widget.machinery.powerHP}'),
            if (widget.machinery.wheelArrangement != null)
              _buildInfoRow(
                  'Wheel Arrangement', widget.machinery.wheelArrangement!),
            if (widget.machinery.crankshaftRatedSpeed != null)
              _buildInfoRow('Crankshaft Speed',
                  '${widget.machinery.crankshaftRatedSpeed} rpm'),
            if (widget.machinery.numberOfCylinders != null)
              _buildInfoRow('Number of Cylinders',
                  '${widget.machinery.numberOfCylinders}'),
            if (widget.machinery.fuelTankCapacity != null)
              _buildInfoRow('Fuel Tank Capacity',
                  '${widget.machinery.fuelTankCapacity} litres'),
            if (widget.machinery.numberOfGears != null)
              _buildInfoRow('Number of Gears', widget.machinery.numberOfGears!),
            if (widget.machinery.liftingCapacity != null)
              _buildInfoRow(
                  'Lifting Capacity', '${widget.machinery.liftingCapacity} kg'),
            if (widget.machinery.operatingWeight != null)
              _buildInfoRow(
                  'Operating Weight', '${widget.machinery.operatingWeight} kg'),
            if (widget.machinery.tractorBase != null)
              _buildInfoRow(
                  'Tractor Base', '${widget.machinery.tractorBase} m'),
            if (widget.machinery.agrotechnicalClearance != null)
              _buildInfoRow('Agrotechnical Clearance',
                  '${widget.machinery.agrotechnicalClearance} m'),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesTab() {
    if (widget.machinery.imageUrls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: AppTheme.cardDecoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image,
                size: 60,
                color: AppTheme.gray,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                'No images available',
                style: AppTheme.bodyText,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Machinery Images',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.machinery.imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: AppTheme.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Image.network(
                      widget.machinery.imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: AppTheme.gray,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTheme.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.gray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book This Machinery',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Text(
                'Duration:',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              DropdownButton<int>(
                value: _selectedDuration,
                items: [1, 3, 7, 14, 30].map((days) {
                  return DropdownMenuItem(
                    value: days,
                    child: Text('$days ${days == 1 ? 'day' : 'days'}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Total Price: GHS ${(widget.machinery.price * _selectedDuration).toStringAsFixed(2)}',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.machinery.isAvailable && !_isLoading
                  ? _bookMachinery
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: AppTheme.paddingSmall),
                        Text(
                          'Book for $_selectedDuration ${_selectedDuration == 1 ? 'day' : 'days'}',
                          style: AppTheme.bodyText.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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

  Widget _buildPurchaseSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase This Machinery',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Price: GHS ${widget.machinery.price.toStringAsFixed(2)}',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.machinery.isAvailable && !_isLoading
                  ? _purchaseMachinery
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart),
                        const SizedBox(width: AppTheme.paddingSmall),
                        Text(
                          'Purchase for GHS ${widget.machinery.price.toStringAsFixed(2)}',
                          style: AppTheme.bodyText.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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

  void _bookMachinery() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please sign in to book machinery');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user information
      final userName = user.displayName ?? 'Unknown User';
      final userEmail = user.email ?? '';

      // Calculate total amount
      final totalAmount = widget.machinery.price * _selectedDuration;

      // Calculate dates
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: _selectedDuration));

      final booking = Booking(
        id: '', // Will be generated by Firebase
        userId: user.uid,
        userName: userName,
        userEmail: userEmail,
        machineryId: widget.machinery.id,
        machineryName: widget.machinery.name,
        machineryType: widget.machinery.machineryType,
        machineryModel: widget.machinery.model,
        dailyRate: widget.machinery.price,
        duration: _selectedDuration,
        totalAmount: totalAmount,
        startDate: startDate,
        endDate: endDate,
        status: 'pending',
        notes: null,
        phoneNumber: '', // Could be added to user profile later
        deliveryAddress: '', // Could be added to user profile later
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      await Provider.of<FirebaseService>(context, listen: false)
          .createBooking(booking);

      if (mounted) {
        _showSnackBar('Booking request sent successfully!');
        Navigator.pop(context); // Go back to machinery list
      }
    } catch (e) {
      _showSnackBar('Error booking machinery: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _purchaseMachinery() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please sign in to purchase machinery');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userName = user.displayName ?? 'Unknown User';
      final userEmail = user.email ?? '';

      final purchase = Purchase(
        id: '', // Will be generated by Firebase
        userId: user.uid,
        userName: userName,
        userEmail: userEmail,
        machineryId: widget.machinery.id,
        machineryName: widget.machinery.name,
        machineryType: widget.machinery.machineryType,
        machineryModel: widget.machinery.model,
        price: widget.machinery.price,
        status: 'pending',
        notes: null,
        phoneNumber: '', // Could be added to user profile later
        deliveryAddress: '', // Could be added to user profile later
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      await Provider.of<FirebaseService>(context, listen: false)
          .createPurchase(purchase);

      if (mounted) {
        _showSnackBar('Purchase request sent successfully!');
        Navigator.pop(context); // Go back to machinery list
      }
    } catch (e) {
      _showSnackBar('Error purchasing machinery: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
