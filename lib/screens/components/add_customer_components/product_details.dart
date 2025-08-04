import 'package:flutter/material.dart';
import 'package:retailer_app/models/brands_model.dart';
import 'package:retailer_app/models/categories_model.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends StatefulWidget {
  final void Function(bool isValid) onValidityChanged;
  final Map<String, dynamic> data;
  final Map<String, dynamic> invoiceData;
  final Map<String, dynamic> warrantyData;
  final List<PercentItem> percentList;
  final Future<List<Brand>> brandsFuture;

  ProductDetailsScreen({
    required this.data,
    required this.invoiceData,
    required this.warrantyData,
    required this.percentList,
    required this.brandsFuture,
    required this.onValidityChanged,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Brand? selectedBrand;
  int? selectedDuration;

  void _checkFormValidity() {
    final isValid =
        widget.data['brandId'] != null &&
        widget.data['purchasePrice'] != null &&
        widget.data['orignalWarranty'] != null &&
        widget.invoiceData['invoiceDate'] != null &&
        widget.warrantyData['warrantyPeriod'] != null &&
        widget.warrantyData['premiumAmount'] != null;

    widget.onValidityChanged(isValid);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBrandDropdown(),
            _buildSimpleField(
              'Purchase Price',
              'purchasePrice',
              TextInputType.number,
            ),
            _buildOriginalWarrantyDropdown(),
            _buildDatePicker(),

            // _buildSimpleField('Product Name', 'modelName'),
            // _buildSimpleField(
            //   'Serial Number',
            //   'serialNumber',
            //   TextInputType.text,
            // ),
            if (_isCalculationDataAvailable()) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,

                child: const Text(
                  "Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Company Warranty & Invoice Date Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.verified,
                        "Company Warranty",
                        widget.data["orignalWarranty"],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.calendar_today,
                        "Invoice Date",
                        widget.invoiceData["invoiceDate"] is DateTime
                            ? DateFormat(
                              'yyyy-MM-dd',
                            ).format(widget.invoiceData["invoiceDate"])
                            : 'Invalid date',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Extended Warranty",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              ...widget.percentList.map((item) {
                if (!item.isActive) return const SizedBox.shrink();

                final price =
                    double.tryParse(widget.data["purchasePrice"] ?? "0") ?? 0;
                final calculatedAmount = (price * item.percent) / 100;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),

                        // Duration Text
                        Text(
                          "${item.duration} Month${item.duration > 1 ? 's' : ''}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),

                        // Value Text
                        Text(
                          "₹${calculatedAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Button changes based on selection
                        if (selectedDuration == item.duration)
                          ElevatedButton(
                            onPressed: null, // Disabled
                            child: const Text("Added"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedDuration = item.duration;
                                widget.warrantyData['warrantyPeriod'] =
                                    item.duration;
                                widget.warrantyData['premiumAmount'] =
                                    calculatedAmount;
                              });
                              _checkFormValidity();
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Add",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return FutureBuilder<List<Brand>>(
      future: widget.brandsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text("Error loading brands: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No brands available");
        } else {
          final brands = snapshot.data!;
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<Brand>(
              decoration: const InputDecoration(
                labelText: "Brand",
                border: OutlineInputBorder(),
              ),
              value: selectedBrand,
              isExpanded: true,
              items:
                  brands.map((brand) {
                    return DropdownMenuItem<Brand>(
                      value: brand,
                      child: Text(brand.brandName),
                    );
                  }).toList(),
              onChanged: (Brand? brand) {
                setState(() {
                  selectedBrand = brand;
                  widget.data['brandName'] = brand!.brandName;
                  widget.data['brandId'] = brand.brandId;
                });
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildOriginalWarrantyDropdown() {
    final List<String> warrantyOptions = [
      '1 Year',
      '2 Year',
      '3 Year',
      '4 Year',
      '5 Year',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Original Warranty',
          border: OutlineInputBorder(),
        ),
        value: widget.data['orignalWarranty'],
        isExpanded: true,
        items:
            warrantyOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
        onChanged: (String? value) {
          setState(() {
            widget.data['orignalWarranty'] = value!;
          });
          _checkFormValidity();
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: widget.invoiceData["invoiceDate"] ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => widget.invoiceData["invoiceDate"] = picked);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
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
                'Invoice Date: ${widget.invoiceData["invoiceDate"] is DateTime ? DateFormat('yyyy-MM-dd').format(widget.invoiceData["invoiceDate"]) : 'Not selected'}',
              ),
              Icon(Icons.calendar_today),
            ],
          ),
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
        onChanged: (value) {
          setState(() {
            widget.data[key] = value;
            _checkFormValidity();
          });
        },
      ),
    );
  }

  bool _isCalculationDataAvailable() {
    return widget.data["purchasePrice"] != null &&
        widget.invoiceData["invoiceDate"] != null &&
        widget.data["orignalWarranty"] != null &&
        widget.data["brandId"] != null;
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
