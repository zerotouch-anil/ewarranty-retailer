import 'package:flutter/material.dart';
import 'package:retailer_app/models/history_model.dart';
import 'package:retailer_app/screens/retailer_drawer.dart';
import 'package:retailer_app/services/history_service.dart';

class HistoryData extends StatefulWidget {
  const HistoryData({super.key});

  @override
  State<HistoryData> createState() => _HistoryDataState();
}

class _HistoryDataState extends State<HistoryData> {
  List<RetailerHistoryData> _allHistoryData = [];
  HistoryPaginationData? _historyPaginationData;

  // Filter variables
  String _selectedTransactionType = 'ALL';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 60));
  DateTime _endDate = DateTime.now();

  // Pagination variables
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  final List<String> _transactionTypes = [
    'ALL',
    'ALLOCATION',
    'WARRANTY_USAGE',
    'REVOKE',
    'REFUND',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _currentPage = 1;
        _allHistoryData.clear();
        _hasMoreData = true;
      }
    });

    try {
      final data = await fetchRetailerHistoryData({
        "page": _currentPage,
        "limit": 20,
        "transactionType": _selectedTransactionType,
        "startDate":
            "${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}",
        "endDate":
            "${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}",
        "sortBy": "createdAt",
        "sortOrder": "desc",
      });

      setState(() {
        if (isRefresh) {
          _allHistoryData = data.retailerHistory;
        } else {
          _allHistoryData.addAll(data.retailerHistory);
        }
        _historyPaginationData = data.historyPagination;
        _hasMoreData = _currentPage < (data.historyPagination?.totalPages ?? 0);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMoreData || _isLoading) return;

    _currentPage++;
    await _loadData();
  }

  void _onFilterChanged() {
    _loadData(isRefresh: true);
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _onFilterChanged();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _onFilterChanged();
    }
  }

  void _onTransactionTypeChanged(String? value) {
    if (value != null && value != _selectedTransactionType) {
      setState(() {
        _selectedTransactionType = value;
      });
      _onFilterChanged();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTransactionTypeColor(String transactionType) {
    switch (transactionType) {
      case 'ALLOCATION':
        return Colors.green;
      case 'WARRANTY_USAGE':
        return Colors.red;
      case 'REVOKE':
        return Colors.orange;
      case 'REFUND':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(String transactionType) {
    switch (transactionType) {
      case 'ALLOCATION':
        return Icons.add_circle;
      case 'WARRANTY_USAGE':
        return Icons.build;
      case 'REVOKE':
        return Icons.remove_circle;
      case 'REFUND':
        return Icons.money_off;
      default:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff131313),
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Color(0xff131313),
        foregroundColor: Color(0xFFdccf7b),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectStartDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFdccf7b)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xff131313),
                                ),

                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFFdccf7b),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Start Date',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            _formatDateShort(_startDate),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectEndDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFdccf7b)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xff131313),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFFdccf7b),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'End Date',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            _formatDateShort(_endDate),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Transaction Type Filter Row
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: Color(0xFFdccf7b)),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter by ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFFdccf7b),
                      ),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFdccf7b)),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xff131313),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTransactionType,
                            onChanged: _onTransactionTypeChanged,
                            isExpanded: true,
                            items:
                                _transactionTypes.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color:
                                            option == 'ALL'
                                                ? Colors.grey[600]
                                                : _getTransactionTypeColor(
                                                  option,
                                                ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Data List Section
          Expanded(
            child:
                _allHistoryData.isEmpty && !_isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _selectedTransactionType == 'ALL'
                                ? 'No history data found for the selected date range.'
                                : 'No $_selectedTransactionType transactions found for the selected date range.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadData(isRefresh: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: () => _loadData(isRefresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            _allHistoryData.length + (_hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Loading indicator at bottom
                          if (index == _allHistoryData.length) {
                            return _isLoading
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final history = _allHistoryData[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xff131313),
                                border: Border.all(
                                  color: Color(0xFFdccf7b),
                                  width:1.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getTransactionTypeColor(
                                              history.transactionType,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: _getTransactionTypeColor(
                                                history.transactionType,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getTransactionTypeIcon(
                                                  history.transactionType,
                                                ),
                                                size: 16,
                                                color: _getTransactionTypeColor(
                                                  history.transactionType,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                history.transactionType,
                                                style: TextStyle(
                                                  color:
                                                      _getTransactionTypeColor(
                                                        history.transactionType,
                                                      ),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          history.transactionType ==
                                                  "WARRANTY_USAGE"
                                              ? '-₹${history.amount}'
                                              : '₹${history.amount}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _getTransactionTypeColor(
                                              history.transactionType,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Customer Information
                                    if (history.transactionType ==
                                        "WARRANTY_USAGE")
                                      _buildInfoRow(
                                        'Customer Name',
                                        history.customerDetails?.customerName ??
                                            'n/a',
                                        Icons.person,
                                      ),

                                    const SizedBox(height: 8),

                                    // Warranty Key
                                    if (history.transactionType ==
                                        "WARRANTY_USAGE")
                                      _buildInfoRow(
                                        'Warranty Key',
                                        history.warrantyKey ?? 'n/a',
                                        Icons.vpn_key,
                                      ),

                                    if (history.transactionType == "ALLOCATION")
                                      _buildInfoRow(
                                        'Transaction Id',
                                        history.transactionId,
                                        Icons.vpn_key,
                                      ),

                                    const SizedBox(height: 8),

                                    // User Types Row
                                    Row(
                                      children: [
                                        if (history.transactionType ==
                                            "ALLOCATION")
                                          Expanded(
                                            child: _buildInfoRow(
                                              'From',
                                              history.fromUser != null
                                                  ? '${history.fromUser!.name} (${history.fromUser!.userType})'
                                                  : 'n/a',
                                              Icons.person_outline,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoRow(
                                            'Notes',
                                            history.notes ?? "n/a",
                                            Icons.notes,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Date
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.schedule,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDate(
                                              history.transactionDate,
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
