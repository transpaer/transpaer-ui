import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:consumers_api/consumers_api.dart' as api;

const double defaultPadding = 10.0;
const double tileWidth = 180;
const double tileHeight = 240;

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
    final style = Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(color: Colors.black);
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
  final String? source;

  const Description({
    super.key,
    required this.text,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black,
        );
    final sourceStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            if (source != null) ...[
              const Space(),
              Text("Source: " + source!, style: sourceStyle),
            ]
          ],
        ),
      ),
    );
  }
}

class Article extends StatelessWidget {
  final String markdown;

  const Article({
    super.key,
    required this.markdown,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(defaultPadding))),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Markdown(data: markdown),
        ),
      ),
    );
  }
}

extension InfoTopicGuiExtension on api.InfoTopic {
  String get icon {
    return ["main", "bcorp", "tco"][index];
  }
}

class InfoWidget extends StatelessWidget {
  final api.Info info;

  const InfoWidget({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Title(text: info.title),
          const Space(),
          Article(markdown: info.article),
        ],
      ),
    );
  }
}

class InfoView extends StatefulWidget {
  final api.InfoTopic infoTopic;

  const InfoView({super.key, required this.infoTopic});

  @override
  State<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView>
    with AutomaticKeepAliveClientMixin {
  late Future<api.Info> _futureInfo;

  @override
  void initState() {
    super.initState();
    _futureInfo = api.fetchInfo(widget.infoTopic);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<api.Info>(
        future: _futureInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return InfoWidget(
              info: snapshot.data!,
            );
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

class InfoPage extends StatefulWidget {
  final api.InfoTopic infoTopic;

  const InfoPage({super.key, required this.infoTopic});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  static const double tabIconSize = 32;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: api.InfoTopic.values.length, vsync: this);
    _tabController.animateTo(api.InfoTopic.main.index);
  }

  @override
  void didUpdateWidget(InfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.animateTo(widget.infoTopic.index);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.green[800],
          indicatorColor: Colors.green[800],
          indicatorWeight: 7,
          tabs: <Widget>[
            for (final value in api.InfoTopic.values)
              Tab(
                icon: Image(
                  image: AssetImage('images/${value.icon}.png'),
                  height: tabIconSize,
                  width: tabIconSize,
                ),
              ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              for (final value in api.InfoTopic.values)
                InfoView(infoTopic: value),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductInfoWidget extends StatelessWidget {
  final api.ProductFull product;
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

class ProductTileWidget extends StatelessWidget {
  final api.ProductShort product;
  final Function(String) onSelected;
  final Function(api.BadgeName) onBadgeTap;

  const ProductTileWidget({
    required this.product,
    required this.onSelected,
    required this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black,
        );

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            onSelected(product.productId);
          },
          child: Container(
            width: tileWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.all(Radius.circular(defaultPadding)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: titleStyle),
                  const Space(),
                  Text(product.description, style: textStyle),
                  const Space(),
                  BadgeRow(
                    badges: product.badges,
                    onTap: onBadgeTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Badge extends StatelessWidget {
  static const double badgeSize = 32;

  final api.BadgeName badge;
  final Function(api.BadgeName) onTap;

  const Badge({required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap(badge);
        },
        child: Image(
          image: AssetImage('images/${badge.name}.png'),
          height: badgeSize,
          width: badgeSize,
        ),
      ),
    );
  }
}

class BadgeFlex extends StatelessWidget {
  static const double badgeSize = 32;

  final List<api.BadgeName>? badges;
  final Axis axis;
  final Function(api.BadgeName) onTap;

  const BadgeFlex(
      {required this.badges, required this.axis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: axis,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badges != null) ...[
          for (final badge in badges!) Badge(badge: badge, onTap: onTap)
        ],
      ],
    );
  }
}

class BadgeColumn extends BadgeFlex {
  const BadgeColumn({
    List<api.BadgeName>? badges,
    required Function(api.BadgeName) onTap,
  }) : super(badges: badges, axis: Axis.vertical, onTap: onTap);
}

class BadgeRow extends BadgeFlex {
  const BadgeRow({
    List<api.BadgeName>? badges,
    required Function(api.BadgeName) onTap,
  }) : super(badges: badges, axis: Axis.horizontal, onTap: onTap);
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

class ManufacturerView extends StatelessWidget {
  final api.Manufacturer manufacturer;
  final String source;
  final Function(api.BadgeName) onBadgeTap;

  const ManufacturerView({
    super.key,
    required this.manufacturer,
    required this.source,
    required this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black,
        );
    final sourceStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey,
        );

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(defaultPadding))),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(manufacturer.name, style: titleStyle),
                  const Space(),
                  Text(manufacturer.description, style: textStyle),
                  const Space(),
                  Text("Source: " + source, style: sourceStyle),
                ],
              ),
            ),
            BadgeColumn(
              badges: manufacturer.badges,
              onTap: onBadgeTap,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  final api.ProductFull product;
  final Function(String) onAlternativeTap;
  final Function(api.BadgeName) onBadgeTap;

  const ProductView({
    super.key,
    required this.product,
    required this.onAlternativeTap,
    required this.onBadgeTap,
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
                if (product.manufacturers != null) ...[
                  for (final manufacturer in product.manufacturers!)
                    ManufacturerView(
                      manufacturer: manufacturer,
                      source: "wikidata",
                      onBadgeTap: onBadgeTap,
                    )
                ],
                Section(text: 'Alternatives'),
                SizedBox(
                  height: tileHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (product.manufacturers != null) ...[
                        for (final alternative in product.alternatives!)
                          ProductTileWidget(
                            product: alternative,
                            onSelected: onAlternativeTap,
                            onBadgeTap: onBadgeTap,
                          ),
                      ],
                    ],
                  ),
                ),
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
  final Function(String) onAlternativeTap;
  final Function(api.BadgeName) onBadgeTap;

  const ProductPage({
    super.key,
    required this.productId,
    required this.onAlternativeTap,
    required this.onBadgeTap,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin {
  late Future<api.ProductFull> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = api.fetchProduct(widget.productId);
  }

  @override
  void didUpdateWidget(ProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _futureProduct = api.fetchProduct(widget.productId);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<api.ProductFull>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ProductView(
              product: snapshot.data!,
              onAlternativeTap: widget.onAlternativeTap,
              onBadgeTap: widget.onBadgeTap,
            );
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
  List<api.ProductFull> _entries = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
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
    final result = await api.searchProducts(text);
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
  String? _productId;
  api.InfoTopic _infoTopic = api.InfoTopic.main;

  final int _infoTab = 0;
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
            InfoPage(infoTopic: _infoTopic),
            if (_productId != null) ...[
              ProductPage(
                productId: _productId!,
                onAlternativeTap: (productId) {
                  setState(() {
                    _productId = productId;
                  });
                },
                onBadgeTap: (badgeName) {
                  setState(() {
                    _infoTopic = badgeName.toInfoTopic();
                  });
                  _tabController.animateTo(_infoTab);
                },
              )
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
