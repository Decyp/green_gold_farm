import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/booking.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
      ),
      body: StreamBuilder<List<Booking>>(
        stream: Provider.of<FirebaseService>(context, listen: false)
            .getAllBookings(),
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
                  Text('Error loading bookings', style: AppTheme.heading3),
                ],
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today,
                      size: 60, color: AppTheme.gray),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text('No bookings available', style: AppTheme.heading3),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                      'Bookings will appear here when customers make rental requests',
                      style: AppTheme.caption),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
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
                        booking.machineryName,
                        style: AppTheme.heading3,
                      ),
                      Text(
                        booking.machineryModel,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(booking.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: _getStatusColor(booking.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: AppTheme.caption.copyWith(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            // Status Update Section
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.gray.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.update,
                        size: 16,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: AppTheme.paddingSmall),
                      Text(
                        'Update Status',
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    'Click the buttons below to update the booking status:',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.gray,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Wrap(
                    spacing: AppTheme.paddingSmall,
                    runSpacing: AppTheme.paddingSmall,
                    children: _buildStatusActionButtons(context, booking),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${booking.userName}',
                        style: AppTheme.bodyText,
                      ),
                      Text(
                        'Email: ${booking.userEmail}',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'GHS ${booking.totalAmount.toStringAsFixed(2)}',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration: ${booking.duration} days',
                        style: AppTheme.bodyText,
                      ),
                      Text(
                        'Daily Rate: GHS ${booking.dailyRate.toStringAsFixed(2)}',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'From: ${_formatDate(booking.startDate)}',
                      style: AppTheme.caption,
                    ),
                    Text(
                      'To: ${_formatDate(booking.endDate)}',
                      style: AppTheme.caption,
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
                    'Booked: ${_formatDate(booking.createdAt)}',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.gray,
                    ),
                  ),
                ),
                if (booking.phoneNumber.isNotEmpty)
                  Text(
                    'Phone: ${booking.phoneNumber}',
                    style: AppTheme.caption,
                  ),
              ],
            ),
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  'Notes: ${booking.notes}',
                  style: AppTheme.caption,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusActionButtons(
      BuildContext context, Booking booking) {
    List<Widget> buttons = [];

    // Add status-specific buttons
    if (booking.status == 'pending') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _handleBookingAction(context, booking, 'confirm'),
          icon: const Icon(Icons.check_circle, size: 16),
          label: const Text('Confirm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingSmall,
            ),
          ),
        ),
      );
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _handleBookingAction(context, booking, 'reject'),
          icon: const Icon(Icons.cancel, size: 16),
          label: const Text('Reject'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingSmall,
            ),
          ),
        ),
      );
    }

    if (booking.status == 'confirmed') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _handleBookingAction(context, booking, 'activate'),
          icon: const Icon(Icons.play_circle, size: 16),
          label: const Text('Activate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingSmall,
            ),
          ),
        ),
      );
    }

    if (booking.status == 'active') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _handleBookingAction(context, booking, 'complete'),
          icon: const Icon(Icons.done_all, size: 16),
          label: const Text('Complete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingSmall,
            ),
          ),
        ),
      );
    }

    // Always show cancel button
    buttons.add(
      ElevatedButton.icon(
        onPressed: () => _handleBookingAction(context, booking, 'cancel'),
        icon: const Icon(Icons.delete, size: 16),
        label: const Text('Cancel'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingSmall,
          ),
        ),
      ),
    );

    // If no status-specific buttons, show a message
    if (buttons.length == 1) {
      // Only cancel button
      return [
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: BoxDecoration(
            color: AppTheme.gray.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.gray,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Expanded(
                child: Text(
                  'This booking is ${_getStatusText(booking.status).toLowerCase()}. You can only cancel it.',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.gray,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        ...buttons,
      ];
    }

    return buttons;
  }

  void _handleBookingAction(
      BuildContext context, Booking booking, String action) async {
    String newStatus = '';
    String message = '';

    switch (action) {
      case 'confirm':
        newStatus = 'confirmed';
        message = 'Booking confirmed successfully';
        break;
      case 'reject':
        newStatus = 'cancelled';
        message = 'Booking rejected';
        break;
      case 'activate':
        newStatus = 'active';
        message = 'Booking activated';
        break;
      case 'complete':
        newStatus = 'completed';
        message = 'Booking completed';
        break;
      case 'cancel':
        newStatus = 'cancelled';
        message = 'Booking cancelled';
        break;
    }

    if (newStatus.isNotEmpty) {
      try {
        await Provider.of<FirebaseService>(context, listen: false)
            .updateBookingStatus(booking.id, newStatus);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Booking status updated to ${_getStatusText(newStatus)}'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating booking status: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'active':
        return AppTheme.primaryGreen;
      case 'completed':
        return AppTheme.darkGreen;
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
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
