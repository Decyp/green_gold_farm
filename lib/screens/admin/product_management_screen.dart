import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = '';
  bool _isAvailable = true;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream:
            Provider.of<FirebaseService>(context, listen: false).getProducts(),
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
                  Text('Error loading products', style: AppTheme.heading3),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_basket,
                      size: 60, color: AppTheme.gray),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text('No products available', style: AppTheme.heading3),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text('Add your first product', style: AppTheme.caption),
                  const SizedBox(height: AppTheme.paddingLarge),
                  ElevatedButton(
                    onPressed: () => _showAddProductDialog(),
                    child: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
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
                        product.name,
                        style: AppTheme.heading3,
                      ),
                      Text(
                        product.category,
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
                        _showEditProductDialog(product);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(product);
                        break;
                      case 'toggle':
                        _toggleProductAvailability(product);
                        break;
                      case 'test_image':
                        _testImageUrl(product.imageUrl);
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
                            product.isAvailable
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(product.isAvailable ? 'Disable' : 'Enable'),
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
                    if (product.imageUrl.isNotEmpty)
                      PopupMenuItem(
                        value: 'test_image',
                        child: Row(
                          children: [
                            Icon(Icons.image,
                                size: 16, color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Test Image',
                                style: TextStyle(color: AppTheme.primaryGreen)),
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
                        'Price: GHS ${product.price.toStringAsFixed(2)}',
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Quantity: ${product.quantity}',
                        style: AppTheme.caption,
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
                    color: product.isAvailable
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : AppTheme.gray.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    product.isAvailable ? 'Available' : 'Unavailable',
                    style: AppTheme.caption.copyWith(
                      color: product.isAvailable
                          ? AppTheme.primaryGreen
                          : AppTheme.gray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                product.description,
                style: AppTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Product Image
            if (product.imageUrl.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingMedium),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                            SizedBox(height: 4),
                            Text(
                              'Image Error',
                              style: TextStyle(
                                color: AppTheme.gray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    memCacheWidth: 300,
                    memCacheHeight: 200,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    _resetForm();
    _ensureProductCategories();
    _showProductDialog(null);
  }

  void _showEditProductDialog(Product product) {
    _nameController.text = product.name;
    _categoryController.text = product.category;
    _priceController.text = product.price.toString();
    _quantityController.text = product.quantity;
    _descriptionController.text = product.description;
    _selectedCategory = product.category;
    _isAvailable = product.isAvailable;
    _ensureProductCategories();
    _showProductDialog(product);
  }

  void _showProductDialog(Product? existingProduct) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingProduct == null ? 'Add Product' : 'Edit Product'),
        content: SizedBox(
          width: double.maxFinite,
          height:
              MediaQuery.of(context).size.height * 0.7, // Set maximum height
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Upload Section
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                          color: AppTheme.gray.withValues(alpha: 0.3)),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : InkWell(
                            onTap: _pickImage,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppTheme.gray,
                                ),
                                const SizedBox(height: AppTheme.paddingSmall),
                                Text(
                                  'Tap to add product image',
                                  style: AppTheme.caption
                                      .copyWith(color: AppTheme.gray),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  StreamBuilder<List<Category>>(
                    stream: Provider.of<FirebaseService>(context, listen: false)
                        .getCategories('product'),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];

                      if (categories.isEmpty) {
                        return TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            helperText:
                                'No categories available. Please add categories first.',
                          ),
                          enabled: false,
                        );
                      }

                      // Check if the current category exists in the categories
                      final currentValue =
                          _selectedCategory.isEmpty ? null : _selectedCategory;

                      final valueExists =
                          categories.any((cat) => cat.name == currentValue);
                      final dropdownValue = valueExists ? currentValue : null;

                      // Set default category if not set
                      if (_selectedCategory.isEmpty && categories.isNotEmpty) {
                        _selectedCategory = categories.first.name;
                      }

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: dropdownValue,
                        hint: const Text('Select a category'),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (GHS)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
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
                  Row(
                    children: [
                      Checkbox(
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value!;
                          });
                        },
                      ),
                      const Text('Available for purchase'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Add a subtle indicator that content is scrollable
        contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _saveProduct(existingProduct),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(existingProduct == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showSnackBar('Image selected successfully');
      }
    } catch (e) {
      _showErrorDialog(
        'Image Selection Error',
        'Unable to select image. Please try again.\n\nError: $e',
      );
    }
  }

  void _saveProduct(Product? existingProduct) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = existingProduct?.imageUrl ?? '';

      // Upload image if selected
      if (_selectedImage != null) {
        _showSnackBar('Uploading image...');
        imageUrl = await _uploadImage(_selectedImage!);
        _showSnackBar('Image uploaded successfully!');
      }

      final product = Product(
        id: existingProduct?.id ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: _quantityController.text.trim(),
        imageUrl: imageUrl,
        description: _descriptionController.text.trim(),
        isAvailable: _isAvailable,
        createdAt: existingProduct?.createdAt ?? DateTime.now(),
      );

      if (existingProduct == null) {
        await Provider.of<FirebaseService>(context, listen: false)
            .addProduct(product);
      } else {
        await Provider.of<FirebaseService>(context, listen: false)
            .updateProduct(product);
      }

      Navigator.pop(context);
      _showSnackBar(existingProduct == null
          ? 'Product added successfully'
          : 'Product updated successfully');
    } catch (e) {
      _showErrorDialog(
        'Save Error',
        'Failed to save product. Please try again.\n\nError: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Selected image file does not exist');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'products/${timestamp}_${imageFile.path.split('/').last}';

      // Get storage reference
      final ref = Provider.of<FirebaseService>(context, listen: false)
          .storage
          .ref()
          .child(fileName);

      // Upload file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(imageFile, metadata);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // print('Image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String productId) async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .deleteProduct(productId);
      _showSnackBar('Product deleted successfully');
    } catch (e) {
      _showSnackBar('Error deleting product: $e');
    }
  }

  void _toggleProductAvailability(Product product) async {
    try {
      final updatedProduct =
          product.copyWith(isAvailable: !product.isAvailable);
      await Provider.of<FirebaseService>(context, listen: false)
          .updateProduct(updatedProduct);
      _showSnackBar(
          'Product ${product.isAvailable ? 'disabled' : 'enabled'} successfully');
    } catch (e) {
      _showSnackBar('Error updating product: $e');
    }
  }

  void _resetForm() {
    _nameController.clear();
    _categoryController.clear();
    _priceController.clear();
    _quantityController.clear();
    _descriptionController.clear();
    _selectedCategory = '';
    _isAvailable = true;
    _selectedImage = null;
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

  void _testImageUrl(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Image URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Testing URL: $imageUrl'),
            const SizedBox(height: AppTheme.paddingMedium),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(
              child: Text(
                title,
                style: AppTheme.heading3.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _ensureProductCategories() async {
    try {
      final categories =
          await Provider.of<FirebaseService>(context, listen: false)
              .getCategories('product')
              .first;

      if (categories.isEmpty) {
        _showErrorDialog(
          'No Product Categories Found',
          'Please add product categories first. This is required for product management.',
        );
        // Optionally, you might want to navigate to category management
        // Navigator.pushNamed(context, '/admin/category_management');
      }
    } catch (e) {
      // print('Error checking product categories: $e');
    }
  }
}
