import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
        if (response.statusCode == 200) {
          setState(() {
            products = json.decode(response.body);
            isLoading = false;
          });
          return;
        } else {
          setState(() {
            errorMessage = 'Failed to load products: ${response.statusCode}';
            isLoading = false;
          });
          return;
        }
      } catch (e) {
        if (attempt == 3) {
          setState(() {
            errorMessage = 'Error fetching products: $e. Please check your internet connection.';
            isLoading = false;
          });
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, textAlign: TextAlign.center))
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.55,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  child: Image.network(
                    product['thumbnailUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Image load error for URL: ${product['thumbnailUrl']} - Error: $error');
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
                Icon(Icons.favorite_border, color: Colors.grey),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    product['title']?.toString() ?? 'No Title',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EGP ${index * 500 + 1000}  ',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${(index * 500 + 2000)}EGP',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Review (${(index % 5 + 1).toStringAsFixed(1)} ★)',
                  style: TextStyle(fontSize: 14),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      onPressed: () {},
                      child: Icon(Icons.add),
                      mini: true,
                      backgroundColor: Colors.purple[100],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}