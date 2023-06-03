import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:sustainity_api/sustainity_api.dart' as api;

import 'package:sustainity_frontend/configuration.dart';

const double defaultPadding = 10.0;
const double tileWidth = 180;
const double tileHeight = 240;

void main() async {
  final config = Config.load();
  final fetcher = api.Fetcher(
    scheme: config.backend_scheme,
    host: config.backend_host,
    port: config.backend_port,
  );
  runApp(SustainityFrontend(fetcher: fetcher));
}

enum PreviewVariant { organisation, product }

class ScoreData {
  final api.ScorerName scorer;
  final int score;

  ScoreData({required this.scorer, required this.score});

  Color get color {
    var value = 0.0;
    switch (this.scorer) {
      case api.ScorerName.fti:
        value = score / 100.0;
    }
    return Color.fromRGBO(
        ((255 - 100 * value)).toInt(), (155 + 100 * value).toInt(), 155, 0x01);
  }
}

class PreviewData {
  final PreviewVariant variant;
  final String itemId;

  PreviewData({required this.variant, required this.itemId});
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
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultPadding))),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: textStyle),
            if (source != null) ...[
              const Space(),
              Text("Source: ${source!}", style: sourceStyle),
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
            borderRadius:
                const BorderRadius.all(Radius.circular(defaultPadding))),
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
    return ["main", "bcorp", "tco", "fti"][index];
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
  final api.Fetcher fetcher;

  const InfoView({super.key, required this.infoTopic, required this.fetcher});

  @override
  State<InfoView> createState() => _InfoViewState(fetcher: fetcher);
}

class _InfoViewState extends State<InfoView>
    with AutomaticKeepAliveClientMixin {
  final api.Fetcher fetcher;

  late Future<api.Info> _futureInfo;

  _InfoViewState({required this.fetcher});

  @override
  void initState() {
    super.initState();
    _futureInfo = fetcher.fetchInfo(widget.infoTopic);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.Info>(
        future: _futureInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return InfoWidget(
              info: snapshot.data!,
            );
          } else if (snapshot.hasError) {
            return Text('Error while fetching data: ${snapshot.error}');
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
  final api.Fetcher fetcher;

  const InfoPage({super.key, required this.infoTopic, required this.fetcher});

  @override
  State<InfoPage> createState() => _InfoPageState(fetcher: fetcher);
}

class _InfoPageState extends State<InfoPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  static const double tabIconSize = 32;

  final api.Fetcher fetcher;

  late TabController _tabController;

  _InfoPageState({required this.fetcher});

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
    super.build(context);
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
                InfoView(infoTopic: value, fetcher: fetcher),
            ],
          ),
        ),
      ],
    );
  }
}

class OrganisationInfoWidget extends StatelessWidget {
  final api.Organisation organisation;
  final Function(String) onSelected;

  const OrganisationInfoWidget({
    super.key,
    required this.organisation,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        onTap: () => onSelected(organisation.organisationId),
        title: Text(organisation.name),
      ),
    );
  }
}

class ProductInfoWidget extends StatelessWidget {
  final api.ProductFull product;
  final Function(String) onSelected;

  const ProductInfoWidget({
    super.key,
    required this.product,
    required this.onSelected,
  });

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
  final Function(api.ScorerName) onScorerTap;

