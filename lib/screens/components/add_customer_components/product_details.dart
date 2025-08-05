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
  final List<Brand> brands;

  const ProductDetailsScreen({
    super.key,
    required this.data,
    required this.invoiceData,
    required this.warrantyData,
    required this.percentList,
    required this.brands,
    required this.onValidityChanged,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const Color _goldenColor = Color(0xFFdccf7b);

  Brand? selectedBrand;
  int? selectedDuration;
  final _purchasePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _purchasePriceController.text =
        widget.data['purchasePrice']?.toString() ?? '';
  }

  @override
  void dispose() {
    _purchasePriceController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {

    print("brandId: ${widget.data['brandId']}");
    print("purchasePrice: ${widget.data['purchasePrice']} (${widget.data['purchasePrice'].runtimeType})");
    print("orignalWarranty: ${widget.data['orignalWarranty']} (${widget.data['orignalWarranty'].runtimeType})");
    print("invoiceDate: ${widget.invoiceData['invoiceDate']}");
    print("warrantyPeriod: ${widget.warrantyData['warrantyPeriod']}");
    print("premiumAmount: ${widget.warrantyData['premiumAmount']}");

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 15),
            _buildBrandDropdown(),
            _buildPurchasePriceField(),
            _buildOriginalWarrantyDropdown(),
            _buildDatePicker(),
            if (_isCalculationDataAvailable()) ..._buildCalculationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    final brands = widget.brands;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Brand>(
        decoration: InputDecoration(
          labelText: "Brand",
          labelStyle: const TextStyle(color: _goldenColor),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: _goldenColor.withOpacity(0.1),
        ),
        value: selectedBrand,
        isExpanded: true,
        dropdownColor: const Color.fromARGB(255, 79, 107, 117),
        icon: const Icon(Icons.arrow_drop_down, color: _goldenColor),
        style: const TextStyle(color: _goldenColor, fontSize: 16),
        items:
            brands.map((brand) {
              return DropdownMenuItem<Brand>(
                value: brand,
                child: Text(
                  brand.brandName,
                  style: const TextStyle(color: _goldenColor),
                ),
              );
            }).toList(),
        onChanged: (Brand? brand) {
          if (brand != null) {
            setState(() {
              selectedBrand = brand;
              widget.data['brand'] = brand.brandName;
              widget.data['brandId'] = brand.brandId;
            });
            _checkFormValidity();
          }
        },
      ),
    );
  }

  Widget _buildPurchasePriceField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _purchasePriceController,
        decoration: InputDecoration(
          labelText: 'Purchase Price',
          labelStyle: const TextStyle(color: _goldenColor),
          prefixIcon: const Icon(Icons.currency_rupee, color: _goldenColor),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: _goldenColor.withOpacity(0.1),
        ),
        keyboardType: TextInputType.number,
        style: const TextStyle(color: _goldenColor, fontSize: 16),
        onChanged: (value) {
          setState(() {
            widget.data['purchasePrice'] = value.isNotEmpty ? value : null;
          });
          _checkFormValidity();
        },
      ),
    );
  }

  Widget _buildOriginalWarrantyDropdown() {
    const List<String> warrantyOptions = [
      '1 Year',
      '2 Year',
      '3 Year',
      '4 Year',
      '5 Year',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Original Warranty',
          labelStyle: const TextStyle(color: _goldenColor),
          prefixIcon: const Icon(Icons.verified_outlined, color: _goldenColor),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: _goldenColor.withOpacity(0.1),
        ),
        value: widget.data['orignalWarranty'],
        isExpanded: true,
        dropdownColor: Color.fromARGB(255, 79, 107, 117),
        icon: const Icon(Icons.arrow_drop_down, color: _goldenColor),
        style: const TextStyle(color: _goldenColor, fontSize: 16),
        items:
            warrantyOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(color: _goldenColor),
                ),
              );
            }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              widget.data['orignalWarranty'] = value;
            });
            _checkFormValidity();
          }
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    final DateTime today = DateTime.now();
    final DateTime sixMonthsAgo = DateTime(
      today.year,
      today.month - 6,
      today.day,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: widget.invoiceData["invoiceDate"] ?? today,
            firstDate: sixMonthsAgo,
            lastDate: today,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: _goldenColor,
                    onPrimary: Colors.white,
                    surface: const Color.fromARGB(255, 79, 107, 117),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.green;
                          }
                          return Colors.black;
                        },
                      ),
                    ),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    return Localizations.override(
                      context: context,
                      locale: Locale('en', 'US'),
                      child: child!,
                    );
                  },
                ),
              );
            },
          );

          if (picked != null) {
            setState(() {
              widget.invoiceData["invoiceDate"] = picked;
            });
            _checkFormValidity();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
            color: _goldenColor.withOpacity(0.1),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: _goldenColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.invoiceData["invoiceDate"] is DateTime
                      ? 'Invoice Date: ${DateFormat('yyyy-MM-dd').format(widget.invoiceData["invoiceDate"])}'
                      : 'Select Invoice Date',
                  style: const TextStyle(color: _goldenColor, fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: _goldenColor),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalculationSection() {
    return [
      const SizedBox(height: 16),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _goldenColor,
          ),
        ),
      ),
      const SizedBox(height: 12),
      _buildDetailsCard(),
      const SizedBox(height: 16),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Extended Warranty",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _goldenColor,
          ),
        ),
      ),
      const SizedBox(height: 8),
      ..._buildWarrantyCards(),
    ];
  }

  Widget _buildDetailsCard() {
    return Card(
      color: Color(0xff131313),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _goldenColor, width: 1),
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
              widget.data["orignalWarranty"] ?? "Not selected",
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.calendar_today,
              "Invoice Date",
              widget.invoiceData["invoiceDate"] is DateTime
                  ? DateFormat(
                    'yyyy-MM-dd',
                  ).format(widget.invoiceData["invoiceDate"])
                  : 'Not selected',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWarrantyCards() {
    final price = double.tryParse(widget.data["purchasePrice"] ?? "0") ?? 0;

    return widget.percentList.where((item) => item.isActive).map((item) {
      final calculatedAmount = (price * item.percent) / 100;
      final isSelected = selectedDuration == item.duration;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? _goldenColor : _goldenColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        elevation: 2,
        color:
            isSelected
                ? _goldenColor.withOpacity(0.1)
                : Color.fromARGB(255, 79, 107, 117),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.access_time, color: _goldenColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "${item.duration} Month${item.duration > 1 ? 's' : ''}",
                style: const TextStyle(
                  fontSize: 14,
                  color: _goldenColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "₹${calculatedAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _goldenColor,
                ),
              ),
              const SizedBox(width: 12),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _goldenColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _goldenColor),
                  ),
                  child: const Text(
                    "Added",
                    style: TextStyle(
                      color: _goldenColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedDuration = item.duration;
                      widget.warrantyData['warrantyPeriod'] = item.duration;
                      widget.warrantyData['premiumAmount'] = calculatedAmount;
                    });
                    _checkFormValidity();
                  },
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldenColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
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
        Icon(icon, color: _goldenColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: _goldenColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: _goldenColor,
          ),
        ),
      ],
    );
  }
}
