import 'package:flutter/material.dart';

class WarrantyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  WarrantyDetailsScreen({required this.data});

  @override
  State<WarrantyDetailsScreen> createState() => _WarrantyDetailsScreenState();
}

class _WarrantyDetailsScreenState extends State<WarrantyDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
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
          const SizedBox(height: 16),
          // Optional: add date pickers if needed
          // _buildDatePicker('Start Date', 'startDate'),
          // const SizedBox(height: 16),
          // _buildDatePicker('Expiry Date', 'expiryDate'),
        ],
      ),
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
         style: const TextStyle(color: Color(0xFFdccf7b)),

         decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFdccf7b)), // Label color
        filled: true,
        fillColor: Color(0xff131313), // Background color
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFdccf7b)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFdccf7b), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
        keyboardType: type,
        onChanged: (value) => widget.data[key] = value,
      ),
    );
  }
}
