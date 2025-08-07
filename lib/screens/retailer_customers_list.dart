import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retailer_app/models/customers_list_model.dart';
import 'package:retailer_app/screens/retailer_customer_details.dart';
import 'package:retailer_app/utils/wooden_container.dart';
import '../services/customer_service.dart';

class RetailerViewCustomers extends StatefulWidget {
  const RetailerViewCustomers({Key? key}) : super(key: key);

  @override
  State<RetailerViewCustomers> createState() => _RetailerViewCustomersState();
}

class _RetailerViewCustomersState extends State<RetailerViewCustomers> {
  List<CustomersData> _allCustomers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  PaginationData? _paginationData;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchCustomers(isRefresh: true);
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_paginationData != null &&
            _paginationData!.currentPage < _paginationData!.totalPages &&
            !_isLoadingMore) {
          _loadMoreCustomers();
        }
      }
    });
  }

  void _fetchCustomers({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _allCustomers.clear();
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    final now = DateTime.now();
    final startDate = _selectedStartDate ?? now.subtract(Duration(days: 7));
    final endDate = _selectedEndDate ?? now;

    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      final response = await fetchAllCustomers({
        "page": _currentPage,
        "limit": 20,
        "startDate": startDateStr,
        "endDate": endDateStr,
        "sortBy": "createdDate",
        "sortOrder": "desc",
      });

      setState(() {
        if (isRefresh) {
          _allCustomers = response.customers;
        } else {
          _allCustomers.addAll(response.customers);
        }
        _paginationData = response.pagination;
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  void _loadMoreCustomers() {
    if (_paginationData != null &&
        _paginationData!.currentPage < _paginationData!.totalPages) {
      setState(() {
        _currentPage++;
        _isLoadingMore = true;
      });
      _fetchCustomers();
    }
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required bool isStart,
  }) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(pickedDate);
        controller.text = formatted;
        if (isStart) {
          _selectedStartDate = pickedDate;
        } else {
          _selectedEndDate = pickedDate;
        }
      });
    }
  }

  void _onSearchPressed() {
    _fetchCustomers(isRefresh: true);
  }

  // Calculate dynamic height based on screen size and content
  double _calculateWoodContainerHeight(
    BuildContext context,
    CustomersData customer,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double baseHeight = 50;
    double headerHeight = screenWidth * 0.12 + 20;
    double productInfoHeight = 35;
    double premiumAmountHeight = 55;
    double warrantyKeyHeight = 50;

    double notesHeight = 0;
    if (customer.notes?.isNotEmpty == true) {
      notesHeight = 30;
    }

    double totalHeight =
        baseHeight +
        headerHeight +
        productInfoHeight +
        premiumAmountHeight +
        warrantyKeyHeight +
        notesHeight;

    double minHeight = screenHeight * 0.25;

    return totalHeight > minHeight ? totalHeight : minHeight;
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    extendBodyBehindAppBar: true, // Allows AppBar to sit above background
    appBar: AppBar(
      foregroundColor: Color(0xFFdccf7b),
      backgroundColor: Colors.transparent,
      title: const Text(
        'Customer List',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevation: 0,
    ),
    body: Stack(
      children: [
        // Background image with dark overlay
        Positioned.fill(
          child: Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        // Your main content
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: [
                        // Start Date
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 250
                              : MediaQuery.of(context).size.width / 2 - 24,
                          child: TextField(
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            controller: _startDateController,
                            decoration: _buildInputDecoration('Start Date'),
                            onTap: () => _pickDate(
                              controller: _startDateController,
                              isStart: true,
                            ),
                          ),
                        ),
                        // End Date
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 250
                              : MediaQuery.of(context).size.width / 2 - 24,
                          child: TextField(
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            controller: _endDateController,
                            decoration: _buildInputDecoration('End Date'),
                            onTap: () => _pickDate(
                              controller: _endDateController,
                              isStart: false,
                            ),
                          ),
                        ),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _onSearchPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFdccf7b),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    ),
                              label: Text(
                                _isLoading ? 'Searching...' : 'Search',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_paginationData != null)
                              Text(
                                '(${_paginationData?.totalData ?? '-'})',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFdccf7b),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildCustomerList()),
            ],
          ),
        ),
      ],
    ),
  
  );
}

// Helper function for consistent TextField style
InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: const Icon(
      Icons.calendar_today,
      color: Color(0xFFdccf7b),
    ),
    filled: true,
    fillColor: Color(0xff131313),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 4,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Color(0xFFdccf7b),
        width: 0.5,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Color(0xFFdccf7b),
        width: 0.5,
      ),
    ),
  );
}
  Widget _buildCustomerList() {
    if (_isLoading && _allCustomers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
        ),
      );
    }

    if (_hasError && _allCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53E3E)),
            const SizedBox(height: 16),
            Text(
              'Failed loading customers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: Color(0xFFdccf7b),
                    width: 1,
                  ),
                ),
              ),
              onPressed: () => _fetchCustomers(isRefresh: true),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_allCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No customers yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customer data will appear here once available',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      itemCount: _allCustomers.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allCustomers.length && _isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            ),
          );
        }

        final customer = _allCustomers[index];
        final screenWidth = MediaQuery.of(context).size.width;
        final dynamicHeight = _calculateWoodContainerHeight(context, customer);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: WoodContainer(
            height: dynamicHeight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ViewCustomer(customerId: customer.customerId),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// --- Customer Name Header ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF1976D2),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFdccf7b),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat.yMMMd().format(
                                    customer.createdDate,
                                  ),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// --- Product Info ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.devices,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                customer.modelName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.036,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// --- Premium Amount ---
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.currency_rupee,
                              size: 20,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${customer.premiumAmount}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromARGB(255, 5, 145, 40),
                                ),
                              ),
                              Text(
                                'Premium Amount',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// --- Warranty Key ---
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xff131313),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.security,
                              size: 18,
                              color: Color.fromARGB(255, 7, 122, 74),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                customer.warrantyKey,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromARGB(255, 4, 216, 181),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// --- Notes (only if present) ---
                      if (customer.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              "Notes: ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                customer.notes!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.lightGreen.shade700,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
