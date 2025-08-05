import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerDetailsScreen extends StatefulWidget {
  final Map<String, String> data;
  final void Function(bool isValid) onValidityChanged2;

  CustomerDetailsScreen({
    required this.data,
    required this.onValidityChanged2,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final Map<String, TextEditingController> _controllers = {};
bool _lastValidityState = false;
  final List<String> _fields = [
    'name',
    'email',
    'mobile',
    'alternateNumber',
    'street',
    'city',
    'state',
    'country',
    'zipCode',
  ];

  @override
void initState() {
  super.initState();
  for (var key in _fields) {
    _controllers[key] = TextEditingController(text: widget.data[key] ?? '');
    _controllers[key]!.addListener(() {
      widget.data[key] = _controllers[key]!.text;
      if (key == 'zipCode' && _controllers[key]!.text.length == 6) {
        _fetchLocationFromPin(_controllers[key]!.text);
      }
      _checkFormValidity2();
    });
  }

  // Initialize the validity state
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkFormValidity2();
  });
}

  void _checkFormValidity2() {
  // Use a more efficient validation that stops at first invalid field
  bool isValid = true;
  
  for (String key in _fields) {
    final value = widget.data[key];
    if (value == null || value.trim().isEmpty) {
      isValid = false;
      break; // Stop checking once we find an invalid field
    }
  }
  
  // Only call the callback if validity state has changed
  if (_lastValidityState != isValid) {
    _lastValidityState = isValid;
    widget.onValidityChanged2(isValid);
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

        _checkFormValidity2(); // Re-check validity after auto-filling
      }
    }
  }

  Widget _buildSimpleField(String label, String key,
      [TextInputType? inputType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[key],
        keyboardType: inputType,
        style: const TextStyle(color: Color(0xFFdccf7b)), // Text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFdccf7b)), // Label color
          filled: true,
          fillColor: const Color(0xff131313), // Background color
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFdccf7b)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color(0xFFdccf7b), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 15),
          _buildSimpleField('Full Name', 'name'),
          _buildSimpleField('Email', 'email', TextInputType.emailAddress),
          _buildSimpleField('Mobile Number', 'mobile', TextInputType.phone),
          _buildSimpleField(
              'Alternate Number', 'alternateNumber', TextInputType.phone),
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
