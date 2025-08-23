import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I place an order?',
      'answer':
          'To place an order, browse our products, add items to your cart, and proceed to checkout. You can pay using mobile money or bank transfer.',
      'expanded': false,
    },
    {
      'question': 'How do I rent machinery?',
      'answer':
          'To rent machinery, select the equipment you need, choose your rental dates, and complete the booking process. You\'ll receive confirmation once approved.',
      'expanded': false,
    },
    {
      'question': 'What payment methods do you accept?',
      'answer':
          'We accept mobile money (MTN, Vodafone, AirtelTigo), bank transfers, and cash payments. All payments are processed securely.',
      'expanded': false,
    },
    {
      'question': 'How long does delivery take?',
      'answer':
          'Delivery typically takes 1-3 business days for products and same-day pickup for machinery rentals. Delivery times may vary based on location.',
      'expanded': false,
    },
    {
      'question': 'Can I cancel my order?',
      'answer':
          'Orders can be cancelled within 24 hours of placement. Machinery bookings can be cancelled up to 48 hours before the rental start date.',
      'expanded': false,
    },
    {
      'question': 'What if the machinery breaks down?',
      'answer':
          'We provide 24/7 support for machinery issues. Contact our support team immediately and we\'ll arrange for repair or replacement.',
      'expanded': false,
    },
    {
      'question': 'Do you offer training for machinery?',
      'answer':
          'Yes, we provide basic training for all machinery rentals. Advanced training is available for complex equipment at an additional cost.',
      'expanded': false,
    },
    {
      'question': 'How do I track my order?',
      'answer':
          'You can track your order in the Orders section of your profile. You\'ll also receive SMS and email updates on your order status.',
      'expanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFAQs(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildContactSection(),
            const SizedBox(height: AppTheme.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.paddingLarge),
          Text(
            'Frequently Asked Questions',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ..._faqs.map((faq) => _buildFAQCard(faq)),
        ],
      ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      decoration: AppTheme.cardDecoration,
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              faq['answer'],
              style: AppTheme.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildContactItem(
              Icons.phone,
              'Phone',
              '+233 544 103 101',
              () => _callSupport(),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            _buildContactItem(
              Icons.email,
              'Email',
              'info@ggf.farm',
              () => _emailSupport(),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            _buildContactItem(
              Icons.location_on,
              'Address',
              'Accra, Ghana',
              () => _openLocation(),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            _buildContactItem(
              Icons.access_time,
              'Business Hours',
              'Mon-Fri: 8AM-6PM, Sat: 9AM-4PM',
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String title, String value, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title,
          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: AppTheme.caption),
      trailing:
          onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  void _emailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@greengoldfarms.com',
      query: 'subject=Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackBar('Could not open email app');
    }
  }

  void _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+233201234567');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar('Could not open phone app');
    }
  }

  void _openLocation() async {
    final Uri locationUri = Uri.parse('https://maps.google.com/?q=Accra,Ghana');

    if (await canLaunchUrl(locationUri)) {
      await launchUrl(locationUri);
    } else {
      _showSnackBar('Could not open maps app');
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
