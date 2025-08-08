import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retailer_app/services/file_handle_service.dart';

class ThirdPart extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> productImg;
  final Map<String, dynamic> warrantyData;
  final Map<String, dynamic> productDetails;

  final VoidCallback onPrevious;
  final int currentPage;
  final int totalPages;
  final VoidCallback onSubmit;

  ThirdPart({
    required this.data,
    required this.productImg,
    required this.warrantyData,
    required this.productDetails,
    required this.onPrevious,
    required this.currentPage,
    required this.totalPages,
    required this.onSubmit,
  });

  @override
  State<ThirdPart> createState() => _ThirdPartState();
}

class _ThirdPartState extends State<ThirdPart> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Text controllers for better state management
  late TextEditingController _modelNameController;
  late TextEditingController _serialNumberController;
  late TextEditingController _invoiceNumberController;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing values
    _modelNameController = TextEditingController(
      text: widget.productDetails['modelName']?.toString() ?? ''
    );
    _serialNumberController = TextEditingController(
      text: widget.productDetails['serialNumber']?.toString() ?? ''
    );
    _invoiceNumberController = TextEditingController(
      text: widget.data['invoiceNumber']?.toString() ?? ''
    );
    
    // Add listeners to update maps and trigger rebuilds
    _modelNameController.addListener(() {
      final trimmedValue = _modelNameController.text.trim();
      widget.productDetails['modelName'] = trimmedValue.isEmpty ? null : trimmedValue;
      setState(() {}); // Trigger rebuild for button state
    });
    
    _serialNumberController.addListener(() {
      final trimmedValue = _serialNumberController.text.trim();
      widget.productDetails['serialNumber'] = trimmedValue.isEmpty ? null : trimmedValue;
      setState(() {});
    });
    
    _invoiceNumberController.addListener(() {
      final trimmedValue = _invoiceNumberController.text.trim();
      widget.data['invoiceNumber'] = trimmedValue.isEmpty ? null : trimmedValue;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _serialNumberController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  // VALIDATION CHECK with debug info
  bool _isFormFirstComplete() {
    String? modelName = widget.productDetails['modelName']?.toString().trim();
    String? serialNumber = widget.productDetails['serialNumber']?.toString().trim();
    String? invoiceNumber = widget.data['invoiceNumber']?.toString().trim();

    // Debug prints - remove these in production
    print('=== VALIDATION DEBUG ===');
    print('modelName: $modelName');
    print('serialNumber: $serialNumber');
    print('invoiceNumber: $invoiceNumber');
    print('invoiceImage: ${widget.data['invoiceImage']}');
    print('frontImage: ${widget.productImg['frontImage']}');
    print('backImage: ${widget.productImg['backImage']}');
    print('rightImage: ${widget.productImg['rightImage']}');
    print('leftImage: ${widget.productImg['leftImage']}');

    bool isComplete = modelName != null &&
        modelName.isNotEmpty &&
        serialNumber != null &&
        serialNumber.isNotEmpty &&
        invoiceNumber != null &&
        invoiceNumber.isNotEmpty &&
        widget.data['invoiceImage'] != null &&
        widget.productImg['frontImage'] != null &&
        widget.productImg['backImage'] != null &&
        widget.productImg['rightImage'] != null &&
        widget.productImg['leftImage'] != null;

    print('Form complete: $isComplete');
    print('========================');

    return isComplete;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff131313),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildSectionHeader(Icons.receipt_long, "Invoice Details"),
              _divider(),
              const SizedBox(height: 16),

              _buildSimpleFieldWithController('Product Name', _modelNameController),
              _buildSimpleFieldWithController('Serial / Unique / IMEI Number', _serialNumberController),
              _buildSimpleFieldWithController('Invoice Number', _invoiceNumberController),
              const SizedBox(height: 16),

              _buildImageBox("invoiceImage", "Invoice Image", widget.data),
              const SizedBox(height: 25),

              _buildSectionHeader(Icons.shopping_bag, "Product Images"),
              _divider(),
              const SizedBox(height: 16),

              _buildImageBox("frontImage", "Front side product image", widget.productImg),
              _buildImageBox("backImage", "Back side product image", widget.productImg),
              _buildImageBox("rightImage", "Right side product image", widget.productImg),
              _buildImageBox("leftImage", "Left side product image", widget.productImg),

              const SizedBox(height: 18),
              _buildSectionHeader(Icons.security, "Warranty Details"),
              _divider(),
              const SizedBox(height: 16),

              _buildSimpleFieldReadOnly('Warranty Period (months)', 'warrantyPeriod'),
              _buildSimpleFieldReadOnly('Premium Amount', 'premiumAmount'),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.grey),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 49, 48, 43),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 75, 74, 70),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isFormFirstComplete() ? widget.onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormFirstComplete() ? Colors.green[800] : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 1,
        color: const Color.fromARGB(255, 126, 124, 115),
        width: double.infinity,
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFieldWithController(
    String label, 
    TextEditingController controller, 
    [TextInputType? type]
  ) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFFdccf7b)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFdccf7b)),
          filled: true,
          fillColor: const Color(0xff131313),
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
      ),
    );
  }

  Widget _buildSimpleFieldReadOnly(
    String label,
    String key, [
    TextInputType? type,
  ]) {
    final text = widget.warrantyData[key]?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: TextEditingController(text: text)
          ..selection = TextSelection.collapsed(offset: text.length),
        readOnly: true,
        style: const TextStyle(color: Color(0xFFdccf7b)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFdccf7b)),
          filled: true,
          fillColor: const Color.fromARGB(255, 37, 37, 37),
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
              border: Border.all(color: const Color(0xFFdccf7b)),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xff131313),
            ),
            child: _isUploading
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
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
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