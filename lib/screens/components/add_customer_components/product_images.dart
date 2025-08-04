
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:retailer_app/services/file_handle_service.dart';

class ProductImagesScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  ProductImagesScreen({required this.data});

  @override
  State<ProductImagesScreen> createState() => _ProductImagesScreenState();
}

class _ProductImagesScreenState extends State<ProductImagesScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildImageSection('Front Image', 'frontImage'),
          SizedBox(height: 16),
          _buildImageSection('Back Image', 'backImage'),
          SizedBox(height: 24),
          Text(
            'Additional Images',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ..._buildAdditionalImages(),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _addAdditionalImage,
            icon: Icon(Icons.add),
            label: Text('Add Image'),
          ),
          if (_isUploading)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String label, String key) {
    final String? imageUrl = widget.data[key];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child:
              imageUrl != null
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
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  Text('Failed to load image'),
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
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => _deleteImage(key),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    ],
                  )
                  : InkWell(
                    onTap: _isUploading ? null : () => _pickImage(key),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tap to select $label'),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  List<Widget> _buildAdditionalImages() {
    final List<String> imageUrls = List<String>.from(
      widget.data['additionalImages'] ?? [],
    );
    return imageUrls.asMap().entries.map((entry) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    entry.value,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              onPressed:
                  _isUploading ? null : () => _removeAdditionalImage(entry.key),
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _pickImage(String key) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);

      final uploadedUrl = await uploadFile(File(image.path));

      setState(() {
        _isUploading = false;
        if (uploadedUrl != null) {
          widget.data[key] = uploadedUrl;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload image')));
        }
      });
    }
  }

  Future<void> _addAdditionalImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);

      final uploadedUrl = await uploadFile(File(image.path));

      setState(() {
        _isUploading = false;
        if (uploadedUrl != null) {
          final List<String> imageUrls = List<String>.from(
            widget.data['additionalImages'] ?? [],
          );
          imageUrls.add(uploadedUrl);
          widget.data['additionalImages'] = imageUrls;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload image')));
        }
      });
    }
  }

  Future<void> _removeAdditionalImage(int index) async {
    final List<String> imageUrls = List<String>.from(
      widget.data['additionalImages'] ?? [],
    );

    if (index < imageUrls.length) {
      final imageUrl = imageUrls[index];
      setState(() => _isUploading = true);

      final success = await deleteFile(imageUrl);

      setState(() {
        _isUploading = false;
        if (success) {
          imageUrls.removeAt(index);
          widget.data['additionalImages'] = imageUrls;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete image')));
        }
      });
    }
  }

  Future<void> _deleteImage(String key) async {
    final String? imageUrl = widget.data[key];
    if (imageUrl != null) {
      setState(() => _isUploading = true);

      final success = await deleteFile(imageUrl);

      setState(() {
        _isUploading = false;
        if (success) {
          widget.data[key] = null;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete image')));
        }
      });
    }
  }
}
