import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retailer_app/models/customers_list_model.dart';
import 'package:retailer_app/screens/retailer_customer_details.dart';
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
      // Check if user has scrolled to the bottom
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Load more data if available and not already loading
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff131313),
      appBar: AppBar(
        foregroundColor: Color(0xFFdccf7b),
        backgroundColor: Color(0xff131313),
        title: const Text(
          'Customer List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Column(
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
                    SizedBox(
                      width:
                          MediaQuery.of(context).size.width > 600
                              ? 250
                              : MediaQuery.of(context).size.width / 2 - 24,
                      child: TextField(
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF1976D2),
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
                        ),
                        onTap:
                            () => _pickDate(
                              controller: _startDateController,
                              isStart: true,
                            ),
                      ),
                    ),
                    SizedBox(
                      width:
                          MediaQuery.of(context).size.width > 600
                              ? 250
                              : MediaQuery.of(context).size.width / 2 - 24,
                      child: TextField(
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF1976D2),
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
                        ),
                        onTap:
                            () => _pickDate(
                              controller: _endDateController,
                              isStart: false,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _onSearchPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon:
                              _isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                          label: Text(
                            _isLoading ? 'Searching...' : 'Search',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
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
                              color: Colors.blue,
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
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchCustomers(isRefresh: true),
              child: const Text('Retry'),
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
      padding: const EdgeInsets.all(16),
      itemCount: _allCustomers.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom when loading more
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

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ViewCustomer(customerId: customer.customerId),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Color(0xff131313),
              border: Border.all(color: Color(0xFFdccf7b), width: 0.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                              DateFormat.yMMMd().format(customer.createdDate),
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

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  /// --- Warranty Key ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xff131313),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
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

                  const SizedBox(height: 16),
                  if (customer.notes?.isNotEmpty == true)
                    Row(
                      children: [
                        const SizedBox(width: 8),
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
              ),
            ),
          ),
        );
      },
    );
  }
}
