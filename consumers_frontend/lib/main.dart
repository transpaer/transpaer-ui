import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:consumers_api/consumers_api.dart' as api;

Future<api.Product> fetchProduct() async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/products/Q109851604'));

  if (response.statusCode == 200) {
    return api.Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album ${response.statusCode}');
  }
}

void main() {
  runApp(const ConsumersFrontend());
}

class ConsumersFrontend extends StatefulWidget {
  const ConsumersFrontend({super.key});

  @override
  State<ConsumersFrontend> createState() => _ConsumersFrontendState();
}

class _ConsumersFrontendState extends State<ConsumersFrontend> {
  late Future<api.Product> futureProduct;

  @override
  void initState() {
    super.initState();
    futureProduct = fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consumers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Consumers'),
        ),
        body: Center(
          child: FutureBuilder<api.Product>(
            future: futureProduct,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    "${snapshot.data!.product_id} ${snapshot.data!.name}");
              } else if (snapshot.hasError) {
                return Text('Error while fetching data:: ${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
