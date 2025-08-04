import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerDetailsScreen extends StatefulWidget {
  final Map<String, String> data;

  CustomerDetailsScreen({required this.data});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var key in [
      'name',
      'email',
      'mobile',
      'alternateNumber',
      'street',
      'city',
      'state',
      'country',
      'zipCode',
    ]) {
      _controllers[key] = TextEditingController(text: widget.data[key]);
    }
  }

  Future<void> _fetchLocationFromPin(String pin) async {
    if (pin.length != 6) return;

    final url = Uri.parse('https://api.postalpincode.in/pincode/$pin');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty && data[0]['Status'] == 'Success') {
        final postOffice = data[0]['PostOffice'][0];
        final city = postOffice['District'];
        final state = postOffice['State'];
        final country = postOffice['Country'];

        setState(() {
          _controllers['city']?.text = city;
          _controllers['state']?.text = state;
          _controllers['country']?.text = country;

          widget.data['city'] = city;
          widget.data['state'] = state;
          widget.data['country'] = country;
        });
      }
    }
  }

 Widget _buildSimpleField(String label, String key, [TextInputType? type]) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: _controllers[key],
      keyboardType: type,
      style: const TextStyle(color: Color(0xFFdccf7b)), // Input text color
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
      onChanged: (value) {
        widget.data[key] = value;
        if (key == 'zipCode' && value.length == 6) {
          _fetchLocationFromPin(value);
        }
      },
    ),
  );
}


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
          _buildSimpleField('Zip Code', 'zipCode', TextInputType.number),
          _buildSimpleField('City', 'city'),
          _buildSimpleField('State', 'state'),
          _buildSimpleField('Country', 'country'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
