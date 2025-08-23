import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildShippingForm(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildPaymentMethod(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildOrderNotes(),
                  ],
                ),
              ),
            ),
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          ...widget.cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName} (${item.quantity}x)',
                        style: AppTheme.bodyText,
                      ),
                    ),
                    Text(
                      'GHS ${item.totalPrice.toStringAsFixed(2)}',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: AppTheme.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTheme.heading3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'GHS ${widget.total.toStringAsFixed(2)}',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Information',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
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
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Shipping Address',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your shipping address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Select Payment Method',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Cash on Delivery',
                child: Text('Cash on Delivery'),
              ),
              DropdownMenuItem(
                value: 'Mobile Money',
                child: Text('Mobile Money'),
              ),
              DropdownMenuItem(
                value: 'Bank Transfer',
                child: Text('Bank Transfer'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNotes() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Notes (Optional)',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Special instructions or notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: AppTheme.white,
            padding:
                const EdgeInsets.symmetric(vertical: AppTheme.paddingMedium),
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
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                )
              : Text(
                  'Place Order - GHS ${widget.total.toStringAsFixed(2)}',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Please sign in to place an order');
        return;
      }

      // Convert cart items to order items
      final orderItems = widget.cartItems
          .map((cartItem) => OrderItem(
                productId: cartItem.productId,
                productName: cartItem.productName,
                productImage: cartItem.productImage,
                price: cartItem.price,
                quantity: cartItem.quantity,
                category: cartItem.category,
              ))
          .toList();

      // Calculate order totals
      final subtotal = widget.cartItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      final tax = subtotal * 0.05; // 5% tax
      final shipping =
          subtotal > 100 ? 0.0 : 10.0; // Free shipping over GHS 100

      // Create order
      final order = Order(
        id: '',
        userId: user.uid,
        userName: _nameController.text.trim(),
        userEmail: _emailController.text.trim(),
        items: orderItems,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: widget.total,
        status: 'pending',
        paymentMethod: _selectedPaymentMethod,
        shippingAddress: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save order to Firebase
      await Provider.of<FirebaseService>(context, listen: false)
          .createOrder(order.toFirestore());

      // Clear cart
      await Provider.of<FirebaseService>(context, listen: false).clearCart();

      if (mounted) {
        _showOrderSuccessDialog();
      }
    } catch (e) {
      _showSnackBar('Error placing order: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed Successfully!'),
        content: const Text(
          'Your order has been placed and is being processed. You will receive a confirmation email shortly.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Continue Shopping'),
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
}
