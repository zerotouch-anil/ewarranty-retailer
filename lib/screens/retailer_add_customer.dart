import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retailer_app/models/brands_model.dart';
import 'package:retailer_app/models/categories_model.dart';
import 'package:retailer_app/models/warranty_plans_model.dart';
import 'package:retailer_app/screens/components/add_customer_components/customer_details.dart';
import 'package:retailer_app/screens/components/add_customer_components/invoice_details.dart';
import 'package:retailer_app/screens/components/add_customer_components/product_details.dart';
import 'package:retailer_app/screens/components/add_customer_components/product_images.dart';
import 'package:retailer_app/services/catalog_service.dart';
import 'package:retailer_app/services/customer_form_submit.dart';
import 'package:retailer_app/services/customer_service.dart';

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
  late Future<List<WarrantyPlans>> _warrantyPlans;
  bool _isPage0Valid = false;

  @override
  void initState() {
    super.initState();

    _warrantyPlans = fetchWarrantyPlans();
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
    'Product Details',
    'Customer Info',
    'Invoice Details',
    'Product Images',
    'Warranty Info',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_pageTitles[_currentPage]),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
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
                  value: (_currentPage + 1) / 5,
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
                    InvoiceDetailsScreen(data: _formData['invoice']),
                    ProductImagesScreen(data: _formData['images']),
                    WarrantyDetailsScreen(
                      data: _formData['warranty'],
                      warrantyPlansFuture: _warrantyPlans,
                    ),
                  ],
                ),
              ),

              // Navigation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white),
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
                                : (_currentPage == 4
                                    ? () =>
                                        submitCustomerForm(context, _formData)
                                    : _nextPage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (_currentPage == 0 && !_isPage0Valid)
                                  ? Colors.grey
                                  : (_currentPage == 4
                                      ? Colors.green
                                      : Colors.blue[700]),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_currentPage == 4 ? 'Submit Form' : 'Next'),
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

// product details

// customer details

// invoic screen

// product images screen

class WarrantyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Future<List<WarrantyPlans>> warrantyPlansFuture;

  WarrantyDetailsScreen({
    required this.data,
    required this.warrantyPlansFuture,
  });

  @override
  State<WarrantyDetailsScreen> createState() => _WarrantyDetailsScreenState();
}

class _WarrantyDetailsScreenState extends State<WarrantyDetailsScreen> {
  WarrantyPlans? selectedPlan;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WarrantyPlans>>(
      future: widget.warrantyPlansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(child: Text('Failed to load warranty plans.'));
        }

        final plans = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Dropdown
              DropdownButtonFormField<WarrantyPlans>(
                decoration: InputDecoration(
                  labelText: 'Select Warranty Plan',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: selectedPlan,
                isExpanded: true,
                items:
                    plans.map((plan) {
                      return DropdownMenuItem<WarrantyPlans>(
                        value: plan,
                        child: Text(
                          '${plan.planName} (${plan.duration} months, ₹${plan.premiumAmount})',
                        ),
                      );
                    }).toList(),
                onChanged: (WarrantyPlans? plan) {
                  if (plan != null) {
                    setState(() {
                      selectedPlan = plan;

                      // Fill the fields with selected plan data
                      widget.data['planId'] = plan.planId;
                      widget.data['planName'] = plan.planName;
                      widget.data['warrantyPeriod'] = plan.duration;
                      widget.data['premiumAmount'] = plan.premiumAmount;
                    });
                  }
                },
              ),

              SizedBox(height: 16),

              _buildSimpleField('Plan ID', 'planId'),
              _buildSimpleField('Plan Name', 'planName'),
              _buildSimpleField(
                'Warranty Period (months)',
                'warrantyPeriod',
                TextInputType.number,
              ),
              _buildSimpleField(
                'Premium Amount',
                'premiumAmount',
                TextInputType.number,
              ),
              SizedBox(height: 16),
              // _buildDatePicker('Start Date', 'startDate'),
              // SizedBox(height: 16),
              // _buildDatePicker('Expiry Date', 'expiryDate'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleField(String label, String key, [TextInputType? type]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: TextEditingController(
            text: widget.data[key]?.toString() ?? '',
          )
          ..selection = TextSelection.collapsed(
            offset: (widget.data[key]?.toString() ?? '').length,
          ),
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

  Widget _buildDatePicker(String label, String key) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: widget.data[key],
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => widget.data[key] = picked);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label: ${DateFormat('yyyy-MM-dd').format(widget.data[key])}',
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
