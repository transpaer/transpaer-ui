import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:sustainity_api/sustainity_api.dart' as api;

import 'package:sustainity_frontend/configuration.dart';

const double defaultPadding = 10.0;
const double tileWidth = 180;
const double tileHeight = 240;
const double imageSize = 220;

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
    switch (scorer) {
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
          child: Markdown(
            data: markdown,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              blockquoteDecoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  left: BorderSide(
                    width: 3,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension LibraryTopicGuiExtension on api.LibraryTopic {
  String get icon {
    return [
      "main",
      "main",
      "bcorp",
      "eu_ecolabel",
      "tco",
      "fti",
    ][index];
  }
}

class InfoWidget extends StatelessWidget {
  final api.LibraryInfo info;

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

class SourcedImage extends StatelessWidget {
  static const url1 = "https://commons.wikimedia.org/wiki/Special:FilePath";

  final api.Image image;

  const SourcedImage(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    String link;
    String url;
    String source;
    switch (image.source) {
      case api.Source.wikidata:
        link = "$url1/${image.image}";
        url = "$link?width=200";
        source = "wikidata";
        break;
    }

    return Column(
      children: [
        Image.network(
          url,
          width: imageSize,
          height: imageSize,
        ),
        Tooltip(
          message: link,
          child: Text("Source: $source"),
        ),
      ],
    );
  }
}

class LibraryView extends StatefulWidget {
  final api.LibraryTopic topic;
  final api.Fetcher fetcher;

  const LibraryView({super.key, required this.topic, required this.fetcher});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with AutomaticKeepAliveClientMixin {
  late Future<api.LibraryInfo> _futureInfo;

  @override
  void initState() {
    super.initState();
    _futureInfo = widget.fetcher.fetchLibraryInfo(widget.topic);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.LibraryInfo>(
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

class LibraryPage extends StatefulWidget {
  final api.LibraryTopic topic;
  final api.Fetcher fetcher;

  const LibraryPage({super.key, required this.topic, required this.fetcher});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  static const double tabIconSize = 32;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: api.LibraryTopic.values.length, vsync: this);
    _tabController.animateTo(api.LibraryTopic.main.index);
  }

  @override
  void didUpdateWidget(LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.animateTo(widget.topic.index);
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
            for (final value in api.LibraryTopic.values)
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
              for (final value in api.LibraryTopic.values)
                LibraryView(topic: value, fetcher: widget.fetcher),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchEntryWidget extends StatelessWidget {
  final api.SearchResult entry;
  final Navigation navigation;

  const SearchEntryWidget({
    super.key,
    required this.entry,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon;
    Function() onTap;
    switch (entry.variant) {
      case api.SearchResultVariant.organisation:
        icon = const Tooltip(
          message: "manufacturer / organisation / business / shop",
          child: Icon(Icons.business_outlined),
        );
        onTap = () => navigation.goToOrganisation(entry.id);
        break;
      case api.SearchResultVariant.product:
        icon = const Tooltip(
          message: "product / brand / item category",
          child: Icon(Icons.shopping_basket_outlined),
        );
        onTap = () => navigation.goToProduct(entry.id);
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        onTap: onTap,
        leading: icon,
        title: Text(entry.label),
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
                  Text(
                    product.description != null ? product.description! : "",
                    style: textStyle,
                  ),
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
          image: AssetImage('images/${badge.toLibraryTopic().icon}.png'),
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
                  image: AssetImage(
                      'images/${score.scorer.toLibraryTopic().icon}.png'),
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

class OperationsMenu extends StatelessWidget {
  final PreviewVariant variant;
  final Navigation navigation;

  const OperationsMenu({
    super.key,
    required this.variant,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    var tipText = "";
    switch (variant) {
      case PreviewVariant.organisation:
        tipText = "Are you associated with this organisation? Read these tips!";
        break;
      case PreviewVariant.product:
        tipText =
            "Are you associated with producer of this item? Read these tips!";
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              navigation.goToLibrary(api.LibraryTopic.forProducers);
            },
            icon: const Icon(Icons.tips_and_updates_outlined),
            label: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(tipText),
            ),
          ),
          const Space(),
          ElevatedButton.icon(
            onPressed: () async {
              final url = Uri.parse(
                  'https://github.com/sustainity-dev/issues/issues/new');
              await url_launcher.launchUrl(url);
            },
            icon: const Icon(Icons.bug_report_outlined),
            label: const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Text("Found problem with data? Report it to us!"),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryAlternativesWidget extends StatelessWidget {
  final api.CategoryAlternatives ca;
  final Navigation navigation;

  const CategoryAlternativesWidget({
    super.key,
    required this.ca,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Section(text: 'Alternatives (category: "${ca.category}")'),
        ca.alternatives.isNotEmpty
            ? SizedBox(
                height: tileHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final alternative in ca.alternatives)
                      ProductTileWidget(
                        product: alternative,
                        onSelected: navigation.goToProduct,
                        onBadgeTap: navigation.onBadgeTap,
                        onScorerTap: navigation.onScorerTap,
                      ),
                  ],
                ),
              )
            : const Center(
                child: Text(
                    "No alternatives?... That might be some problem in our data...")),
      ],
    );
  }
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
                  Text(
                      organisation.description != null
                          ? organisation.description!
                          : "",
                      style: textStyle),
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

class OrganisationView extends StatelessWidget {
  final api.Organisation organisation;
  final String source;
  final Navigation navigation;

  const OrganisationView({
    super.key,
    required this.organisation,
    required this.source,
    required this.navigation,
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
                organisation.description != null
                    ? Description(
                        text: organisation.description!,
                        source: "wikidata",
                      )
                    : const Center(child: Text("No description...")),
                const Section(text: 'Certifications'),
                RibbonRow(
                  badges: organisation.badges,
                  scores: organisation.scores,
                  onBadgeTap: navigation.onBadgeTap,
                  onScorerTap: navigation.onScorerTap,
                ),
                const Section(text: 'Images'),
                organisation.images.isNotEmpty
                    ? SizedBox(
                        height: tileHeight,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final image in organisation.images)
                              SourcedImage(image)
                          ],
                        ),
                      )
                    : const Center(child: Text("No images...")),
                OperationsMenu(
                  variant: PreviewVariant.organisation,
                  navigation: navigation,
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
  final Navigation navigation;

  const ProductView({
    super.key,
    required this.product,
    required this.navigation,
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
                product.description != null
                    ? Description(
                        text: product.description!,
                        source: "wikidata",
                      )
                    : const Center(child: Text("No description...")),
                const Section(text: 'GTINs'),
                product.gtins.isNotEmpty
                    ? Description(text: product.gtins.join(", "))
                    : const Center(child: Text("No GTINs...")),
                const Section(text: 'Producers:'),
                if (product.manufacturers != null) ...[
                  for (final manufacturer in product.manufacturers!)
                    OrganisationWidget(
                      organisation: manufacturer,
                      source: "wikidata",
                      onBadgeTap: navigation.onBadgeTap,
                      onScorerTap: navigation.onScorerTap,
                    )
                ],
                const Section(text: 'Images'),
                product.images.isNotEmpty
                    ? SizedBox(
                        height: tileHeight,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final image in product.images)
                              SourcedImage(image)
                          ],
                        ),
                      )
                    : const Center(child: Text("No images...")),
                for (final a in product.alternatives)
                  CategoryAlternativesWidget(ca: a, navigation: navigation),
                OperationsMenu(
                  variant: PreviewVariant.product,
                  navigation: navigation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrganisationPage extends StatefulWidget {
  final String organisationId;
  final Navigation navigation;
  final api.Fetcher fetcher;

  const OrganisationPage({
    super.key,
    required this.organisationId,
    required this.navigation,
    required this.fetcher,
  });

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage>
    with AutomaticKeepAliveClientMixin {
  late Future<api.Organisation> _futureOrganisation;

  @override
  void initState() {
    super.initState();
    _futureOrganisation =
        widget.fetcher.fetchOrganisation(widget.organisationId);
  }

  @override
  void didUpdateWidget(OrganisationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _futureOrganisation =
        widget.fetcher.fetchOrganisation(widget.organisationId);
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
              source: "wikidata",
              navigation: widget.navigation,
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
  final Navigation navigation;
  final api.Fetcher fetcher;

  const ProductPage({
    super.key,
    required this.productId,
    required this.navigation,
    required this.fetcher,
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
    _futureProduct = widget.fetcher.fetchProduct(widget.productId);
  }

  @override
  void didUpdateWidget(ProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _futureProduct = widget.fetcher.fetchProduct(widget.productId);
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
              navigation: widget.navigation,
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

class TextSearchPage extends StatefulWidget {
  final api.Fetcher fetcher;
  final Navigation navigation;

  const TextSearchPage({
    super.key,
    required this.fetcher,
    required this.navigation,
  });

  @override
  State<TextSearchPage> createState() => _TextSearchPageState();
}

class _TextSearchPageState extends State<TextSearchPage>
    with AutomaticKeepAliveClientMixin {
  final _searchFieldController = TextEditingController();

  bool _searching = false;
  List<api.SearchResult> _entries = [];

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
                      return SearchEntryWidget(
                        entry: _entries[index],
                        navigation: widget.navigation,
                      );
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
    final result = await widget.fetcher.textSearch(text);
    setState(() {
      _searching = false;
      _entries = result.results;
    });
  }
}

class ProductArguments {
  final String id;

  ProductArguments({required this.id});
}

class ProductScreen extends StatelessWidget {
  final String? productId;
  final Navigation navigation;
  final api.Fetcher fetcher;

  const ProductScreen({
    super.key,
    required this.productId,
    required this.navigation,
    required this.fetcher,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product"),
      ),
      body: ProductPage(
        productId: productId!,
        navigation: navigation,
        fetcher: fetcher,
      ),
    );
  }
}

class OrganisationArguments {
  final String id;

  OrganisationArguments({required this.id});
}

class OrganisationScreen extends StatelessWidget {
  final String organisationId;
  final api.Fetcher fetcher;
  final Navigation navigation;

  const OrganisationScreen({
    super.key,
    required this.organisationId,
    required this.fetcher,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organisation"),
      ),
      body: OrganisationPage(
        organisationId: organisationId,
        navigation: navigation,
        fetcher: fetcher,
      ),
    );
  }
}

class LibraryArguments {
  final api.LibraryTopic topic;

  LibraryArguments({required this.topic});
}

class LibraryScreen extends StatelessWidget {
  final api.LibraryTopic topic;
  final api.Fetcher fetcher;
  final Navigation navigation;

  const LibraryScreen({
    super.key,
    required this.topic,
    required this.navigation,
    required this.fetcher,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
      ),
      body: LibraryView(
        topic: topic,
        fetcher: fetcher,
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  final api.Fetcher fetcher;
  final Navigation navigation;

  const RootScreen({
    super.key,
    required this.fetcher,
    required this.navigation,
  });

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  static const int _tabNum = 4;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabNum, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainity'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.lightGreen[100],
          indicatorWeight: 7,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.menu_book_outlined),
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
          LibraryPage(
            topic: api.LibraryTopic.main,
            fetcher: widget.fetcher,
          ),
          TextSearchPage(
            fetcher: widget.fetcher,
            navigation: widget.navigation,
          ),
          const Center(
            child: Text('Map search'),
          ),
          const Center(
            child: Text('QRC search'),
          ),
        ],
      ),
    );
  }
}

enum NavigationPath {
  root,
  product,
  organisation,
  library,
}

class Navigation {
  static const rootPath = "/";
  static const productPath = "/product:";
  static const organisationPath = "/organisation:";
  static const libraryPath = "/library:";

  final BuildContext context;

  Navigation(this.context);

  void goToProduct(String productId) {
    Navigator.pushNamed(
      context,
      "$productPath$productId",
      arguments: AppArguments(
        NavigationPath.product,
        ProductArguments(id: productId),
      ),
    );
  }

  void goToOrganisation(String organisationId) {
    Navigator.pushNamed(
      context,
      "$organisationPath$organisationId",
      arguments: AppArguments(
        NavigationPath.organisation,
        OrganisationArguments(id: organisationId),
      ),
    );
  }

  void goToLibrary(api.LibraryTopic topic) {
    Navigator.pushNamed(
      context,
      "$libraryPath${topic.name}",
      arguments: AppArguments(
        NavigationPath.library,
        LibraryArguments(topic: topic),
      ),
    );
  }

  void onBadgeTap(api.BadgeName badge) {
    goToLibrary(badge.toLibraryTopic());
  }

  void onScorerTap(api.ScorerName scorer) {
    goToLibrary(scorer.toLibraryTopic());
  }
}

class AppArguments {
  final NavigationPath path;
  final dynamic args;

  AppArguments(this.path, this.args);
}

class SustainityFrontend extends StatefulWidget {
  final api.Fetcher fetcher;

  const SustainityFrontend({super.key, required this.fetcher});

  @override
  State<SustainityFrontend> createState() => _SustainityFrontendState();
}

class _SustainityFrontendState extends State<SustainityFrontend>
    with TickerProviderStateMixin {
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
        initialRoute: "/",
        onGenerateRoute: (settings) {
          AppArguments appArgs;
          if (settings.arguments != null) {
            appArgs = settings.arguments as AppArguments;
          } else {
            appArgs = parseArgs(settings.name);
          }
          switch (appArgs.path) {
            case NavigationPath.root:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return RootScreen(
                    fetcher: widget.fetcher,
                    navigation: Navigation(context),
                  );
                },
              );
            case NavigationPath.product:
              final args = appArgs.args as ProductArguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return ProductScreen(
                    productId: args.id,
                    fetcher: widget.fetcher,
                    navigation: Navigation(context),
                  );
                },
              );
            case NavigationPath.organisation:
              final args = appArgs.args as OrganisationArguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return OrganisationScreen(
                    organisationId: args.id,
                    fetcher: widget.fetcher,
                    navigation: Navigation(context),
                  );
                },
              );
            case NavigationPath.library:
              final args = appArgs.args as LibraryArguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return LibraryScreen(
                    topic: args.topic,
                    fetcher: widget.fetcher,
                    navigation: Navigation(context),
                  );
                },
              );
          }
        });
  }

  AppArguments parseArgs(String? path) {
    if (path == null || path == Navigation.rootPath) {
      return AppArguments(NavigationPath.root, null);
    }

    if (path.startsWith(Navigation.productPath)) {
      final productId = path.substring(Navigation.productPath.length);
      return AppArguments(
        NavigationPath.product,
        ProductArguments(id: productId),
      );
    }

    if (path.startsWith(Navigation.organisationPath)) {
      final organisationId = path.substring(Navigation.organisationPath.length);
      return AppArguments(
        NavigationPath.organisation,
        OrganisationArguments(id: organisationId),
      );
    }

    if (path.startsWith(Navigation.libraryPath)) {
      final topic = path.substring(Navigation.libraryPath.length);
      return AppArguments(
        NavigationPath.library,
        LibraryArguments(topic: api.LibraryTopicExtension.fromString(topic)),
      );
    }

    return AppArguments(NavigationPath.root, null);
  }
}
