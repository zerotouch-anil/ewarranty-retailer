import 'package:flutter/material.dart';
import 'package:retailer_app/models/brands_model.dart';
import 'package:retailer_app/models/categories_model.dart';
import 'package:retailer_app/screens/add_customer/second_part.dart';
import 'package:retailer_app/screens/add_customer/third_part.dart';
import 'package:retailer_app/screens/add_customer/first_part.dart';
import 'package:retailer_app/services/catalog_service.dart';
import 'package:retailer_app/services/customer_form_submit.dart';

class AddCustomerScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final List<PercentItem> percentList;

  const AddCustomerScreen({
    super.key,
    required this.categoryId,
    required this.percentList,
    required this.categoryName,
  });

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  late Future<List<Brand>> _brandsFuture;
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
      'leftImage': null,
      'rightImage': null,
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

  void _goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < 3) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _submitForm() {
    submitCustomerForm(context, _formData);
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
                    FirstPart(
                      data: _formData['product'],
                      invoiceData: _formData['invoice'],
                      warrantyData: _formData['warranty'],
                      brands: brands,
                      percentList: widget.percentList,
                      onNext: _nextPage,
                      currentPage: 0,
                      totalPages: 3,
                    ),
                    SecondPart(
                      data: _formData['customer'],
                      onNext: _nextPage,
                      onPrevious: _previousPage,
                      currentPage: 1,
                      totalPages: 3,
                    ),
                    ThirdPart(
                      data: _formData['invoice'],
                      productImg: _formData['images'],
                      warrantyData: _formData['warranty'],
                      productDetails: _formData['product'],
                      onPrevious: _previousPage,
                      onSubmit: _submitForm,
                      currentPage: 2,
                      totalPages: 3,
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
}
