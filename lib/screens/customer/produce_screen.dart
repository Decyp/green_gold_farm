import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../models/cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import '../../widgets/notification_badge.dart';
import 'notifications_screen.dart';

class ProduceScreen extends StatefulWidget {
  const ProduceScreen({super.key});

  @override
  State<ProduceScreen> createState() => _ProduceScreenState();
}

class _ProduceScreenState extends State<ProduceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = '';
  List<Category> _categories = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter variables
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedFilterCategory = '';
  bool _showFilters = false;
  final List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 1, vsync: this); // Start with 1 for 'All'
    _loadCategories();
    _ensureDefaultCategories();
  }

  void _loadCategories() {
    Provider.of<FirebaseService>(context, listen: false)
        .getCategories('product')
        .listen((categories) {
      print('DEBUG: Loaded categories:');
      for (final c in categories) {
        print(
            '  - name: \'${c.name}\', type: \'${c.type}\', isActive: ${c.isActive}');
      }
      setState(() {
        _categories = categories;
        // Dispose the old controller before creating a new one
        _tabController.dispose();
        _tabController =
            TabController(length: _categories.length + 1, vsync: this);
        _selectedCategory = '';
        _tabController.addListener(() {
          setState(() {
            if (_tabController.index == 0) {
              _selectedCategory = '';
            } else {
              _selectedCategory = _categories[_tabController.index - 1].name;
            }
          });
        });
      });
    });
  }

  void _ensureDefaultCategories() async {
    try {
      final categories =
          await Provider.of<FirebaseService>(context, listen: false)
              .getCategories('product')
              .first;

      if (categories.isEmpty) {
        // Add default categories
        final defaultCategories = [
          'Vegetables',
          'Fruits',
          'Grains',
          'Dairy',
          'Meat',
        ];

        for (final categoryName in defaultCategories) {
          final category = Category(
            id: '',
            name: categoryName,
            type: 'product',
            description: 'Default product category',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await Provider.of<FirebaseService>(context, listen: false)
              .addCategory(category);
        }
      }
    } catch (e) {
      // print('Error ensuring default categories: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Produce'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          StreamBuilder<List<CartItem>>(
            stream:
                Provider.of<FirebaseService>(context, listen: false).getCart(),
            builder: (context, snapshot) {
              final cartItems = snapshot.data ?? [];
              final itemCount =
                  cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(
                _showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            NotificationBadge(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            _buildSearchBar(),
            if (_showFilters) _buildFilterSection(),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildCategoryTabs(),
            const SizedBox(height: AppTheme.paddingMedium),
            Expanded(
              child: _buildProductList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
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
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.gray),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.gray),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingSmall,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Clear All',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Category Filter
          Text(
            'Category',
            style: AppTheme.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilterChip(
                      'All Categories', '', _selectedFilterCategory.isEmpty);
                }
                final category = _categories[index - 1];
                return _buildFilterChip(category.name, category.name,
                    _selectedFilterCategory == category.name);
              },
            ),
          ),

          const SizedBox(height: AppTheme.paddingLarge),

          // Price Range Filter
          Text(
            'Price Range',
            style: AppTheme.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppTheme.primaryGreen,
            inactiveColor: AppTheme.lightGray,
            labels: RangeLabels(
              'GHS ${_priceRange.start.round()}',
              'GHS ${_priceRange.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GHS ${_priceRange.start.round()}',
                style: AppTheme.caption.copyWith(color: AppTheme.gray),
              ),
              Text(
                'GHS ${_priceRange.end.round()}',
                style: AppTheme.caption.copyWith(color: AppTheme.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: AppTheme.paddingSmall),
      child: FilterChip(
        label: Text(
          label,
          style: AppTheme.caption.copyWith(
            color: isSelected ? AppTheme.white : AppTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilterCategory = selected ? value : '';
          });
        },
        backgroundColor: AppTheme.lightGray,
        selectedColor: AppTheme.primaryGreen,
        checkmarkColor: AppTheme.white,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.lightGray,
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedFilterCategory = '';
      _priceRange = const RangeValues(0, 1000);
    });
  }

  Widget _buildCategoryTabs() {
    if (_categories.isEmpty) {
      // Show a loading indicator instead of just 'All Products'
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
        height: 50,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      height: 50,
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
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.gray,
        labelStyle: AppTheme.bodyText.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: AppTheme.bodyText.copyWith(fontSize: 16),
        tabs: [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('All'),
            ),
          ),
          ..._categories.map((category) => Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(category.name),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: Provider.of<FirebaseService>(context, listen: false).getProducts(
          category: _selectedCategory.isNotEmpty ? _selectedCategory : null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final products = snapshot.data ?? [];

        // Apply filters
        final filteredProducts = products.where((product) {
          // Search filter
          if (_searchQuery.isNotEmpty) {
            final matchesSearch = product.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                product.category
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
            if (!matchesSearch) return false;
          }

          // Category filter
          if (_selectedFilterCategory.isNotEmpty) {
            if (product.category != _selectedFilterCategory) return false;
          }

          // Price range filter
          if (product.price < _priceRange.start ||
              product.price > _priceRange.end) {
            return false;
          }

          return true;
        }).toList();

        if (filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
          child: Column(
            children: [
              if (_showFilters || _searchQuery.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: Row(
                    children: [
                      Text(
                        '${filteredProducts.length} products found',
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.gray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (_showFilters || _searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text(
                            'Clear filters',
                            style: AppTheme.bodyText.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(
                    left: AppTheme.paddingMedium,
                    right: AppTheme.paddingMedium,
                    bottom: AppTheme.paddingLarge,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppTheme.paddingMedium,
                    mainAxisSpacing: AppTheme.paddingMedium,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(filteredProducts[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badges
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusLarge),
                        topRight: Radius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppTheme.radiusLarge),
                              topRight: Radius.circular(AppTheme.radiusLarge),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl,
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
                                        color: AppTheme.gray,
                                        size: 24,
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'No Image',
                                        style: TextStyle(
                                          color: AppTheme.gray,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              memCacheWidth: 300,
                              memCacheHeight: 300,
                            ),
                          )
                        : Container(
                            color: AppTheme.lightGray,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: AppTheme.gray,
                                    size: 24,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'No Image',
                                    style: TextStyle(
                                      color: AppTheme.gray,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  // Top-right badges
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Column(
                      children: [
                        // Fresh badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FRESH',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Rating badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppTheme.white,
                                size: 8,
                              ),
                              const SizedBox(width: 1),
                              const Text(
                                '4.5',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // TODO: Add to favorites functionality
                        },
                        icon: const Icon(
                          Icons.favorite_border,
                          color: AppTheme.gray,
                          size: 12,
                        ),
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Details
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Product name
                    Text(
                      product.name,
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Quantity and unit
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: AppTheme.gray,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.quantity,
                          style: AppTheme.caption.copyWith(
                            fontSize: 8,
                            color: AppTheme.gray,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price and Add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GHS ${product.price.toStringAsFixed(2)}',
                                style: AppTheme.bodyText.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              // Text(
                              //   'per unit',R
                              //   style: AppTheme.caption.copyWith(
                              //     fontSize: 6,
                              //     color: AppTheme.gray,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryGreen,
                                AppTheme.darkGreen,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: 0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _addToCart(product);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppTheme.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_shopping_cart,
                                  size: 10,
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.paddingMedium,
        mainAxisSpacing: AppTheme.paddingMedium,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
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
            'Failed to load products',
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
          const Icon(
            Icons.shopping_basket,
            color: AppTheme.gray,
            size: 60,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'No products available',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Check back later for fresh produce',
            style: AppTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to add items to cart'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check if product is already in cart
    try {
      final cartItems =
          await Provider.of<FirebaseService>(context, listen: false)
              .getCart()
              .first;

      final existingItem =
          cartItems.where((item) => item.productId == product.id).firstOrNull;

      if (existingItem != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} is already in your cart'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: AppTheme.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }
    } catch (e) {
      // print('Error checking cart: $e');
    }

    final cartItem = CartItem(
      id: '',
      productId: product.id,
      productName: product.name,
      productImage: product.imageUrl,
      price: product.price,
      quantity: 1,
      category: product.category,
      addedAt: DateTime.now(),
    );

    Provider.of<FirebaseService>(context, listen: false)
        .addToCart(user.uid, cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }
}
