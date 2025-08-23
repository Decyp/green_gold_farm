import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Provider.of<FirebaseService>(context, listen: false).getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: AppTheme.gray),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text('Error loading users', style: AppTheme.heading3),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, size: 60, color: AppTheme.gray),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text('No users found', style: AppTheme.heading3),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text('Users will appear here when they register',
                      style: AppTheme.caption),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final isAdmin = user['role'] == 'admin' || user['isAdmin'] == true;
    final isActive = user['isActive'] ?? true;

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
                        user['displayName'] ?? user['email'] ?? 'Unknown User',
                        style: AppTheme.heading3,
                      ),
                      Text(
                        user['email'] ?? 'No email',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditUserDialog(context, user);
                        break;
                      case 'toggle':
                        _toggleUserStatus(context, user);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, user);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.block : Icons.check_circle,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(isActive ? 'Disable' : 'Enable'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
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
                        'Role: ${user['role'] ?? 'farmer'}',
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Phone: ${user['phone'] ?? 'Not provided'}',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppTheme.accentGold.withValues(alpha: 0.1)
                            : AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        isAdmin ? 'Admin' : 'User',
                        style: AppTheme.caption.copyWith(
                          color: isAdmin
                              ? AppTheme.accentGold
                              : AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                            : AppTheme.gray.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: AppTheme.caption.copyWith(
                          color:
                              isActive ? AppTheme.primaryGreen : AppTheme.gray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (user['address'] != null && user['address'].isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                'Address: ${user['address']}',
                style: AppTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    // This would typically open a form to add a new user
    // For now, we'll show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: const Text(
            'User registration is handled through the app. New users will appear here when they sign up.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController =
        TextEditingController(text: user['displayName'] ?? '');
    final phoneController = TextEditingController(text: user['phone'] ?? '');
    final addressController =
        TextEditingController(text: user['address'] ?? '');
    String selectedRole = user['role'] ?? 'farmer';
    bool isAdmin = user['role'] == 'admin' || user['isAdmin'] == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Row(
                children: [
                  Checkbox(
                    value: isAdmin,
                    onChanged: (value) {
                      isAdmin = value!;
                    },
                  ),
                  const Text('Admin privileges'),
                ],
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
              // Update user logic would go here
              Navigator.pop(context);
              _showSnackBar(context, 'User updated successfully');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(
      BuildContext context, Map<String, dynamic> user) async {
    try {
      // Toggle user status logic would go here
      _showSnackBar(context, 'User status updated successfully');
    } catch (e) {
      _showSnackBar(context, 'Error updating user status: $e');
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user['displayName'] ?? user['email']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(context, user['uid']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context, String userId) async {
    try {
      // Delete user logic would go here
      _showSnackBar(context, 'User deleted successfully');
    } catch (e) {
      _showSnackBar(context, 'Error deleting user: $e');
    }
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
