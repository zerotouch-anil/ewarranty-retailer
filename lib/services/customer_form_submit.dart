import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retailer_app/screens/retailer_dashboard.dart';
import 'package:retailer_app/services/customer_service.dart';

Future<void> submitCustomerForm(
  BuildContext context,
  Map<String, dynamic> formData,
) async {
  final combinedData = {
    "customerDetails": {
      "name": formData['customer']['name'] ?? '',
      "email": formData['customer']['email'] ?? '',
      "mobile": formData['customer']['mobile'] ?? '',
      "alternateNumber": formData['customer']['alternateNumber'] ?? '',
      "address": {
        "street": formData['customer']['street'] ?? '',
        "city": formData['customer']['city'] ?? '',
        "state": formData['customer']['state'] ?? '',
        "country": formData['customer']['country'] ?? '',
        "zipCode": formData['customer']['zipCode'] ?? '',
      },
    },
    "productDetails": {
      "modelName": formData['product']['modelName'] ?? '',
      "serialNumber": formData['product']['serialNumber'] ?? '',
      "orignalWarranty":
          int.tryParse(
            formData['product']['orignalWarranty'].toString().split(' ')[0],
          ) ??
          0,

      "brand": formData['product']['brand'] ?? '',
      "category": formData['product']['category'] ?? '',
      "categoryId": formData['product']['categoryId'] ?? '',
      "purchasePrice":
          double.tryParse(formData['product']['purchasePrice'] ?? '') ?? 0,
    },
    "invoiceDetails": {
      "invoiceNumber": formData['invoice']['invoiceNumber'] ?? '',
      "invoiceAmount":
          double.tryParse(
            formData['invoice']['invoiceAmount']?.toString() ?? '',
          ) ??
          0,
      "invoiceImage":
          formData['invoice']['invoiceImage'] ?? '', // Now a URL string
      "invoiceDate": DateFormat(
        'yyyy-MM-dd',
      ).format(formData['invoice']['invoiceDate']),
    },
    "productImages": {
      "frontImage": formData['images']['frontImage'] ?? '', // Now a URL string
      "backImage": formData['images']['backImage'] ?? '', // Now a URL string
      "additionalImages":
          formData['images']['additionalImages'] ??
          [], // Now list of URL strings
    },
    "warrantyDetails": {
      "planId": formData['warranty']['planId'] ?? '',
      "planName": formData['warranty']['planName'] ?? '',
      "warrantyPeriod":
          int.tryParse(
            formData['warranty']['warrantyPeriod']?.toString() ?? '',
          ) ??
          0,
      "startDate": DateFormat(
        'yyyy-MM-dd',
      ).format(formData['warranty']['startDate']),
      "expiryDate": DateFormat(
        'yyyy-MM-dd',
      ).format(formData['warranty']['expiryDate']),
      "premiumAmount":
          double.tryParse(
            formData['warranty']['premiumAmount']?.toString() ?? '',
          ) ??
          0,
    },
  };

  print("FORMDATA: $combinedData");

 try {
  final response = await submitCustomerData(combinedData);

  if (context.mounted) {
    final isSuccess = response.statusCode == 200 || response.statusCode == 201;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess ? 'Customer created successfully' : 'Failed creating customer',
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RetailerDashboard()),
      );
    });
  }
} catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed creating customer'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) =>  RetailerDashboard()),
      );
    });
  }
}

}