  const ProductTileWidget({
    super.key,
    required this.product,
    required this.onSelected,
    required this.onBadgeTap,
    required this.onScorerTap,
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
              borderRadius:
                  const BorderRadius.all(Radius.circular(defaultPadding)),
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
                  RibbonRow(
                    badges: product.badges,
                    scores: product.scores,
                    onBadgeTap: onBadgeTap,
                    onScorerTap: onScorerTap,
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

  const Badge({super.key, required this.badge, required this.onTap});

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

class Score extends StatelessWidget {
  static const double badgeSize = 32;

  final ScoreData score;
  final Function(api.ScorerName) onTap;

  const Score({
    super.key,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap(score.scorer);
        },
        child: Container(
          decoration: BoxDecoration(
              color: score.color,
              borderRadius:
                  const BorderRadius.all(Radius.circular(defaultPadding))),
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                Image(
                  image: AssetImage('images/${score.scorer.name}.png'),
                  height: badgeSize,
                  width: badgeSize,
                ),
                const Space(),
                Text("${score.score}%"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RibbonFlex extends StatelessWidget {
  static const double badgeSize = 32;

  final List<api.BadgeName>? badges;
  final Map<api.ScorerName, int>? scores;
  final Axis axis;
  final Function(api.BadgeName) onBadgeTap;
  final Function(api.ScorerName) onScorerTap;

  const RibbonFlex({
    super.key,
    required this.badges,
    required this.scores,
    required this.axis,
    required this.onBadgeTap,
    required this.onScorerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: axis,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badges != null) ...[
          for (final badge in badges!) Badge(badge: badge, onTap: onBadgeTap)
        ],
        if (scores != null) ...[
          for (final entry in scores!.entries)
            Score(
                score: ScoreData(scorer: entry.key, score: entry.value),
                onTap: onScorerTap)
        ],
      ],
    );
  }
}

class RibbonColumn extends RibbonFlex {
  const RibbonColumn({
    super.key,
    List<api.BadgeName>? badges,
    Map<api.ScorerName, int>? scores,
    required Function(api.BadgeName) onBadgeTap,
    required Function(api.ScorerName) onScorerTap,
  }) : super(
          badges: badges,
          scores: scores,
          axis: Axis.vertical,
          onBadgeTap: onBadgeTap,
          onScorerTap: onScorerTap,
        );
}

class RibbonRow extends RibbonFlex {
  const RibbonRow({
    super.key,
    List<api.BadgeName>? badges,
    Map<api.ScorerName, int>? scores,
    required Function(api.BadgeName) onBadgeTap,
    required Function(api.ScorerName) onScorerTap,
  }) : super(
            badges: badges,
            scores: scores,
            axis: Axis.horizontal,
            onBadgeTap: onBadgeTap,
            onScorerTap: onScorerTap);
}

class OrganisationWidget extends StatelessWidget {
  final api.Organisation organisation;
  final String source;
  final Function(api.BadgeName) onBadgeTap;
  final Function(api.ScorerName) onScorerTap;

  const OrganisationWidget({
    super.key,
    required this.organisation,
    required this.source,
    required this.onBadgeTap,
    required this.onScorerTap,
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
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultPadding))),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(organisation.name, style: titleStyle),
                  const Space(),
                  Text(organisation.description, style: textStyle),
                  const Space(),
                  Text("Source: $source", style: sourceStyle),
                ],
              ),
            ),
            RibbonColumn(
              badges: organisation.badges,
              scores: organisation.scores,
              onBadgeTap: onBadgeTap,
              onScorerTap: onScorerTap,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  final Function() onOrganisationTextSearch;
  final Function() onProductTextSearch;
  final Function() onMapSearch;
  final Function() onQrcScan;

  const HomeView({
    super.key,
    required this.onOrganisationTextSearch,
    required this.onProductTextSearch,
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
              icon: const Icon(Icons.manage_search_outlined),
              label: const Text('Producer/shop search'),
              onPressed: () => onOrganisationTextSearch(),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              icon: const Icon(Icons.manage_search_outlined),
              label: const Text('Product search'),
              onPressed: () => onProductTextSearch(),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: const Text('Map search'),
              onPressed: onMapSearch,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              label: const Text('QRC scan'),
              onPressed: onQrcScan,
            ),
          ),
        ],
      ),
    );
  }
}

class OrganisationView extends StatelessWidget {
  final api.Organisation organisation;
  final String source;
  final Function(api.BadgeName) onBadgeTap;
  final Function(api.ScorerName) onScorerTap;

