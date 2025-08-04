import 'package:flutter/material.dart';
import 'package:retailer_app/models/brands_model.dart';
import 'package:retailer_app/models/categories_model.dart';
import 'package:retailer_app/screens/components/add_customer_components/customer_details.dart';
import 'package:retailer_app/screens/components/add_customer_components/invoice_details.dart';
import 'package:retailer_app/screens/components/add_customer_components/product_details.dart';
import 'package:retailer_app/services/catalog_service.dart';
import 'package:retailer_app/services/customer_form_submit.dart';

class CustomerForm extends StatefulWidget {
  final String categoryId;
  final List<PercentItem> percentList;
  const CustomerForm({
    super.key,
    required this.categoryId,
    required this.percentList,
  });
  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late Future<List<Brand>> _brands;
  bool _isPage0Valid = false;

  @override
  void initState() {
    super.initState();

    _brands = fetchBrands(widget.categoryId);
  }

  int _currentPage = 0;
  final PageController _pageController = PageController();

  final Map<String, dynamic> _formData = {
    'customer': <String, String>{},
    'product': <String, String>{},
    'invoice': <String, dynamic>{
      'invoiceDate': DateTime.now(),
      'invoiceImage': null,
    },
    'images': <String, dynamic>{
      'frontImage': null,
      'backImage': null,
      'additionalImages': <String>[],
    },
    'warranty': <String, dynamic>{
      'startDate': DateTime.now(),
      'expiryDate': DateTime.now(),
    },
  };

  final List<String> _pageTitles = [
    'Extended Warranty Details',
    'Customer Info',
    'Invoice & Product Details',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff131313),
      appBar: AppBar(
        title: Text(_pageTitles[_currentPage]),
        backgroundColor: Color(0xff131313),
        foregroundColor: Color(0xFFdccf7b),
        elevation: 1,
      ),
      body: FutureBuilder<List<Brand>>(
        future: _brands,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'No brands found',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              Container(
                height: 4,
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 3,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[500]!),
                ),
              ),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged:
                      (index) => setState(() => _currentPage = index),
                  children: [
                    ProductDetailsScreen(
                      data: _formData['product'],
                      invoiceData: _formData['invoice'],
                      warrantyData: _formData['warranty'],
                      brandsFuture: Future.value(snapshot.data),
                      percentList: widget.percentList,
                      onValidityChanged: (isValid) {
                        setState(() {
                          _isPage0Valid = isValid;
                        });
                      },
                    ),

                    CustomerDetailsScreen(data: _formData['customer']),
                    InvoiceDetailsScreen(
                      data: _formData['invoice'],
                      productImg: _formData['images'],
                      warrantyData: _formData['warranty'],
                    ),
                    // ProductImagesScreen(data: _formData['images']),
                    // WarrantyDetailsScreen(
                    //   data: _formData['warranty'],
                    // ),
                  ],
                ),
              ),

              // Navigation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.grey),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          child: const Text('Previous'),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed:
                            (_currentPage == 0 && !_isPage0Valid)
                                ? null
                                : (_currentPage == 2
                                    ? () =>
                                        submitCustomerForm(context, _formData)
                                    : _nextPage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (_currentPage == 0 && !_isPage0Valid)
                                  ? Colors
                                      .black // Disabled = Black background
                                  : (_currentPage == 2
                                      ? Colors.green
                                      : Colors.blue[700]),
                          foregroundColor:
                              (_currentPage == 0 && !_isPage0Valid)
                                  ? Colors
                                      .grey
                                      .shade400 // Disabled = Light grey text
                                  : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_currentPage == 2 ? 'Submit Form' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}
