import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retailer_app/screens/components/add_customer_components/warranty_details.dart';
import 'package:retailer_app/services/file_handle_service.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> productImg;
  final Map<String, dynamic> warrantyData;
  final Map<String, dynamic> productDetails;

  InvoiceDetailsScreen({
    required this.data,
    required this.productImg,
    required this.warrantyData,
    required this.productDetails,
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
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Invoice Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 1,
                color: Color.fromARGB(255, 126, 124, 115),
                width: double.infinity,
              ),
            ),
            SizedBox(height: 16),
            _buildSimpleField('Product Name', 'modelName'),
            _buildSimpleField('Serial / Unique / IMEI Number', 'serialNumber'),
            _buildSimpleField('Invoice Number', 'invoiceNumber'),
            SizedBox(height: 16),

            _buildImageBox("invoiceImage", "Invoice Image", widget.data),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag, // You can change this icon
                      color: Colors.white,
                      size: 20, // Optional: adjust size to fit your UI
                    ),
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      "Product Images",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 1,
                color: Color.fromARGB(255, 126, 124, 115),
                width: double.infinity,
              ),
            ),
            SizedBox(height: 16),

            _buildImageBox(
              "frontImage",
              "Front Product Image",
              widget.productImg,
            ),
            _buildImageBox(
              "backImage",
              "Back Product Image",
              widget.productImg,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.security, // You can change this icon
                      color: Colors.white,
                      size: 20, // Optional: adjust size to fit your UI
                    ),
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      "Warranty Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 1,
                color: Color.fromARGB(255, 126, 124, 115),
                width: double.infinity,
              ),
            ),
            SizedBox(height: 16),

            WarrantyDetailsScreen(key: UniqueKey(), data: widget.warrantyData),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleField(String label, String key, [TextInputType? type]) {
    return Padding(
      padding: EdgeInsets.all(6),

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
        onChanged: (value) {
          if (key == 'modelName' || key == 'serialNumber') {
            widget.productDetails[key] = value;
          } else {
            widget.data[key] = value;
          }
        },
      ),
    );
  }

  Widget _buildImageBox(
    String key,
    String label,
    Map<String, dynamic> targetMap,
  ) {
    final String? imageUrl = targetMap[key];

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFFdccf7b),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFdccf7b)),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xff131313),
            ),
            child:
                _isUploading
                    ? const Center(child: CircularProgressIndicator())
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
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, color: Colors.red),
                                    SizedBox(height: 4),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Color(0xFFdccf7b),
                                      ),
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
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => _deleteImage(key, targetMap),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                        ),
                      ],
                    )
                    : InkWell(
                      onTap: () => _pickImage(key, targetMap),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 32,
                              color: Color(0xFFdccf7b),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to capture image',
                              style: TextStyle(color: Color(0xFFdccf7b)),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(String key, Map<String, dynamic> targetMap) async {
    FocusScope.of(context).unfocus();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null) {
      setState(() => _isUploading = true);

      try {
        final originalFile = File(image.path);
        final directory = originalFile.parent;
        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String newFileName = '${key}_${timestamp}.jpg';
        final File renamedFile = await originalFile.copy(
          '${directory.path}/$newFileName',
        );

        final uploadedUrl = await uploadFile(renamedFile);

        print("uploadedUrl::: $uploadedUrl");
        setState(() {
          _isUploading = false;
          if (uploadedUrl != null) {
            targetMap[key] = uploadedUrl;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
        });
      } catch (e) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing image: $e')));
      }
    }
  }

  Future<void> _deleteImage(String key, Map<String, dynamic> targetMap) async {
    final String? imageUrl = targetMap[key];
    if (imageUrl != null) {
      setState(() => _isUploading = true);

      final success = await deleteFile(imageUrl);

      setState(() {
        _isUploading = false;
        if (success) {
          targetMap[key] = null;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete image')),
          );
        }
      });
    }
  }
}
