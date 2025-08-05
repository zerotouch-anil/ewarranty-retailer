import 'package:flutter/material.dart';

class WarrantyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const WarrantyDetailsScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<WarrantyDetailsScreen> createState() => _WarrantyDetailsScreenState();
}


class _WarrantyDetailsScreenState extends State<WarrantyDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(6),
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
    final text = widget.data[key]?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: TextEditingController(text: text)
          ..selection = TextSelection.collapsed(offset: text.length),
        readOnly: true, // ✅ Makes the field non-editable
        style: const TextStyle(color: Color(0xFFdccf7b)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFdccf7b)),
          filled: true,
          fillColor: const Color(0xff131313),
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
      ),
    );
  }
}
