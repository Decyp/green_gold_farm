import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRevenueSection(),
            _buildProductAnalytics(),
            _buildMachineryAnalytics(),
            _buildUserAnalytics(),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSection() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Overview',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                    'This Month', 'GHS 12,450', '+15%', AppTheme.primaryGreen),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildRevenueCard(
                    'Last Month', 'GHS 10,820', '+8%', AppTheme.lightGreen),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                    'This Year', 'GHS 145,230', '+23%', AppTheme.accentGold),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildRevenueCard(
                    'Total Orders', '156', '+12%', AppTheme.darkGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(
      String title, String value, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.caption,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            value,
            style: AppTheme.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            change,
            style: AppTheme.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAnalytics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Selling Products',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildProductItem('Soybeans', 'GHS 2,450', '45 units'),
          _buildProductItem('Maize', 'GHS 1,890', '38 units'),
          _buildProductItem('Tomatoes', 'GHS 1,230', '52 units'),
          _buildProductItem('Cassava', 'GHS 980', '28 units'),
          _buildProductItem('Yam', 'GHS 750', '25 units'),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, String revenue, String units) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            revenue,
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            units,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildMachineryAnalytics() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Machinery Performance',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildMachineryCard('Tractors', 'GHS 4,200',
                    '12 rentals', AppTheme.primaryGreen),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildMachineryCard('Harvesters', 'GHS 3,150',
                    '8 rentals', AppTheme.lightGreen),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildMachineryCard(
                    'Planters', 'GHS 1,890', '15 rentals', AppTheme.accentGold),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildMachineryCard(
                    'Irrigation', 'GHS 1,230', '6 rentals', AppTheme.darkGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMachineryCard(
      String type, String revenue, String rentals, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            revenue,
            style: AppTheme.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rentals,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalytics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Insights',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildUserCard(
                    'Total Users', '156', '+12 this month', Icons.people),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildUserCard(
                    'Active Users', '89', '57% of total', Icons.person),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildUserCard(
                    'New Users', '23', '+5 this week', Icons.person_add),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: _buildUserCard(
                    'Premium Users', '12', '8% of total', Icons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
      String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            value,
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.caption,
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: AppTheme.caption.copyWith(
              color: AppTheme.gray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingLarge),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildActivityItem(
              'New order received', 'Order #1234 - GHS 450', '2 hours ago'),
          _buildActivityItem('Machinery rental completed',
              'Tractor rental - GHS 800', '4 hours ago'),
          _buildActivityItem(
              'New user registered', 'John Doe joined', '6 hours ago'),
          _buildActivityItem(
              'Product restocked', 'Soybeans - 50kg added', '1 day ago'),
          _buildActivityItem(
              'Payment received', 'Order #1230 - GHS 320', '1 day ago'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTheme.caption.copyWith(color: AppTheme.gray),
          ),
        ],
      ),
    );
  }

  void _exportReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: const Text(
            'This feature would generate and download a comprehensive PDF report of all analytics data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Report export started');
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
