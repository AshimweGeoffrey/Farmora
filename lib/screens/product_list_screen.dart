import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmora/models/product.dart';
import 'package:farmora/services/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:farmora/screens/product_detail_screen.dart';
import 'package:farmora/screens/product_form_screen.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Product> _products = [];
  bool _isLoading = true;
  final Color _primaryColor = Color(0xFF1E88E5);
  final Color _accentColor = Color(0xFF26A69A);
  
  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final products = await _databaseHelper.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshProducts,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductFormScreen()),
              );
              if (result == true) {
                _refreshProducts();
              }
            },
          ),
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _products.isEmpty
              ? _buildEmptyState()
              : _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductFormScreen()),
          );
          if (result == true) {
            _refreshProducts();
          }
        },
        backgroundColor: _primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: _primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductFormScreen()),
              );
              if (result == true) {
                _refreshProducts();
              }
            },
            icon: Icon(Icons.add),
            label: Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _products.length,
      padding: EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final product = _products[index];
        return Slidable(
          key: Key(product.id.toString()),
          startActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductFormScreen(product: product),
                    ),
                  );
                  if (result == true) {
                    _refreshProducts();
                  }
                },
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  _showDeleteConfirmationDialog(product);
                },
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
                if (result == true) {
                  _refreshProducts();
                }
              },
              onDoubleTap: () {
                _showFullSizeImage(context, product.imageUrl);
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _showFullSizeImage(context, product.imageUrl);
                      },
                      child: Hero(
                        tag: 'product-image-${product.id}',
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          child: product.imageUrl.startsWith('http')
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                      Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                      ),
                                )
                              : Image.file(
                                  File(product.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                      Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  // Product details
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _accentColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.description.length > 80
                              ? '${product.description.substring(0, 80)}...'
                              : product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy').format(product.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: _accentColor),
                                SizedBox(width: 4),
                                Text(
                                  'Swipe to edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullSizeImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.image_not_supported, size: 100, color: Colors.white),
                    )
                  : Image.file(
                      File(imageUrl),
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.image_not_supported, size: 100, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete ${product.name}?',
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _databaseHelper.deleteProduct(product.id!);
                  _refreshProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} deleted'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
