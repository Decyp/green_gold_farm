import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/cart_item.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your cart'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: Provider.of<FirebaseService>(context, listen: false).getCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: AppTheme.gray),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text('Error loading cart', style: AppTheme.heading3),
                ],
              ),
            );
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return _buildCartItemCard(cartItems[index]);
                  },
                ),
              ),
              _buildCheckoutSection(cartItems),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppTheme.gray,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          Text(
            'Your cart is empty',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Add some products to get started',
            style: AppTheme.bodyText.copyWith(color: AppTheme.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: cartItem.productImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      child: Image.network(
                        cartItem.productImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            color: AppTheme.gray,
                            size: 40,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.image,
                      color: AppTheme.gray,
                      size: 40,
                    ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.productName,
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    cartItem.category,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    'GHS ${cartItem.totalPrice.toStringAsFixed(2)}',
                    style: AppTheme.bodyText.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _updateQuantity(cartItem, -1),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.primaryGreen,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(cartItem, 1),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.primaryGreen,
                    ),
                  ],
                ),
                Text(
                  'GHS ${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(List<CartItem> cartItems) {
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final tax = subtotal * 0.05; // 5% tax
    final shipping = subtotal > 100 ? 0.0 : 10.0; // Free shipping over GHS 100
    final total = subtotal + tax + shipping;

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTheme.bodyText),
              Text(
                'GHS ${subtotal.toStringAsFixed(2)}',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax (5%)', style: AppTheme.bodyText),
              Text(
                'GHS ${tax.toStringAsFixed(2)}',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: AppTheme.bodyText),
              Text(
                shipping == 0 ? 'Free' : 'GHS ${shipping.toStringAsFixed(2)}',
                style: AppTheme.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: shipping == 0 ? AppTheme.primaryGreen : null,
                ),
              ),
            ],
          ),
          const Divider(height: AppTheme.paddingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTheme.heading3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'GHS ${total.toStringAsFixed(2)}',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(cartItems, total),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Proceed to Checkout (${cartItems.length} items)',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(CartItem cartItem, int change) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newQuantity = cartItem.quantity + change;
    if (newQuantity <= 0) {
      // Remove item from cart
      await Provider.of<FirebaseService>(context, listen: false)
          .removeFromCart(user.uid, cartItem.id);
    } else {
      // Update quantity
      await Provider.of<FirebaseService>(context, listen: false)
          .updateCartItemQuantity(user.uid, cartItem.id, newQuantity);
    }
  }

  void _proceedToCheckout(List<CartItem> cartItems, double total) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: cartItems,
          total: total,
        ),
      ),
    );
  }
}