  const OrganisationView({
    super.key,
    required this.organisation,
    required this.source,
    required this.onBadgeTap,
    required this.onScorerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Title(text: organisation.name),
          const Space(),
          Expanded(
            child: ListView(
              children: [
                const Section(text: 'Descriptions:'),
                Description(
                  text: organisation.description,
                  source: "wikidata",
                ),
                RibbonRow(
                  badges: organisation.badges,
                  scores: organisation.scores,
                  onBadgeTap: onBadgeTap,
                  onScorerTap: onScorerTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  final api.ProductFull product;
  final Function(String) onAlternativeTap;
  final Function(api.BadgeName) onBadgeTap;
  final Function(api.ScorerName) onScorerTap;

  const ProductView({
    super.key,
    required this.product,
    required this.onAlternativeTap,
    required this.onBadgeTap,
    required this.onScorerTap,
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
                const Section(text: 'Descriptions:'),
                Description(
                  text: product.description,
                  source: "wikidata",
                ),
                const Section(text: 'Producers:'),
                if (product.manufacturers != null) ...[
                  for (final manufacturer in product.manufacturers!)
                    OrganisationWidget(
                      organisation: manufacturer,
                      source: "wikidata",
                      onBadgeTap: onBadgeTap,
                      onScorerTap: onScorerTap,
                    )
                ],
                const Section(text: 'Alternatives'),
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
                            onScorerTap: onScorerTap,
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

class PreviewPage extends StatelessWidget {
  final PreviewData preview;
  final Function(String) onProductTap;
  final Function(api.BadgeName) onBadgeTap;
  final Function(api.ScorerName) onScorerTap;
  final api.Fetcher fetcher;

  const PreviewPage({
    super.key,
    required this.preview,
    required this.onProductTap,
    required this.onBadgeTap,
    required this.onScorerTap,
    required this.fetcher,
  });

  @override
  Widget build(BuildContext context) {
    switch (preview.variant) {
      case PreviewVariant.organisation:
        return OrganisationPage(
          organisationId: preview.itemId,
          onBadgeTap: onBadgeTap,
          onScorerTap: onScorerTap,
          fetcher: fetcher,
        );
      case PreviewVariant.product:
        return ProductPage(
          productId: preview.itemId,
          onAlternativeTap: onProductTap,
          onBadgeTap: onBadgeTap,
          onScorerTap: onScorerTap,
          fetcher: fetcher,
        );
    }
  }
}

class OrganisationPage extends StatefulWidget {
  final String organisationId;
  final Function(api.BadgeName) onBadgeTap;
  final Function(api.ScorerName) onScorerTap;
  final api.Fetcher fetcher;

  const OrganisationPage({
    super.key,
    required this.organisationId,
    required this.onBadgeTap,
    required this.onScorerTap,
    required this.fetcher,
  });

  @override
  State<OrganisationPage> createState() =>
      _OrganisationPageState(fetcher: fetcher);
}

class _OrganisationPageState extends State<OrganisationPage>
    with AutomaticKeepAliveClientMixin {
  final api.Fetcher fetcher;
  late Future<api.Organisation> _futureOrganisation;

  _OrganisationPageState({required this.fetcher});

  @override
  void initState() {
    super.initState();
    _futureOrganisation = fetcher.fetchOrganisation(widget.organisationId);
  }

  @override
  void didUpdateWidget(OrganisationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _futureOrganisation = fetcher.fetchOrganisation(widget.organisationId);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.Organisation>(
        future: _futureOrganisation,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return OrganisationView(
              organisation: snapshot.data!,
              onBadgeTap: widget.onBadgeTap,
              onScorerTap: widget.onScorerTap,
              source: "wikidata",
            );
          } else if (snapshot.hasError) {
            return Text('Error while fetching data: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class ProductPage extends StatefulWidget {
  final String productId;
  final Function(String) onAlternativeTap;
  final Function(api.BadgeName) onBadgeTap;
  final Function(api.ScorerName) onScorerTap;
  final api.Fetcher fetcher;

  const ProductPage({
    super.key,
    required this.productId,
    required this.onAlternativeTap,
    required this.onBadgeTap,
    required this.onScorerTap,
    required this.fetcher,
  });

  @override
  State<ProductPage> createState() => _ProductPageState(fetcher: fetcher);
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin {
  final api.Fetcher fetcher;
  late Future<api.ProductFull> _futureProduct;

  _ProductPageState({required this.fetcher});

  @override
  void initState() {
    super.initState();
    _futureProduct = fetcher.fetchProduct(widget.productId);
  }

  @override
  void didUpdateWidget(ProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _futureProduct = fetcher.fetchProduct(widget.productId);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.ProductFull>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ProductView(
              product: snapshot.data!,
              onAlternativeTap: widget.onAlternativeTap,
              onBadgeTap: widget.onBadgeTap,
              onScorerTap: widget.onScorerTap,
            );
          } else if (snapshot.hasError) {
            return Text('Error while fetching data: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class OrganisationTextSearchPage extends StatefulWidget {
  final Function(String) onSelected;
  final api.Fetcher fetcher;

  const OrganisationTextSearchPage({
    super.key,
    required this.onSelected,
    required this.fetcher,
  });

  @override
  State<OrganisationTextSearchPage> createState() =>
      _OrganisationTextSearchPageState(fetcher: fetcher);
}

class _OrganisationTextSearchPageState extends State<OrganisationTextSearchPage>
    with AutomaticKeepAliveClientMixin {
  final _searchFieldController = TextEditingController();
  final api.Fetcher fetcher;

  bool _searching = false;
  List<api.Organisation> _entries = [];

  _OrganisationTextSearchPageState({required this.fetcher});

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Text search',
                  ),
                  controller: _searchFieldController,
                  onSubmitted: _onSubmitted,
                ),
              ),
              const Space(),
              FilledButton(
                onPressed: _searching
                    ? null
                    : () => _onSubmitted(_searchFieldController.text),
                child: const Text('Search'),
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
                      return OrganisationInfoWidget(
                          organisation: _entries[index],
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
    final result = await fetcher.searchOrganisations(text);
    setState(() {
      _searching = false;
      _entries = result.organisations;
    });
  }
}

class ProductTextSearchPage extends StatefulWidget {
  final Function(String) onSelected;
  final api.Fetcher fetcher;

  const ProductTextSearchPage({
    super.key,
    required this.onSelected,
    required this.fetcher,
  });

  @override
  State<ProductTextSearchPage> createState() =>
      _ProductTextSearchPageState(fetcher: fetcher);
}

class _ProductTextSearchPageState extends State<ProductTextSearchPage>
    with AutomaticKeepAliveClientMixin {
  final _searchFieldController = TextEditingController();
  final api.Fetcher fetcher;

  bool _searching = false;
  List<api.ProductFull> _entries = [];

  _ProductTextSearchPageState({required this.fetcher});

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Text search',
                  ),
                  controller: _searchFieldController,
                  onSubmitted: _onSubmitted,
                ),
              ),
              const Space(),
              FilledButton(
                onPressed: _searching
                    ? null
                    : () => _onSubmitted(_searchFieldController.text),
                child: const Text('Search'),
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
    final result = await fetcher.searchProducts(text);
    setState(() {
      _searching = false;
      _entries = result.products;
    });
  }
}

class SustainityFrontend extends StatefulWidget {
  final api.Fetcher fetcher;

  const SustainityFrontend({super.key, required this.fetcher});

  @override
  State<SustainityFrontend> createState() =>
      _SustainityFrontendState(fetcher: fetcher);
}

class _SustainityFrontendState extends State<SustainityFrontend>
    with TickerProviderStateMixin {
  static const int _infoTab = 0;
  static const int _previewTab = 1;
  static const int _organisationTextSearchTab = 2;
  static const int _productTextSearchTab = 3;
  static const int _mapSearchTab = 4;
  static const int _qrcScanTab = 5;

  final api.Fetcher fetcher;

  late TabController _tabController;

  PreviewData? _preview;
  api.InfoTopic _infoTopic = api.InfoTopic.main;

  _SustainityFrontendState({required this.fetcher});

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sustainify',
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
          title: const Text('Sustainify'),
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
            InfoPage(infoTopic: _infoTopic, fetcher: fetcher),
            if (_preview != null) ...[
              PreviewPage(
                preview: _preview!,
                onProductTap: (productId) {
                  setState(() {
                    _preview = PreviewData(
                        itemId: productId, variant: PreviewVariant.product);
                  });
                },
                onBadgeTap: (badgeName) {
                  setState(() {
                    _infoTopic = badgeName.toInfoTopic();
                  });
                  _tabController.animateTo(_infoTab);
                },
                onScorerTap: (scorerName) {
                  setState(() {
                    _infoTopic = scorerName.toInfoTopic();
                  });
                  _tabController.animateTo(_infoTab);
                },
                fetcher: fetcher,
              )
            ] else ...[
              HomeView(
                onOrganisationTextSearch: () =>
                    _tabController.animateTo(_organisationTextSearchTab),
                onProductTextSearch: () =>
                    _tabController.animateTo(_productTextSearchTab),
                onMapSearch: () => _tabController.animateTo(_mapSearchTab),
                onQrcScan: () => _tabController.animateTo(_qrcScanTab),
              )
            ],
            OrganisationTextSearchPage(
              onSelected: (organisationId) {
                setState(() {
                  _preview = PreviewData(
                    variant: PreviewVariant.organisation,
                    itemId: organisationId,
                  );
                });
                _tabController.animateTo(_previewTab);
              },
              fetcher: fetcher,
            ),
            ProductTextSearchPage(
              onSelected: (productId) {
                setState(() {
                  _preview = PreviewData(
                    variant: PreviewVariant.product,
                    itemId: productId,
                  );
                });
                _tabController.animateTo(_previewTab);
              },
              fetcher: fetcher,
            ),
            const Center(
              child: Text('Map search'),
            ),
            const Center(
              child: Text('QRC search'),
            ),
          ],
        ),
      ),
    );
  }
}
