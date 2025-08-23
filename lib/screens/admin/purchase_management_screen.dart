import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/purchase.dart';

class PurchaseManagementScreen extends StatefulWidget {
  const PurchaseManagementScreen({super.key});

  @override
  State<PurchaseManagementScreen> createState() =>
      _PurchaseManagementScreenState();
}

class _PurchaseManagementScreenState extends State<PurchaseManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Purchase>>(
        stream: Provider.of<FirebaseService>(context, listen: false)
            .getAllPurchases(),
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
                  Text('Error loading purchases', style: AppTheme.heading3),
                ],
              ),
            );
          }

          final purchases = snapshot.data ?? [];

          if (purchases.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              return _buildPurchaseCard(purchases[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No purchases yet',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Machinery purchases will appear here',
            style: AppTheme.bodyText.copyWith(color: AppTheme.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(Purchase purchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      decoration: AppTheme.cardDecoration,
      child: ExpansionTile(
        title: Text(
          purchase.machineryName,
          style: AppTheme.bodyText.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By: ${purchase.userName}',
              style: AppTheme.caption.copyWith(color: AppTheme.gray),
            ),
            Text(
              'GHS ${purchase.price.toStringAsFixed(2)}',
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(purchase.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Text(
            _getStatusText(purchase.status),
            style: AppTheme.caption.copyWith(
              color: _getStatusColor(purchase.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Purchase ID', purchase.id),
                _buildDetailRow('Customer', purchase.userName),
                _buildDetailRow('Email', purchase.userEmail),
                _buildDetailRow('Machinery Type', purchase.machineryType),
                _buildDetailRow('Model', purchase.machineryModel),
                _buildDetailRow(
                    'Price', 'GHS ${purchase.price.toStringAsFixed(2)}'),
                _buildDetailRow('Status', _getStatusText(purchase.status)),
                _buildDetailRow('Date', _formatDate(purchase.createdAt)),
                if (purchase.notes != null && purchase.notes!.isNotEmpty)
                  _buildDetailRow('Notes', purchase.notes!),
                const SizedBox(height: AppTheme.paddingMedium),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _updateStatus(context, purchase, 'confirmed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: const BorderSide(color: AppTheme.primaryGreen),
                        ),
                        child: const Text('Confirm'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _updateStatus(context, purchase, 'completed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: const Text('Complete'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _updateStatus(context, purchase, 'cancelled'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.gray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.caption,
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(
      BuildContext context, Purchase purchase, String newStatus) async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .updatePurchaseStatus(purchase.id, newStatus);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Purchase status updated to ${_getStatusText(newStatus)}'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return AppTheme.primaryGreen;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.gray;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
