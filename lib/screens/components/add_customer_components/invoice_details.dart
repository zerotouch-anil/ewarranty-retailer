import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:retailer_app/screens/components/add_customer_components/product_images.dart';
import 'package:retailer_app/screens/components/add_customer_components/warranty_details.dart';
import 'package:retailer_app/screens/retailer_add_customer.dart';
import 'package:retailer_app/services/file_handle_service.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> productImg;
  final Map<String, dynamic> warrantyData;

  InvoiceDetailsScreen({
    required this.data,
    required this.productImg,
    required this.warrantyData,
  });

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSimpleField('Invoice Number', 'invoiceNumber'),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Invoice Image",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFdccf7b),
                ),
              ),
            ),
            SizedBox(height: 16),

            _buildImageSection(),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Product Image",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFdccf7b),
                ),
              ),
            ),
            SizedBox(height: 16),

            ProductImagesScreen(data: widget.productImg),
            WarrantyDetailsScreen(data: widget.warrantyData),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleField(String label, String key, [TextInputType? type]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      
      child: TextField(
         style: const TextStyle(color: Color(0xFFdccf7b)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFdccf7b)), // Label color
          filled: true,
          fillColor: Color(0xff131313), // Background color
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFdccf7b)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFdccf7b), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: type,
        onChanged: (value) => widget.data[key] = value,
      ),
    );
  }

  Widget _buildImageSection() {
  final String? imageUrl = widget.data['invoiceImage'];

  return Container(
    width: double.infinity,
    height: 120,
    decoration: BoxDecoration(
      border: Border.all(color: Color(0xFFdccf7b)), // Golden border
      borderRadius: BorderRadius.circular(8),
      color: Color(0xff131313), // Black background
    ),
    child: _isUploading
        ? Center(child: CircularProgressIndicator())
        : imageUrl != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(height: 4),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Color(0xFFdccf7b)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.white, size: 20),
                        onPressed: _deleteImage,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: _pickImage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 32, color: Color(0xFFdccf7b)),
                    SizedBox(height: 8),
                    Text(
                      'Tap to select invoice image',
                      style: TextStyle(color: Color(0xFFdccf7b)),
                    ),
                  ],
                ),
              ),
  );
}


  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);

      final uploadedUrl = await uploadFile(File(image.path));

      setState(() {
        _isUploading = false;
        if (uploadedUrl != null) {
          widget.data['invoiceImage'] = uploadedUrl;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload image')));
        }
      });
    }
  }

  Future<void> _deleteImage() async {
    final String? imageUrl = widget.data['invoiceImage'];
    if (imageUrl != null) {
      setState(() => _isUploading = true);

      final success = await deleteFile(imageUrl);

      setState(() {
        _isUploading = false;
        if (success) {
          widget.data['invoiceImage'] = null;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete image')));
        }
      });
    }
  }
}
