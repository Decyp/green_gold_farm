import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'product';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedType = _tabController.index == 0 ? 'product' : 'machinery';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
          indicatorColor: AppTheme.white,
          tabs: const [
            Tab(text: 'Product Categories'),
            Tab(text: 'Machinery Types'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList('product'),
          _buildCategoryList('machinery'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    return StreamBuilder<List<Category>>(
      stream: Provider.of<FirebaseService>(context, listen: false)
          .getCategories(type),
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
                Text('Error loading categories', style: AppTheme.heading3),
              ],
            ),
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'product' ? Icons.shopping_basket : Icons.agriculture,
                  size: 60,
                  color: AppTheme.gray,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'No ${type == 'product' ? 'product categories' : 'machinery types'}',
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                  'Add your first ${type == 'product' ? 'category' : 'type'}',
                  style: AppTheme.caption,
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                ElevatedButton(
                  onPressed: () => _showAddCategoryDialog(),
                  child: Text('Add ${type == 'product' ? 'Category' : 'Type'}'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
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
                        category.name,
                        style: AppTheme.heading3,
                      ),
                      Text(
                        category.type == 'product'
                            ? 'Product Category'
                            : 'Machinery Type',
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
                        _showEditCategoryDialog(category);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(category);
                        break;
                      case 'toggle':
                        _toggleCategoryStatus(category);
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
                            category.isActive
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(category.isActive ? 'Disable' : 'Enable'),
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
            if (category.description.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                category.description,
                style: AppTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : AppTheme.gray.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    category.isActive ? 'Active' : 'Inactive',
                    style: AppTheme.caption.copyWith(
                      color: category.isActive
                          ? AppTheme.primaryGreen
                          : AppTheme.gray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Created: ${_formatDate(category.createdAt)}',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    _resetForm();
    _showCategoryDialog(null);
  }

  void _showEditCategoryDialog(Category category) {
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    _selectedType = category.type;
    _isActive = category.isActive;
    _showCategoryDialog(category);
  }

  void _showCategoryDialog(Category? existingCategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(existingCategory == null ? 'Add Category' : 'Edit Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: 'product',
                      child: Text('Product Category'),
                    ),
                    DropdownMenuItem(
                      value: 'machinery',
                      child: Text('Machinery Type'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Row(
                  children: [
                    Checkbox(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value!;
                        });
                      },
                    ),
                    const Text('Active'),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed:
                _isLoading ? null : () => _saveCategory(existingCategory),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(existingCategory == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _saveCategory(Category? existingCategory) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final category = Category(
        id: existingCategory?.id ?? '',
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim(),
        isActive: _isActive,
        createdAt: existingCategory?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existingCategory == null) {
        await Provider.of<FirebaseService>(context, listen: false)
            .addCategory(category);
      } else {
        await Provider.of<FirebaseService>(context, listen: false)
            .updateCategory(category);
      }

      Navigator.pop(context);
      _showSnackBar(existingCategory == null
          ? 'Category added successfully'
          : 'Category updated successfully');
    } catch (e) {
      _showSnackBar('Error saving category: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String categoryId) async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .deleteCategory(categoryId);
      _showSnackBar('Category deleted successfully');
    } catch (e) {
      _showSnackBar('Error deleting category: $e');
    }
  }

  void _toggleCategoryStatus(Category category) async {
    try {
      final updatedCategory = category.copyWith(isActive: !category.isActive);
      await Provider.of<FirebaseService>(context, listen: false)
          .updateCategory(updatedCategory);
      _showSnackBar(
          'Category ${category.isActive ? 'disabled' : 'enabled'} successfully');
    } catch (e) {
      _showSnackBar('Error updating category: $e');
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _selectedType = 'product';
    _isActive = true;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
