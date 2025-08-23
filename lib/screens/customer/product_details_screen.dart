import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedQuantity = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductHeader(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildProductDetails(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildQuantitySection(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildAddToCartButton(),
                    const SizedBox(height: AppTheme.paddingLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: AppTheme.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
              ),
              child: widget.product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
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
                    )
                  : Container(
                      color: AppTheme.lightGray,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
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
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            // Back button with background
            Positioned(
              top: 50,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.product.name,
                style: AppTheme.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: widget.product.isAvailable
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.product.isAvailable
                      ? AppTheme.primaryGreen
                      : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.product.isAvailable
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: widget.product.isAvailable
                        ? AppTheme.primaryGreen
                        : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.product.isAvailable ? 'In Stock' : 'Out of Stock',
                    style: AppTheme.caption.copyWith(
                      color: widget.product.isAvailable
                          ? AppTheme.primaryGreen
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.product.category,
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'GHS ${widget.product.price.toStringAsFixed(2)}',
              style: AppTheme.heading1.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            // Text(
            //   'per ${widget.product.quantity}',
            //   style: AppTheme.bodyText.copyWith(
            //     color: AppTheme.gray,
            //     fontSize: 14,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Available: ${widget.product.quantity}',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (widget.product.description.isNotEmpty) ...[
          const SizedBox(height: AppTheme.paddingLarge),
          Text(
            'Description',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            widget.product.description,
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.gray,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _selectedQuantity > 1
                          ? () {
                              setState(() {
                                _selectedQuantity--;
                              });
                            }
                          : null,
                      icon: Icon(
                        Icons.remove,
                        color: _selectedQuantity > 1
                            ? AppTheme.primaryGreen
                            : AppTheme.gray,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                      ),
                      child: Text(
                        '$_selectedQuantity',
                        style: AppTheme.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _selectedQuantity < 10
                          ? () {
                              setState(() {
                                _selectedQuantity++;
                              });
                            }
                          : null,
                      icon: Icon(
                        Icons.add,
                        color: _selectedQuantity < 10
                            ? AppTheme.primaryGreen
                            : AppTheme.gray,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Price',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.gray,
                    ),
                  ),
                  Text(
                    'GHS ${(widget.product.price * _selectedQuantity).toStringAsFixed(2)}',
                    style: AppTheme.heading2.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.darkGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            widget.product.isAvailable && !_isLoading ? _addToCart : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart, size: 20),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    'Add to Cart',
                    style: AppTheme.bodyText.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_selectedQuantity',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please sign in to add items to cart');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if product is already in cart
      final cartItems =
          await Provider.of<FirebaseService>(context, listen: false)
              .getCart()
              .first;

      final existingItem = cartItems
          .where((item) => item.productId == widget.product.id)
          .firstOrNull;

      if (existingItem != null) {
        _showSnackBar('${widget.product.name} is already in your cart');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final cartItem = CartItem(
        id: '',
        productId: widget.product.id,
        productName: widget.product.name,
        productImage: widget.product.imageUrl,
        price: widget.product.price,
        quantity: _selectedQuantity,
        category: widget.product.category,
        addedAt: DateTime.now(),
      );

      await Provider.of<FirebaseService>(context, listen: false)
          .addToCart(user.uid, cartItem);

      if (mounted) {
        _showSnackBar('Added to cart successfully!');
      }
    } catch (e) {
      _showSnackBar('Error adding to cart: $e');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }
}
