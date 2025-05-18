import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          products = (data as List).map((item) => Product(
            image: item['image'] ?? 'https://via.placeholder.com/150',
            title: item['title'] ?? 'No Title',
            price: (item['price']?.toDouble() ?? 0.0),
            rating: (item['rating']?['rate']?.toDouble() ?? 0.0),
          )).toList();
          isLoading = false;
          notifyListeners();
          return;
        } else {
          errorMessage = 'Failed to load products: ${response.statusCode}';
          isLoading = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        if (attempt == 3) {
          errorMessage = 'Error fetching products: $e. Please check your internet connection.';
          isLoading = false;
          notifyListeners();
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }
}