import 'package:flutter/material.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Map<String, String> data;

  CustomerDetailsScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSimpleField('Full Name', 'name'),
          _buildSimpleField('Email', 'email', TextInputType.emailAddress),
          _buildSimpleField('Mobile Number', 'mobile', TextInputType.phone),
          _buildSimpleField(
            'Alternate Number',
            'alternateNumber',
            TextInputType.phone,
          ),
          _buildSimpleField('Street Address', 'street'),
          _buildSimpleField('City', 'city'),
          _buildSimpleField('State', 'state'),
          _buildSimpleField('Country', 'country'),
          _buildSimpleField('Zip Code', 'zipCode', TextInputType.number),
        ],
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
        onChanged: (value) => data[key] = value,
      ),
    );
  }
}