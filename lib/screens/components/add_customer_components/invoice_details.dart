import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:retailer_app/services/file_handle_service.dart';


class InvoiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  InvoiceDetailsScreen({required this.data});

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
            _buildSimpleField(
              'Invoice Amount',
              'invoiceAmount',
              TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildImageSection(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleField(String label, String key, [TextInputType? type]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
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
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child:
          _isUploading
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
                        icon: Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: _deleteImage,
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
                onTap: _pickImage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to select invoice image'),
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
