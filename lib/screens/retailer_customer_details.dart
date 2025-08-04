import 'package:flutter/material.dart';
import 'package:retailer_app/models/customer_details_model.dart';
import 'package:retailer_app/services/customer_service.dart';

class ViewCustomer extends StatefulWidget {
  final String customerId;

  const ViewCustomer({super.key, required this.customerId});

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Customer Details',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: FutureBuilder<ParticularCustomerData>(
        future: fetchCustomerDetails(widget.customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 16, color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else {
            final customer = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerDetailsSection(customer.customerDetails),
                  const SizedBox(height: 20),
                  _buildProductDetailsSection(customer.productDetails),
                  const SizedBox(height: 20),
                  _buildProductImagesSection(customer.productImages),
                  const SizedBox(height: 20),
                  _buildInvoiceDetailsSection(customer.invoiceDetails),
                  const SizedBox(height: 20),
                  _buildWarrantyDetailsSection(customer.warrantyDetails),
                  const SizedBox(height: 20),
                  _buildAdditionalInfoSection(customer),
                  const SizedBox(height: 20),
                  _buildDatesSection(customer.dates),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Color? borderColor,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor ?? Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? ' Not provided' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey[500] : Colors.black87,
                fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsSection(CustomerDetails details) {
    return _buildSectionCard(
      title: 'Customer Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Name',
            value: details.name,
            icon: Icons.person_outline,
          ),
          _buildInfoRow(
            label: 'Email',
            value: details.email,
            icon: Icons.email_outlined,
          ),
          _buildInfoRow(
            label: 'Mobile',
            value: details.mobile,
            icon: Icons.phone_outlined,
          ),
          _buildInfoRow(
            label: 'Alternate Number',
            value: details.alternateNumber,
            icon: Icons.phone_android_outlined,
          ),
          const Divider(height: 24),
          _buildAddressSection(details.address),
        ],
      ),
     borderColor: Colors.purple[600],
    );
  }

  Widget _buildAddressSection(Address address) {
    final fullAddress = [
      address.street,
      address.city,
      address.state,
      address.country,
      address.zipCode,
    ].where((element) => element.isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            fullAddress.isEmpty ? 'Not provided' : fullAddress,
            style: TextStyle(
              fontSize: 14,
              color: fullAddress.isEmpty ? Colors.grey[500] : Colors.black87,
              fontWeight:
                  fullAddress.isEmpty ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsSection(ProductDetails details) {
    return _buildSectionCard(
      title: 'Product Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Model Name',
            value: details.modelName,
            icon: Icons.smartphone_outlined,
          ),
          _buildInfoRow(
            label: 'Brand',
            value: details.brand,
            icon: Icons.branding_watermark_outlined,
          ),
          _buildInfoRow(
            label: 'Category',
            value: details.category,
            icon: Icons.category_outlined,
          ),
          _buildInfoRow(
            label: 'Serial Number',
            value: details.serialNumber,
            icon: Icons.pin_outlined,
          ),
          _buildInfoRow(
            label: 'Orignal Warranty',
            value: details.orignalWarranty > 0 ? '${details.orignalWarranty}': '',
            icon: Icons.pin_outlined,
          ),
          _buildInfoRow(
            label: 'Purchase Price',
            value: details.purchasePrice > 0 ? '₹${details.purchasePrice}' : '',
            icon: Icons.currency_rupee_outlined,
          ),
        ],
      ),
    borderColor: Colors.green[600],
    );
  }

  Widget _buildProductImagesSection(ProductImages images) {
    final List<String> allImages = [
      if (images.frontImage.isNotEmpty) images.frontImage,
      if (images.backImage.isNotEmpty) images.backImage,
      ...images.additionalImages,
    ];

    return _buildSectionCard(
      title: 'Product Images',
      child:
          allImages.isEmpty
              ? Text(
                'No images available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              )
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showImageDialog(allImages[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          allImages[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      borderColor: Colors.teal[600],
    );
  }

  Widget _buildInvoiceDetailsSection(InvoiceDetails details) {
    return _buildSectionCard(
      title: 'Invoice Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Invoice Number',
            value: details.invoiceNumber,
            icon: Icons.receipt_outlined,
          ),
          _buildInfoRow(
            label: 'Invoice Amount',
            value: details.invoiceAmount > 0 ? '₹${details.invoiceAmount}' : '',
            icon: Icons.currency_rupee_outlined,
          ),
          _buildInfoRow(
            label: 'Invoice Date',
            value: _formatDate(details.invoiceDate),
            icon: Icons.calendar_today_outlined,
          ),
          if (details.invoiceImage.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showImageDialog(details.invoiceImage),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    details.invoiceImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      borderColor: Colors.pink[600],
    );
  }

  Widget _buildWarrantyDetailsSection(WarrantyDetails details) {
    final bool isActive = details.expiryDate.isAfter(DateTime.now());

    return _buildSectionCard(
      title: 'Warranty Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Plan Name',
            value: details.planName,
            icon: Icons.security_outlined,
          ),
          _buildInfoRow(
            label: 'Plan ID',
            value: details.planId,
            icon: Icons.confirmation_number_outlined,
          ),
          _buildInfoRow(
            label: 'Warranty Period',
            value:
                details.warrantyPeriod > 0
                    ? '${details.warrantyPeriod} months'
                    : '',
            icon: Icons.timer_outlined,
          ),
          _buildInfoRow(
            label: 'Start Date',
            value: _formatDate(details.startDate),
            icon: Icons.play_arrow_outlined,
          ),
          _buildInfoRow(
            label: 'Expiry Date',
            value: _formatDate(details.expiryDate),
            icon: Icons.stop_outlined,
          ),
          _buildInfoRow(
            label: 'Premium Amount',
            value: details.premiumAmount > 0 ? '₹${details.premiumAmount}' : '',
            icon: Icons.currency_rupee_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 16,
                  color: isActive ? Colors.green[700] : Colors.red[700],
                ),
                const SizedBox(width: 6),
                Text(
                  isActive ? 'Active' : 'Expired',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      borderColor: Colors.green[600],
    );
  }



  Widget _buildAdditionalInfoSection(ParticularCustomerData customer) {
    return _buildSectionCard(
      title: 'Additional Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Customer ID',
            value: customer.customerId,
            icon: Icons.person_outline,
          ),
          _buildInfoRow(
            label: 'Warranty Key',
            value: customer.warrantyKey,
            icon: Icons.vpn_key_outlined,
          ),
          Row(
            children: [
              Icon(Icons.toggle_on_outlined, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        customer.isActive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          customer.isActive
                              ? Colors.green[200]!
                              : Colors.red[200]!,
                    ),
                  ),
                  child: Text(
                    customer.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          customer.isActive
                              ? Colors.green[700]
                              : Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          if (customer.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_outlined, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.notes,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      borderColor: Colors.yellow[600],
    );
  }

  Widget _buildDatesSection(CustomerDates dates) {
    return _buildSectionCard(
      title: 'Important Dates',
      child: Column(
        children: [
          if (dates.pickedDate != null)
            _buildInfoRow(
              label: 'Picked Date',
              value: _formatDate(dates.pickedDate!),
              icon: Icons.event_outlined,
            ),
          _buildInfoRow(
            label: 'Created Date',
            value: _formatDate(dates.createdDate),
            icon: Icons.add_circle_outline,
          ),
          _buildInfoRow(
            label: 'Last Modified',
            value: _formatDate(dates.lastModifiedDate),
            icon: Icons.update_outlined,
          ),
        ],
      ),
      borderColor: Colors.blue[600],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
