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
  final String categoryName;
  final List<PercentItem> percentList;

  const CustomerForm({
    super.key,
    required this.categoryId,
    required this.percentList,
    required this.categoryName,
  });

  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late Future<List<Brand>> _brandsFuture;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  bool _isPage0Valid = false;
  bool _isPage1Valid = false;

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
  void initState() {
    super.initState();

    _formData['product']['categoryId'] = widget.categoryId;
    _formData['product']['category'] = widget.categoryName;
    _brandsFuture = fetchBrands(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff131313),
      appBar: AppBar(
        title: Text(_pageTitles[_currentPage]),
        backgroundColor: const Color(0xff131313),
        foregroundColor: const Color(0xFFdccf7b),
        elevation: 1,
      ),
      body: FutureBuilder<List<Brand>>(
        future: _brandsFuture,
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
                children: const [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'No brands found',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFFdccf7b)),
                  ),
                ],
              ),
            );
          }

          final List<Brand> brands = snapshot.data!;

          return Column(
            children: [
              // Progress bar
              Container(
                height: 4,
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 3,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[500]!),
                ),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged:
                      (index) => setState(() => _currentPage = index),
                  children: [
                    ProductDetailsScreen(
                      data: _formData['product'],
                      invoiceData: _formData['invoice'],
                      warrantyData: _formData['warranty'],
                      brands: brands,
                      percentList: widget.percentList,
                      onValidityChanged: (isValid) {
                        setState(() {
                          _isPage0Valid = isValid;
                        });
                      },
                    ),
                    CustomerDetailsScreen(
                      data: _formData['customer'],
                      onValidityChanged2: (isValid) {
                        setState(() {
                          _isPage1Valid = isValid;
                        });
                      },
                    ),
                    InvoiceDetailsScreen(
                      data: _formData['invoice'],
                      productImg: _formData['images'],
                      warrantyData: _formData['warranty'],
                      productDetails: _formData['product'],
                    ),
                  ],
                ),
              ),

              // Navigation Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.grey),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color.fromARGB(
                              255,
                              49,
                              48,
                              43,
                            ),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 75, 74, 70),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _getNextButtonAction(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonBackgroundColor(),
                          foregroundColor: _getButtonForegroundColor(),
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

  VoidCallback? _getNextButtonAction() {
    if (_currentPage == 0 && !_isPage0Valid) return null;
    if (_currentPage == 1 && !_isPage1Valid) return null;
    if (_currentPage == 2) {
      return () => submitCustomerForm(context, _formData);
    }
    return _nextPage;
  }

  Color _getButtonBackgroundColor() {
    bool isCurrentPageInvalid =
        (_currentPage == 0 && !_isPage0Valid) ||
        (_currentPage == 1 && !_isPage1Valid);

    if (isCurrentPageInvalid) {
      return Colors.black;
    } else if (_currentPage == 2) {
      return const Color.fromARGB(255, 28, 105, 30);
    } else {
      return Colors.blue[700]!;
    }
  }

  Color _getButtonForegroundColor() {
    bool isCurrentPageInvalid =
        (_currentPage == 0 && !_isPage0Valid) ||
        (_currentPage == 1 && !_isPage1Valid);

    return isCurrentPageInvalid ? Colors.grey.shade400 : Colors.white;
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}
