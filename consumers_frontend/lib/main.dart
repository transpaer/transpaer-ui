import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:consumers_api/consumers_api.dart' as api;

const double defaultPadding = 10.0;

Future<api.Product> fetchProduct(String id) async {
  final uri = Uri(
      scheme: 'http', host: 'localhost', port: 8080, path: '/products/' + id);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return api.Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load product: ${response.statusCode}');
  }
}

Future<api.TextSearchResponse> searchProducts(String query) async {
  final uri = Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8080,
      path: '/search',
      queryParameters: {'query': query, 'limit': '10'});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return api.TextSearchResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load products: ${response.statusCode}');
  }
}

void main() {
  runApp(const ConsumersFrontend());
}

class Space extends StatelessWidget {
  const Space({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 10,
      height: 10,
    );
  }
}

class Title extends StatelessWidget {
  final String text;

  const Title({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        Theme.of(context).textTheme.headlineMedium?.apply(color: Colors.black);
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Text(text, style: style),
    );
  }
}

class Section extends StatelessWidget {
  final String text;

  const Section({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall;
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Text(text, style: style),
    );
  }
}

class Description extends StatelessWidget {
  final String text;
  final String source;

  const Description({
    super.key,
    required this.text,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.apply(
          color: Colors.black,
        );
    final sourceStyle = Theme.of(context).textTheme.bodyMedium?.apply(
          color: Colors.grey,
        );

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(defaultPadding))),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: textStyle),
            const Space(),
            Text("Source: " + source, style: sourceStyle),
          ],
        ),
      ),
    );
  }
}

class ProductInfoWidget extends StatelessWidget {
  final api.Product product;
  final Function(String) onSelected;

  const ProductInfoWidget({required this.product, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        onTap: () => onSelected(product.productId),
        title: Text(product.name),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  final Function() onTextSearch;
  final Function() onMapSearch;
  final Function() onQrcScan;

  const HomeView({
    required this.onTextSearch,
    required this.onMapSearch,
    required this.onQrcScan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(100.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              icon: Icon(Icons.manage_search_outlined),
              label: const Text('Text search'),
              onPressed: () => onTextSearch(),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              icon: Icon(Icons.map_outlined),
              label: const Text('Map search'),
              onPressed: onMapSearch,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              icon: Icon(Icons.qr_code_scanner_outlined),
              label: const Text('QRC scan'),
              onPressed: onQrcScan,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  final api.Product product;

  const ProductView({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Title(text: product.name),
          const Space(),
          Expanded(
            child: ListView(
              children: [
                Section(text: 'Descriptions:'),
                Description(
                  text: product.description,
                  source: "wikidata",
                ),
                Section(text: 'Producers:'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductPage extends StatefulWidget {
  final String productId;

  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin {
  late Future<api.Product> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = fetchProduct(widget.productId);
  }

  @override
  void didUpdateWidget(ProductPage page) {
    super.didUpdateWidget(page);
    _futureProduct = fetchProduct(widget.productId);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<api.Product>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ProductView(product: snapshot.data!);
          } else if (snapshot.hasError) {
            return Text('Error while fetching data:: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class TextSearchPage extends StatefulWidget {
  final Function(String) onSelected;

  const TextSearchPage({super.key, required this.onSelected});

  @override
  State<TextSearchPage> createState() => _TextSearchPageState();
}

class _TextSearchPageState extends State<TextSearchPage>
    with AutomaticKeepAliveClientMixin {
  final _searchFieldController = TextEditingController();

  bool _searching = false;
  List<api.Product> _entries = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(100.0),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Text search',
                  ),
                  controller: _searchFieldController,
                  onSubmitted: _onSubmitted,
                ),
              ),
              const Space(),
              FilledButton(
                child: const Text('Search'),
                onPressed: _searching
                    ? null
                    : () => _onSubmitted(_searchFieldController.text),
              ),
            ],
          ),
          const Space(),
          _searching
              ? const CircularProgressIndicator()
              : Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: _entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductInfoWidget(
                          product: _entries[index],
                          onSelected: widget.onSelected);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _onSubmitted(String text) async {
    setState(() {
      _searching = true;
      _entries = [];
    });
    final result = await searchProducts(text);
    setState(() {
      _searching = false;
      _entries = result.products;
    });
  }
}

class ConsumersFrontend extends StatefulWidget {
  const ConsumersFrontend({super.key});

  @override
  State<ConsumersFrontend> createState() => _ConsumersFrontendState();
}

class _ConsumersFrontendState extends State<ConsumersFrontend>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _productId = null;

  final int _productTab = 1;
  final int _textSearchTab = 2;
  final int _mapSearchTab = 3;
  final int _qrcScanTab = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consumers',
      theme: ThemeData(
        cardColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.green[800],
          onPrimary: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Consumers'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.lightGreen[100],
            indicatorWeight: 7,
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.info_outlined),
              ),
              Tab(
                icon: Icon(Icons.shopping_basket_outlined),
              ),
              Tab(
                icon: Icon(Icons.manage_search_outlined),
              ),
              Tab(
                icon: Icon(Icons.map_outlined),
              ),
              Tab(
                icon: Icon(Icons.qr_code_scanner_outlined),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Center(
              child: Text('Info'),
            ),
            if (_productId != null) ...[
              ProductPage(productId: _productId!)
            ] else ...[
              HomeView(
                onTextSearch: () => _tabController.animateTo(_textSearchTab),
                onMapSearch: () => _tabController.animateTo(_mapSearchTab),
                onQrcScan: () => _tabController.animateTo(_qrcScanTab),
              )
            ],
            TextSearchPage(onSelected: (productId) {
              setState(() {
                _productId = productId;
              });
              _tabController.animateTo(_productTab);
            }),
            Center(
              child: Text('Map search'),
            ),
            Center(
              child: Text('QRC search'),
            ),
          ],
        ),
      ),
    );
  }
}
