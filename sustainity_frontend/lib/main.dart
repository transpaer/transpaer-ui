import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:countries_utils/countries_utils.dart' as countries_utils;
import 'package:logging/logging.dart' as logging;
import 'package:firebase_analytics/firebase_analytics.dart' as analytics;
import 'package:firebase_core/firebase_core.dart' as firebase;
import 'package:flutter/foundation.dart' as foundation;

import 'package:sustainity_api/api.dart' as api;

import 'package:sustainity_frontend/configuration.dart';

import 'firebase_options.dart' as firebase_options;

const double defaultPadding = 10.0;
const double tileWidth = 180;
const double tileHeight = 240;
const double imageSize = 220;
const double medallionWidth = 240;
const double medallionHeight = 180;
const double iconSize = 32;

const String slugSeparator = ":";

final log = logging.Logger('main');

void main() async {
  logging.Logger.root.level = logging.Level.INFO;
  logging.Logger.root.onRecord.listen((record) {
    debugPrint(
        '[${record.time}][${record.level}][${record.loggerName}] ${record.message}');
  });

  log.info('Welcome to Sustainity');

  final config = Config.load();
  final fetcher = api.DefaultApi(
    api.ApiClient(
      basePath:
          "${config.backendScheme}://${config.backendHost}:${config.backendPort}",
    ),
  );
  await logAnalytics();
  runApp(SustainityFrontend(fetcher: fetcher));
}

Future<void> logAnalytics() async {
  if (!foundation.kIsWeb) {
    return;
  }

  try {
    await firebase.Firebase.initializeApp(
      options: firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
    log.info('Analytics: initialized');

    await analytics.FirebaseAnalytics.instance.logAppOpen();
    log.info('Analytics: logged app open');
  } catch (e) {
    log.severe('Analytics error: $e');
  }
}

extension LibraryTopicGuiExtension on api.LibraryTopic {
  Widget get image {
    switch (this) {
      case api.LibraryTopic.infoColonMain:
        return const Icon(Icons.question_answer_outlined);
      case api.LibraryTopic.infoColonForProducers:
        return const Icon(Icons.question_answer_outlined);
      case api.LibraryTopic.infoColonFaq:
        return const Icon(Icons.question_answer_outlined);

      case api.LibraryTopic.dataColonWiki:
        // TODO: Prepare an icon.
        return const Icon(Icons.question_answer_outlined);
      case api.LibraryTopic.dataColonOpenFoodFacts:
        // TODO: Prepare an icon.
        return const Icon(Icons.question_answer_outlined);

      case api.LibraryTopic.certColonBcorp:
        return const Image(
          image: AssetImage("images/bcorp.png"),
          height: iconSize,
          width: iconSize,
        );
      case api.LibraryTopic.certColonEuEcolabel:
        return const Image(
          image: AssetImage("images/eu_ecolabel.png"),
          height: iconSize,
          width: iconSize,
        );
      case api.LibraryTopic.certColonTco:
        return const Image(
          image: AssetImage("images/tco.png"),
          height: iconSize,
          width: iconSize,
        );
      case api.LibraryTopic.certColonFti:
        return const Image(
          image: AssetImage("images/fti.png"),
          height: iconSize,
          width: iconSize,
        );

      case api.LibraryTopic.otherColonNotFound:
        return const Icon(Icons.question_answer_outlined);
    }

    return const Icon(Icons.question_answer_outlined);
  }

  bool get isInfo {
    return value.startsWith("info:");
  }

  bool get isCert {
    return value.startsWith("cert:");
  }

  bool get isData {
    return value.startsWith("data:");
  }
}

sealed class TextSearchLink {
  static fromApi(api.TextSearchLinkHack link) {
    if (link.organisationIdVariant != null) {
      return OrganisationLink(
          id: link.id, variant: link.organisationIdVariant!);
    } else if (link.productIdVariant != null) {
      return ProductLink(id: link.id, variant: link.productIdVariant!);
    } else {
      return null;
    }
  }
}

class OrganisationLink implements TextSearchLink {
  final String id;
  final api.OrganisationIdVariant variant;

  OrganisationLink({required this.id, required this.variant});

  static OrganisationLink vat(String id) {
    return OrganisationLink(id: id, variant: api.OrganisationIdVariant.vat);
  }

  static OrganisationLink wiki(String id) {
    return OrganisationLink(id: id, variant: api.OrganisationIdVariant.wiki);
  }

  static OrganisationLink www(String id) {
    return OrganisationLink(id: id, variant: api.OrganisationIdVariant.www);
  }

  static OrganisationLink? fromIds(api.OrganisationIds ids) {
    if (ids.vat.isNotEmpty) {
      return OrganisationLink.vat(ids.vat[0]);
    }
    if (ids.wiki.isNotEmpty) {
      return OrganisationLink.wiki(ids.wiki[0]);
    }
    if (ids.domains.isNotEmpty) {
      return OrganisationLink.www(ids.domains[0]);
    }
    return null;
  }

  String toSlug() {
    return "${variant.toString()}:$id";
  }

  static OrganisationLink? fromSlug(String slug) {
    final parts = slug.split(slugSeparator);
    if (parts.length != 2) {
      return null;
    }

    final variant = api.OrganisationIdVariant.fromJson(parts[0]);
    final id = parts[1];

    if (variant == null) {
      return null;
    }

    return OrganisationLink(
      variant: variant,
      id: id,
    );
  }
}

class ProductLink implements TextSearchLink {
  final String id;
  final api.ProductIdVariant variant;

  ProductLink({required this.id, required this.variant});

  static ProductLink gtin(String id) {
    return ProductLink(id: id, variant: api.ProductIdVariant.gtin);
  }

  static ProductLink ean(String id) {
    return ProductLink(id: id, variant: api.ProductIdVariant.ean);
  }

  static ProductLink wiki(String id) {
    return ProductLink(id: id, variant: api.ProductIdVariant.wiki);
  }

  static ProductLink? fromIds(api.ProductIds ids) {
    if (ids.gtins.isNotEmpty) {
      return ProductLink.gtin(ids.gtins[0]);
    }
    if (ids.eans.isNotEmpty) {
      return ProductLink.ean(ids.eans[0]);
    }
    if (ids.wiki.isNotEmpty) {
      return ProductLink.wiki(ids.wiki[0]);
    }
    return null;
  }

  String toSlug() {
    return "${variant.toString()}:$id";
  }

  static ProductLink? fromSlug(String slug) {
    final parts = slug.split(slugSeparator);
    if (parts.length != 2) {
      return null;
    }

    final variant = api.ProductIdVariant.fromJson(parts[0]);
    final id = parts[1];

    if (variant == null) {
      return null;
    }

    return ProductLink(
      variant: variant,
      id: id,
    );
  }
}

enum DataSourceEnum { wiki, off, eu, bCorp, fti, tco, other }

const dataSourceValues = {
  api.DataSource.wiki: DataSourceEnum.wiki,
  api.DataSource.off: DataSourceEnum.off,
  api.DataSource.eu: DataSourceEnum.eu,
  api.DataSource.bCorp: DataSourceEnum.bCorp,
  api.DataSource.fti: DataSourceEnum.fti,
  api.DataSource.tco: DataSourceEnum.tco,
  api.DataSource.other: DataSourceEnum.other,
};

extension DataSourceExtension on api.DataSource {
  DataSourceEnum toEnum() {
    return dataSourceValues[this] ?? DataSourceEnum.other;
  }
}

enum BadgeEnum { bcorp, eu, tco }

const badgeNameValues = {
  api.BadgeName.bcorp: BadgeEnum.bcorp,
  api.BadgeName.eu: BadgeEnum.eu,
  api.BadgeName.tco: BadgeEnum.tco,
};

extension BadgeNameExtension on api.BadgeName {
  BadgeEnum? toEnum() {
    return badgeNameValues[this];
  }
}

extension BadgeEnumExtension on BadgeEnum {
  api.LibraryTopic toLibraryTopic() {
    switch (this) {
      case BadgeEnum.bcorp:
        return api.LibraryTopic.certColonBcorp;
      case BadgeEnum.eu:
        return api.LibraryTopic.certColonEuEcolabel;
      case BadgeEnum.tco:
        return api.LibraryTopic.certColonTco;
    }
  }

  static List<BadgeEnum>? convertList(List<api.BadgeName>? list) {
    if (list == null) {
      return null;
    }

    var badges = <BadgeEnum>[];
    for (final name in list) {
      final badge = name.toEnum();
      if (badge != null) {
        badges.add(badge);
      }
    }
    return badges;
  }
}

enum ScorerEnum { fti }

const scorerNameValues = {
  api.ScorerName.fti: ScorerEnum.fti,
};

extension ScorerNameExtension on api.ScorerName {
  ScorerEnum? toEnum() {
    return scorerNameValues[this];
  }
}

extension ScorerEnumExtension on ScorerEnum {
  static Map<ScorerEnum, int>? convertList(List<api.Score>? list) {
    if (list == null) {
      return null;
    }

    var scores = <ScorerEnum, int>{};
    for (final entry in list) {
      final scorer = entry.scorerName.toEnum();
      if (scorer != null) {
        scores[scorer] = entry.score;
      }
    }
    return scores;
  }

  api.LibraryTopic toLibraryTopic() {
    switch (this) {
      case ScorerEnum.fti:
        return api.LibraryTopic.certColonFti;
    }
  }
}

enum SearchResultEnum { organisation, product, unknown }

enum PreviewVariant { organisation, product }

class ScoreData {
  final ScorerEnum scorer;
  final int score;

  ScoreData({required this.scorer, required this.score});

  Color get color {
    var value = 0.0;
    switch (scorer) {
      case ScorerEnum.fti:
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
  final api.DataSource? source;

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

    Widget? sourceWidget;
    switch (source) {
      case api.DataSource.wiki:
        sourceWidget = Text("Source: Wikidata", style: sourceStyle);
        break;
      case api.DataSource.off:
        sourceWidget = Text("Source: Open Food Facts", style: sourceStyle);
        break;
      case api.DataSource.eu:
        sourceWidget = Text("Source: Eu Ecolabel", style: sourceStyle);
        break;
      case api.DataSource.bCorp:
        sourceWidget = Text("Source: B Corp", style: sourceStyle);
        break;
      case api.DataSource.fti:
        sourceWidget =
            Text("Source: Fashion Transparency Index", style: sourceStyle);
        break;
      case api.DataSource.tco:
        sourceWidget = Text("Source: TCO", style: sourceStyle);
        break;
      case api.DataSource.other:
        sourceWidget = const Text("");
        break;
      case null:
        break;
    }

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
            SelectableText(text, style: textStyle),
            if (sourceWidget != null) ...[
              const Space(),
              sourceWidget,
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(defaultPadding)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: MarkdownBody(
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
          onTapLink: (text, url, title) async {
            if (url != null) {
              await url_launcher.launchUrl(Uri.parse(url));
            }
          },
        ),
      ),
    );
  }
}

class FashionTransparencyIndexWidget extends StatelessWidget {
  final api.Presentation presentation;
  final Navigation navigation;

  FashionTransparencyIndexWidget({
    super.key,
    required this.presentation,
    required this.navigation,
  }) {
    presentation.data.sort((a, b) => b.score.compareTo(a.score));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          for (final entry in presentation.data)
            ListTile(
              onTap: () => {
                navigation
                    .goToOrganisationLink(OrganisationLink.wiki(entry.wikiId))
              },
              mouseCursor: SystemMouseCursors.click,
              leading: Container(
                decoration: BoxDecoration(
                  color: ScoreData(
                    scorer: ScorerEnum.fti,
                    score: entry.score,
                  ).color,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(defaultPadding)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Text("${entry.score}%"),
                ),
              ),
              title: Text(entry.name),
            ),
        ],
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final api.LibraryItemFull item;
  final Navigation navigation;

  const ItemWidget({
    super.key,
    required this.item,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Title(text: item.title),
          const Space(),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                Article(markdown: item.article),
                if (item.presentation != null) ...[
                  const Space(),
                  if (item.id == api.LibraryTopic.certColonFti) ...[
                    FashionTransparencyIndexWidget(
                      presentation: item.presentation!,
                      navigation: navigation,
                    )
                  ]
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SourcedImage extends StatelessWidget {
  static const url1 = "https://commons.wikimedia.org/wiki/Special:FilePath";

  final String imagePath;
  final DataSourceEnum imageSource;

  const SourcedImage(this.imagePath, this.imageSource, {super.key});

  SourcedImage.fromApi(api.Image image, {super.key})
      : imagePath = image.image,
        imageSource = image.source_.toEnum();

  @override
  Widget build(BuildContext context) {
    String link;
    String url;
    String source;
    switch (imageSource) {
      case DataSourceEnum.wiki:
        link = "$url1/$imagePath";
        url = "$link?width=200";
        source = "Wikidata";
        break;
      case DataSourceEnum.off:
        link = imagePath;
        url = imagePath;
        source = "Open Food Facts";
        break;
      case DataSourceEnum.eu:
        link = imagePath;
        url = imagePath;
        source = "Eu Ecolabel";
        break;
      case DataSourceEnum.bCorp:
        link = imagePath;
        url = imagePath;
        source = "B-Corporations";
        break;
      case DataSourceEnum.fti:
        link = imagePath;
        url = imagePath;
        source = "Fashion Transparency Index";
        break;
      case DataSourceEnum.tco:
        link = imagePath;
        url = imagePath;
        source = "TCO";
        break;
      case DataSourceEnum.other:
        log.severe("Unknown data search variant");
        link = imagePath;
        url = imagePath;
        source = "???";
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

class LibraryContentsView extends StatelessWidget {
  final api.LibraryContents contents;
  final Navigation navigation;

  const LibraryContentsView(
      {super.key, required this.contents, required this.navigation});

  @override
  Widget build(BuildContext context) {
    final aboutUs = contents.items.where((i) => i.id.isInfo);
    final aboutData = contents.items.where((i) => i.id.isCert || i.id.isData);

    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        const Center(child: Section(text: "About us")),
        ...aboutUs.map((item) {
          return ListTile(
            leading: item.id.image,
            title: Text(item.title),
            subtitle: Text(item.summary),
            onTap: () => navigation.goToLibrary(item.id),
          );
        }),
        const Center(
            child: Section(text: "About certifications and data sources")),
        ...aboutData.map((item) {
          return ListTile(
            leading: item.id.image,
            title: Text(item.title),
            subtitle: Text(item.summary),
            onTap: () => navigation.goToLibrary(item.id),
          );
        }),
      ],
    );
  }
}

class LibraryItemView extends StatefulWidget {
  final api.LibraryTopic topic;
  final api.DefaultApi fetcher;
  final Navigation navigation;

  const LibraryItemView({
    super.key,
    required this.topic,
    required this.fetcher,
    required this.navigation,
  });

  @override
  State<LibraryItemView> createState() => _LibraryItemViewState();
}

class _LibraryItemViewState extends State<LibraryItemView>
    with AutomaticKeepAliveClientMixin {
  late Future<api.LibraryItemFull?> _futureItem;

  @override
  void initState() {
    super.initState();
    _futureItem = widget.fetcher.getLibraryItem(widget.topic);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.LibraryItemFull?>(
        future: _futureItem,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ItemWidget(
              item: snapshot.data!,
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

class LibraryPage extends StatefulWidget {
  final api.DefaultApi fetcher;
  final Navigation navigation;

  const LibraryPage({
    super.key,
    required this.fetcher,
    required this.navigation,
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late Future<api.LibraryContents?> _futureLibraryContents;

  @override
  void initState() {
    super.initState();
    _futureLibraryContents = widget.fetcher.getLibrary();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.LibraryContents?>(
        future: _futureLibraryContents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return LibraryContentsView(
              contents: snapshot.data!,
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

class SearchEntryWidget extends StatelessWidget {
  final String label;
  final TextSearchLink? link;
  final Navigation navigation;

  const SearchEntryWidget({
    super.key,
    required this.label,
    required this.link,
    required this.navigation,
  });

  SearchEntryWidget.fromApi({
    super.key,
    required api.TextSearchResult entry,
    required this.navigation,
  })  : label = entry.label,
        link = TextSearchLink.fromApi(entry.link);

  @override
  Widget build(BuildContext context) {
    Widget icon;
    Function() onTap;

    switch (link) {
      case OrganisationLink():
        final organisationLink = link as OrganisationLink;
        icon = const Tooltip(
          message: "manufacturer / organisation / business / shop",
          child: Icon(Icons.business_outlined),
        );
        onTap = () => navigation.goToOrganisationLink(organisationLink);
        break;
      case ProductLink():
        final productLink = link as ProductLink;
        icon = const Tooltip(
          message: "product / brand / item category",
          child: Icon(Icons.shopping_basket_outlined),
        );
        onTap = () => navigation.goToProductLink(productLink);
        break;
      case null:
        log.severe("Unknown search result variant");
        icon = const Icon(Icons.pending_outlined);
        onTap = () => {};
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        onTap: onTap,
        leading: icon,
        title: Text(label),
      ),
    );
  }
}

class ProductTileWidget extends StatelessWidget {
  final api.ProductShort product;
  final Function(api.ProductIds) onSelected;
  final Function(BadgeEnum) onBadgeTap;
  final Function(ScorerEnum) onScorerTap;

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
            onSelected(product.productIds);
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
                    badges: BadgeEnumExtension.convertList(product.badges),
                    scores: ScorerEnumExtension.convertList(product.scores),
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
  final BadgeEnum badge;
  final Function(BadgeEnum) onTap;

  const Badge({super.key, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap(badge);
        },
        child: badge.toLibraryTopic().image,
      ),
    );
  }
}

class Score extends StatelessWidget {
  final ScoreData score;
  final Function(ScorerEnum)? onTap;

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
          if (onTap != null) {
            onTap!(score.scorer);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: score.color,
            borderRadius:
                const BorderRadius.all(Radius.circular(defaultPadding)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                score.scorer.toLibraryTopic().image,
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
  final List<BadgeEnum>? badges;
  final Map<ScorerEnum, int>? scores;
  final Axis axis;
  final Function(BadgeEnum) onBadgeTap;
  final Function(ScorerEnum) onScorerTap;

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
              onTap: onScorerTap,
            )
        ],
      ],
    );
  }
}

class RibbonColumn extends RibbonFlex {
  const RibbonColumn({
    super.key,
    List<BadgeEnum>? badges,
    Map<ScorerEnum, int>? scores,
    required Function(BadgeEnum) onBadgeTap,
    required Function(ScorerEnum) onScorerTap,
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
    List<BadgeEnum>? badges,
    Map<ScorerEnum, int>? scores,
    required Function(BadgeEnum) onBadgeTap,
    required Function(ScorerEnum) onScorerTap,
  }) : super(
          badges: badges,
          scores: scores,
          axis: Axis.horizontal,
          onBadgeTap: onBadgeTap,
          onScorerTap: onScorerTap,
        );
}

class MedallionFrame extends StatelessWidget {
  final Widget child;
  final Color color;

  const MedallionFrame({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Container(
        height: medallionHeight,
        width: medallionWidth,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(defaultPadding)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: child,
        ),
      ),
    );
  }
}

class BCorpMedallion extends StatelessWidget {
  final api.BCorpMedallion medallion;
  final Function(api.LibraryTopic) onTopic;

  const BCorpMedallion({
    super.key,
    required this.medallion,
    required this.onTopic,
  });

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );
    final commentStyle = Theme.of(context).textTheme.bodyMedium;

    return MedallionFrame(
      color: Colors.green.shade200,
      child: Column(
        children: [
          Text("Certified by:", style: commentStyle),
          const Spacer(),
          Center(
            child: Row(
              children: [
                const Spacer(),
                api.LibraryTopic.certColonBcorp.image,
                const Space(),
                Text(
                  "BCorporations",
                  style: mainStyle,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
          ),
          const Spacer(),
          Row(children: [
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () async {
                final url = Uri.parse(
                    'https://github.com/sustainity-dev/issues/issues/new');
                await url_launcher.launchUrl(url);
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () => onTopic(api.LibraryTopic.certColonBcorp),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_outward_outlined),
              onPressed: () async {
                final url = Uri.parse(
                    'https://www.bcorporation.net/en-us/find-a-b-corp/company/${medallion.id}/');
                await url_launcher.launchUrl(url);
              },
            ),
          ])
        ],
      ),
    );
  }
}

class EuEcolabelMedallion extends StatelessWidget {
  final api.EuEcolabelMedallion medallion;
  final Function(api.LibraryTopic) onTopic;

  const EuEcolabelMedallion({
    super.key,
    required this.medallion,
    required this.onTopic,
  });

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );
    final commentStyle = Theme.of(context).textTheme.bodyMedium;

    return MedallionFrame(
      color: Colors.green.shade200,
      child: Column(
        children: [
          Text("Certified by:", style: commentStyle),
          const Spacer(),
          Center(
            child: Row(
              children: [
                const Spacer(),
                api.LibraryTopic.certColonEuEcolabel.image,
                const Space(),
                Text(
                  "EU Ecolabel",
                  style: mainStyle,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
          ),
          const Spacer(),
          Row(children: [
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () async {
                final url = Uri.parse(
                  'https://github.com/sustainity-dev/issues/issues/new',
                );
                await url_launcher.launchUrl(url);
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () => onTopic(api.LibraryTopic.certColonEuEcolabel),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_outward_outlined),
              onPressed: () async {
                final url = Uri.parse(
                  'https://environment.ec.europa.eu/topics/circular-economy/eu-ecolabel-home_en',
                );
                await url_launcher.launchUrl(url);
              },
            ),
          ])
        ],
      ),
    );
  }
}

class FtiMedallion extends StatelessWidget {
  final api.FtiMedallion medallion;
  final Function(api.LibraryTopic) onTopic;

  const FtiMedallion({
    super.key,
    required this.medallion,
    required this.onTopic,
  });

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );
    final commentStyle = Theme.of(context).textTheme.bodyMedium;

    final score = ScoreData(
      scorer: ScorerEnum.fti,
      score: medallion.score,
    );

    return MedallionFrame(
      color: score.color,
      child: Column(children: [
        Text(
          "Fashion Transparency Index",
          style: mainStyle,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          children: [
            const Spacer(),
            Text("Score:", style: commentStyle),
            const Spacer(),
            Text("${medallion.score}%", style: mainStyle),
            const Spacer(),
          ],
        ),
        const Spacer(),
        Row(children: [
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () async {
              final url = Uri.parse(
                  'https://github.com/sustainity-dev/issues/issues/new');
              await url_launcher.launchUrl(url);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outlined),
            onPressed: () => onTopic(api.LibraryTopic.certColonFti),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_outward_outlined),
            onPressed: () async {
              final url = Uri.parse(
                  'https://www.fashionrevolution.org/about/transparency/');
              await url_launcher.launchUrl(url);
            },
          ),
        ])
      ]),
    );
  }
}

class TcoMedallion extends StatelessWidget {
  final api.TcoMedallion medallion;
  final Function(api.LibraryTopic) onTopic;

  const TcoMedallion({
    super.key,
    required this.medallion,
    required this.onTopic,
  });

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );
    final commentStyle = Theme.of(context).textTheme.bodyMedium;

    return MedallionFrame(
      color: Colors.green.shade200,
      child: Column(
        children: [
          Text("Certified by:", style: commentStyle),
          const Spacer(),
          Center(
            child: Row(
              children: [
                const Spacer(),
                api.LibraryTopic.certColonTco.image,
                const Space(),
                Text(
                  "TCO",
                  style: mainStyle,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
          ),
          const Spacer(),
          Row(children: [
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () async {
                final url = Uri.parse(
                    'https://github.com/sustainity-dev/issues/issues/new');
                await url_launcher.launchUrl(url);
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () => onTopic(api.LibraryTopic.certColonTco),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_outward_outlined),
              onPressed: () async {
                final url = Uri.parse(
                    'https://tcocertified.com/product-finder/index?brand=${medallion.brandName}');
                await url_launcher.launchUrl(url);
              },
            ),
          ])
        ],
      ),
    );
  }
}

class MedallionSwitcher extends StatelessWidget {
  final api.Medallion medallion;
  final Function(api.LibraryTopic) onTopic;

  const MedallionSwitcher({
    super.key,
    required this.medallion,
    required this.onTopic,
  });

  @override
  Widget build(BuildContext context) {
    switch (medallion.variant) {
      case api.MedallionVariant.bCorp:
        return BCorpMedallion(
          medallion: medallion.bcorp!,
          onTopic: onTopic,
        );
      case api.MedallionVariant.euEcolabel:
        return EuEcolabelMedallion(
          medallion: medallion.euEcolabel!,
          onTopic: onTopic,
        );
      case api.MedallionVariant.fti:
        return FtiMedallion(
          medallion: medallion.fti!,
          onTopic: onTopic,
        );
      case api.MedallionVariant.sustainity:
        return SustainityMedallion(
          medallion: medallion.sustainity!,
        );
      case api.MedallionVariant.tco:
        return TcoMedallion(
          medallion: medallion.tco!,
          onTopic: onTopic,
        );
    }
    return const Space();
  }
}

class SustainityMedallion extends StatelessWidget {
  final api.SustainityMedallion medallion;

  const SustainityMedallion({super.key, required this.medallion});

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );
    final commentStyle = Theme.of(context).textTheme.bodyMedium;

    return MedallionFrame(
      color: Colors.yellow.shade200,
      child: Column(
        children: [
          Text(
            "Sustainity score",
            style: mainStyle,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            "${(10 * medallion.score.total).toStringAsFixed(2)} / 10",
            style: mainStyle,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            "This is still work in progress!",
            style: commentStyle,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                onPressed: () async {
                  final url = Uri.parse(
                      'https://github.com/sustainity-dev/issues/issues/new');
                  await url_launcher.launchUrl(url);
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_outlined),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SustainityScoreDetailsPopup(
                        score: medallion.score,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GhgMedallion extends StatelessWidget {
  const GhgMedallion({super.key});

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );
    final commentStyle = Theme.of(context).textTheme.bodyMedium;

    return MedallionFrame(
      color: Colors.grey.shade400,
      child: Column(
        children: [
          Text(
            "CO2 emissions",
            style: mainStyle,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(children: [
            const Spacer(),
            Text("During production:", style: commentStyle),
            const Spacer(),
            Text("?", style: mainStyle),
            const Spacer(),
          ]),
          const Spacer(),
          Row(children: [
            const Spacer(),
            Text("During exploitation:", style: commentStyle),
            const Spacer(),
            Text("?", style: mainStyle),
            const Spacer(),
          ]),
          const Spacer(),
          Text(
            "More data needed.\nWe are working on it!",
            style: commentStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DisposalMedallion extends StatelessWidget {
  const DisposalMedallion({super.key});

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );
    final commentStyle = Theme.of(context).textTheme.bodyMedium;

    return MedallionFrame(
      color: Colors.grey.shade400,
      child: Column(
        children: [
          Text(
            "Disposal",
            style: mainStyle,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(children: [
            const Spacer(),
            Text("Product:", style: commentStyle),
            const Spacer(),
            Text("?", style: mainStyle),
            const Spacer(),
          ]),
          const Spacer(),
          Row(children: [
            const Spacer(),
            Text("Packaging:", style: commentStyle),
            const Spacer(),
            Text("?", style: mainStyle),
            const Spacer(),
          ]),
          const Spacer(),
          Text(
            "More data needed.\nWe are working on it!",
            style: commentStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OrganisationMedallions extends StatelessWidget {
  final List<api.Medallion> medallions;
  final Function(api.LibraryTopic) onTopic;

  const OrganisationMedallions({
    super.key,
    required this.medallions,
    required this.onTopic,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        for (final medallion in medallions)
          MedallionSwitcher(medallion: medallion, onTopic: onTopic),
      ],
    );
  }
}

class ProductMedallions extends StatelessWidget {
  final List<api.Medallion> medallions;
  final Function(api.LibraryTopic) onTopic;

  const ProductMedallions({
    super.key,
    required this.medallions,
    required this.onTopic,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        for (final medallion in medallions)
          MedallionSwitcher(medallion: medallion, onTopic: onTopic),
        const GhgMedallion(),
        const DisposalMedallion(),
      ],
    );
  }
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
              navigation.goToLibrary(api.LibraryTopic.infoColonForProducers);
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

class ProductListWidget extends StatelessWidget {
  final List<api.ProductShort> products;
  final String emptyText;
  final Navigation navigation;

  const ProductListWidget({
    super.key,
    required this.products,
    required this.emptyText,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isNotEmpty) {
      return SizedBox(
        height: tileHeight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final product in products)
              ProductTileWidget(
                product: product,
                onSelected: navigation.goToProduct,
                onBadgeTap: navigation.onBadgeTap,
                onScorerTap: navigation.onScorerTap,
              ),
          ],
        ),
      );
    } else {
      return Center(child: Text(emptyText));
    }
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
        ProductListWidget(
          products: ca.alternatives,
          emptyText:
              "No alternatives?... That might be some problem in our data...",
          navigation: navigation,
        ),
      ],
    );
  }
}

class SustainityScoreBranchesInfo {
  final String symbol;
  final String description;

  const SustainityScoreBranchesInfo({
    required this.symbol,
    required this.description,
  });
}

const sustainityScoreBranchesInfos = {
  api.SustainityScoreCategory.dataAvailability: SustainityScoreBranchesInfo(
    symbol: "💁",
    description:
        "Data availability\n\nThe more we know about this product the more information we can infer about it.",
  ),
  api.SustainityScoreCategory.producerKnown: SustainityScoreBranchesInfo(
    symbol: '🏭',
    description:
        "Do we know who produced this product?\n\nIf so, we can include the producers score in products score.",
  ),
  api.SustainityScoreCategory.categoryAssigned: SustainityScoreBranchesInfo(
    symbol: '📥',
    description:
        "Is this product assigned to any category?\n\nIf so, we can compare it to other products and find alternatives.",
  ),
  api.SustainityScoreCategory.productionPlaceKnown: SustainityScoreBranchesInfo(
    symbol: '🌐',
    description:
        "Do we know the place of production?\n\nIf so, we can infer CO2 emissions to deliver it to you or your shop.",
  ),
  api.SustainityScoreCategory.idKnown: SustainityScoreBranchesInfo(
    symbol: '👈',
    description:
        "Has any identification number?\n\nIf so, we can easily find it various data sources to learn more about it.",
  ),
  api.SustainityScoreCategory.category: SustainityScoreBranchesInfo(
    symbol: '📂',
    description: "Various scores unique to product category.",
  ),
  api.SustainityScoreCategory.warrantyLength: SustainityScoreBranchesInfo(
    symbol: '👮',
    description:
        "Length of warranty.\n\nWe can use it as a proxy of durability. More durable products need to be replaced less frequenty.",
  ),
  api.SustainityScoreCategory.numCerts: SustainityScoreBranchesInfo(
    symbol: '📜',
    description: "Does this product (or its producer) have any certifications?",
  ),
  api.SustainityScoreCategory.atLeastOneCert: SustainityScoreBranchesInfo(
    symbol: '🙋',
    description: "At least one certification.",
  ),
  api.SustainityScoreCategory.atLeastTwoCerts: SustainityScoreBranchesInfo(
    symbol: '🙌',
    description: "At least two certifications.",
  ),
};

class SustainityScoreBranchesWidget extends StatelessWidget {
  static const double textPadding = 10.0;
  static const double tablePadding = 8.0;

  final List<api.SustainityScoreBranch> branches;

  const SustainityScoreBranchesWidget({
    super.key,
    required this.branches,
  });

  @override
  Widget build(BuildContext context) {
    final symbolStyle = Theme.of(context).textTheme.headlineSmall;

    return Table(
      border: const TableBorder(
        horizontalInside: BorderSide(width: 1.0, color: Colors.black),
        verticalInside: BorderSide(width: 1.0, color: Colors.black),
      ),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final branch in branches)
          TableRow(
            children: [
              Tooltip(
                message: sustainityScoreBranchesInfos[branch.category]
                        ?.description ??
                    "",
                child: Padding(
                  padding: const EdgeInsets.all(textPadding),
                  child: Text(
                      sustainityScoreBranchesInfos[branch.category]?.symbol ??
                          "",
                      style: symbolStyle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(textPadding),
                child: Text("${branch.weight}"),
              ),
              Padding(
                padding: const EdgeInsets.all(textPadding),
                child: Text(branch.score.toStringAsFixed(2)),
              ),
              branch.branches.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(tablePadding),
                      child: SustainityScoreBranchesWidget(
                        branches: branch.branches,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(tablePadding),
                      child: Text(
                        (branch.score > 0.5) ? '✔' : '✖',
                        style: symbolStyle,
                      ),
                    ),
            ],
          ),
      ],
    );
  }
}

class SustainityScoreDetailsWidget extends StatelessWidget {
  final api.SustainityScore score;

  const SustainityScoreDetailsWidget({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final mainStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SustainityScoreBranchesWidget(branches: score.tree),
                Text(
                  "Total: ${score.total.toStringAsFixed(3)}",
                  style: mainStyle,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SustainityDialog extends Dialog {
  final Widget content;

  const SustainityDialog({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(defaultPadding)),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(defaultPadding)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: content,
        ),
      ),
    );
  }
}

class SustainityScoreDetailsPopup extends StatelessWidget {
  final api.SustainityScore score;

  const SustainityScoreDetailsPopup({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
        );

    return SustainityDialog(
      content: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Sustainity score details",
                  style: headerStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          SustainityScoreDetailsWidget(score: score),
        ],
      ),
    );
  }
}

class CountrySelectionPopup extends StatelessWidget {
  final Function(String?) onSelected;
  final Function() onCancelled;

  const CountrySelectionPopup({
    super.key,
    required this.onSelected,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return SustainityDialog(
      content: Column(
        children: [
          Row(children: [
            const Section(text: "Select region"),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                onCancelled();
                Navigator.of(context).pop();
              },
            ),
          ]),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                ListTile(
                  title: const Text("world-wide"),
                  onTap: () {
                    onSelected(null);
                    Navigator.of(context).pop();
                  },
                ),
                for (final country in countries_utils.Countries.all())
                  ListTile(
                    title: Text(
                        "${country.flagIcon ?? ""} ${country.name ?? "<unknown>"}"),
                    onTap: () {
                      onSelected(country.alpha2Code);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Settings {
  String? regionCode;

  Settings({required this.regionCode});
}

class SettingsWidget extends StatefulWidget {
  final Settings settings;
  final Function() onCancelled;
  final Function(Settings) onSaved;

  const SettingsWidget({
    super.key,
    required this.settings,
    required this.onCancelled,
    required this.onSaved,
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late String? regionCode;

  @override
  void initState() {
    super.initState();
    regionCode = widget.settings.regionCode;
  }

  @override
  Widget build(BuildContext context) {
    var region = 'world-wide';
    if (regionCode != null) {
      final country = countries_utils.Countries.byCode(regionCode!);
      region = "${country.flagIcon ?? ""} ${country.name ?? "<unknown>"}";
    }

    return Column(
      children: [
        const Section(text: 'Settings'),
        Row(
          children: [
            const Text('Region:'),
            const Space(),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CountrySelectionPopup(
                      onSelected: (code) {
                        setState(() {
                          regionCode = code;
                        });
                      },
                      onCancelled: () {},
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(region),
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                widget.onCancelled();
              },
              icon: const Icon(Icons.close),
              label: const Text("Cancel"),
            ),
            const Space(),
            FilledButton.icon(
              onPressed: () {
                widget.onSaved(Settings(regionCode: regionCode));
              },
              icon: const Icon(Icons.check),
              label: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsPopup extends StatelessWidget {
  final Settings settings;
  final Function(Settings) onSaved;

  const SettingsPopup({
    super.key,
    required this.settings,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SustainityDialog(
      content: SettingsWidget(
        settings: settings,
        onCancelled: () {
          Navigator.of(context).pop();
        },
        onSaved: (settings) {
          onSaved(settings);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class OrganisationWidget extends StatelessWidget {
  final api.OrganisationShort organisation;
  final String source;
  final Function(api.OrganisationIds) onOrganisationTap;
  final Function(BadgeEnum) onBadgeTap;
  final Function(ScorerEnum) onScorerTap;

  const OrganisationWidget({
    super.key,
    required this.organisation,
    required this.source,
    required this.onOrganisationTap,
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onOrganisationTap(organisation.organisationIds);
        },
        child: Container(
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
                  badges: BadgeEnumExtension.convertList(organisation.badges),
                  scores: ScorerEnumExtension.convertList(organisation.scores),
                  onBadgeTap: onBadgeTap,
                  onScorerTap: onScorerTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExampleSearchBox extends StatelessWidget {
  final String query;
  final String tip;
  final Function(String) onSubmitted;

  const ExampleSearchBox({
    super.key,
    required this.query,
    required this.tip,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final queryStyle = Theme.of(context).textTheme.headlineSmall;
    final tipStyle = Theme.of(context).textTheme.bodyLarge;

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
            Row(
              children: [
                SelectableText('"$query"', style: queryStyle),
                const Spacer(),
                FilledButton(
                  onPressed: () => onSubmitted(query),
                  child: const Text('Search'),
                ),
              ],
            ),
            const Space(),
            Text(tip, style: tipStyle),
          ],
        ),
      ),
    );
  }
}

class OrganisationView extends StatelessWidget {
  final api.OrganisationFull organisation;
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
          Title(text: organisation.names[0].text),
          const Space(),
          Expanded(
            child: ListView(
              children: [
                const Section(text: 'Descriptions:'),
                if (organisation.descriptions.isNotEmpty) ...[
                  for (final description in organisation.descriptions)
                    Description(
                      text: description.text,
                      source: description.source_,
                    )
                ] else ...[
                  const Center(child: Text("No description..."))
                ],
                OrganisationMedallions(
                  medallions: organisation.medallions,
                  onTopic: navigation.goToLibrary,
                ),
                const Section(text: 'Images'),
                if (organisation.images.isNotEmpty) ...[
                  SizedBox(
                    height: tileHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final image in organisation.images)
                          SourcedImage.fromApi(image)
                      ],
                    ),
                  )
                ] else ...[
                  const Center(child: Text("No images..."))
                ],
                const Section(text: 'Example products'),
                ProductListWidget(
                  products: organisation.products,
                  emptyText: "Seems like this organisation has no products...",
                  navigation: navigation,
                ),
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
          Title(text: product.names.map((n) => n.text).join("\n")),
          const Space(),
          Expanded(
            child: ListView(
              children: [
                const Section(text: 'Descriptions:'),
                if (product.descriptions.isNotEmpty) ...[
                  for (final description in product.descriptions)
                    Description(
                      text: description.text,
                      source: description.source_,
                    )
                ] else ...[
                  const Center(child: Text("No description..."))
                ],
                ProductMedallions(
                  medallions: product.medallions,
                  onTopic: navigation.goToLibrary,
                ),
                const Section(text: 'Producers:'),
                if (product.manufacturers.isNotEmpty) ...[
                  for (final manufacturer in product.manufacturers)
                    OrganisationWidget(
                      organisation: manufacturer,
                      source: "wikidata",
                      onOrganisationTap: navigation.goToOrganisation,
                      onBadgeTap: navigation.onBadgeTap,
                      onScorerTap: navigation.onScorerTap,
                    )
                ],
                const Section(text: 'Images'),
                if (product.images.isNotEmpty) ...[
                  SizedBox(
                    height: tileHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final image in product.images)
                          SourcedImage.fromApi(image)
                      ],
                    ),
                  )
                ] else ...[
                  const Center(child: Text("No images..."))
                ],
                for (final a in product.alternatives)
                  CategoryAlternativesWidget(ca: a, navigation: navigation),
                const Section(text: 'Barcodes'),
                product.productIds.gtins.isNotEmpty
                    ? Description(text: product.productIds.gtins.join(", "))
                    : const Center(child: Text("No barcodes...")),
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
  final OrganisationLink link;
  final Navigation navigation;
  final api.DefaultApi fetcher;

  const OrganisationPage({
    super.key,
    required this.link,
    required this.navigation,
    required this.fetcher,
  });

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage>
    with AutomaticKeepAliveClientMixin {
  late Future<api.OrganisationFull?> _futureOrganisation;

  @override
  void initState() {
    super.initState();
    _futureOrganisation =
        widget.fetcher.getOrganisation(widget.link.variant, widget.link.id);
  }

  @override
  void didUpdateWidget(OrganisationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _futureOrganisation =
        widget.fetcher.getOrganisation(widget.link.variant, widget.link.id);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.OrganisationFull?>(
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
  final ProductLink link;
  final String? regionCode;
  final Navigation navigation;
  final api.DefaultApi fetcher;

  const ProductPage({
    super.key,
    required this.link,
    required this.regionCode,
    required this.navigation,
    required this.fetcher,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin {
  late Future<api.ProductFull?> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = widget.fetcher.getProduct(
        widget.link.variant, widget.link.id,
        region: widget.regionCode);
  }

  @override
  void didUpdateWidget(ProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _futureProduct = widget.fetcher.getProduct(
        widget.link.variant, widget.link.id,
        region: widget.regionCode);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: FutureBuilder<api.ProductFull?>(
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
  final api.DefaultApi fetcher;
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
  List<api.TextSearchResult> _entries = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final largeStyle = Theme.of(context).textTheme.headlineSmall;

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
                onPressed: () => _onSubmitted(_searchFieldController.text),
                child: const Text('Search'),
              ),
            ],
          ),
          const Space(),
          if (_searching) ...[
            const CircularProgressIndicator()
          ] else if (_searchFieldController.text.isEmpty) ...[
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    const SizedBox(width: 500, height: 50),
                    Text(
                      "Looking around? Try these example queries:",
                      style: largeStyle,
                    ),
                    const Space(),
                    ExampleSearchBox(
                      query: "fairphone",
                      tip:
                          "Fairphone is a Dutch electronics manufacturer and social enterprise that designs and produces smartphones with the goal of having a lower environmental footprint and better social impact than is common in the industry.",
                      onSubmitted: _onExampleSubmitted,
                    ),
                    const Space(),
                    ExampleSearchBox(
                      query: "8717677339556",
                      tip:
                          "Did you find a barcode on a product and want to learn more? Just type it in the search box! (This one belongs to Tony's Chocolonely.)",
                      onSubmitted: _onExampleSubmitted,
                    ),
                    const Space(),
                    ExampleSearchBox(
                      query: "shein.com",
                      tip:
                          "Want to buy clothes online? Just enter the website address to learn if an ethical consumer should buy from there. (Spoiler: you shouldn't buy from SHEIN, but check it yourself!)",
                      onSubmitted: _onExampleSubmitted,
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_entries.isNotEmpty) ...[
            Flexible(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  for (final entry in _entries)
                    SearchEntryWidget.fromApi(
                      entry: entry,
                      navigation: widget.navigation,
                    )
                ],
              ),
            ),
          ] else ...[
            Center(child: Text("No results found", style: largeStyle)),
          ],
        ],
      ),
    );
  }

  Future<void> _onSubmitted(String text) async {
    if (_searching) {
      return;
    }
    setState(() {
      _searching = true;
      _entries = [];
    });
    final result = await widget.fetcher.searchByText(text);
    setState(() {
      _searching = false;
      _entries = result?.results ?? [];
    });
  }

  Future<void> _onExampleSubmitted(String text) async {
    _searchFieldController.text = text;
    await _onSubmitted(text);
  }
}

class ProductArguments {
  final ProductLink link;

  ProductArguments({required this.link});
}

class ProductScreen extends StatelessWidget {
  final ProductLink link;
  final Navigation navigation;
  final api.DefaultApi fetcher;
  final Settings settings;

  const ProductScreen({
    super.key,
    required this.link,
    required this.navigation,
    required this.fetcher,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product"),
      ),
      body: ProductPage(
        link: link,
        regionCode: settings.regionCode,
        navigation: navigation,
        fetcher: fetcher,
      ),
    );
  }
}

class OrganisationArguments {
  final OrganisationLink link;

  OrganisationArguments({required this.link});
}

class OrganisationScreen extends StatelessWidget {
  final OrganisationLink link;
  final api.DefaultApi fetcher;
  final Navigation navigation;

  const OrganisationScreen({
    super.key,
    required this.link,
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
        link: link,
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
  final api.DefaultApi fetcher;
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
      body: LibraryItemView(
        topic: topic,
        fetcher: fetcher,
        navigation: navigation,
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  final api.DefaultApi fetcher;
  final Navigation navigation;
  final Settings settings;
  final Function(Settings) onSettingsChanged;

  const RootScreen({
    super.key,
    required this.fetcher,
    required this.navigation,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  static const int _tabNum = 5;

  late Settings _settings;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _tabController = TabController(length: _tabNum, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SettingsPopup(
                    settings: _settings,
                    onSaved: (settings) {
                      setState(() {
                        _settings = settings;
                        widget.onSettingsChanged(settings);
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.lightGreen[200],
          indicatorColor: Colors.lightGreen[100],
          indicatorWeight: 7,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.home_outlined),
            ),
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
          LibraryItemView(
            topic: api.LibraryTopic.infoColonMain,
            fetcher: widget.fetcher,
            navigation: widget.navigation,
          ),
          LibraryPage(
            fetcher: widget.fetcher,
            navigation: widget.navigation,
          ),
          TextSearchPage(
            fetcher: widget.fetcher,
            navigation: widget.navigation,
          ),
          const Center(
            child: Text('There will be map search here.\n\nWork in progress!'),
          ),
          const Center(
            child: Text('There will be QRC search here.\n\nWork in progress!'),
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

  void goToProduct(api.ProductIds productIds) {
    final productLink = ProductLink.fromIds(productIds);
    if (productLink != null) {
      goToProductLink(productLink);
    }
  }

  void goToProductLink(ProductLink link) {
    Navigator.pushNamed(
      context,
      "$productPath${link.toSlug()}",
      arguments: AppArguments(
        NavigationPath.product,
        ProductArguments(link: link),
      ),
    );
  }

  void goToOrganisation(api.OrganisationIds organisationIds) {
    final organisationLink = OrganisationLink.fromIds(organisationIds);
    if (organisationLink != null) {
      goToOrganisationLink(organisationLink);
    }
  }

  void goToOrganisationLink(OrganisationLink link) {
    Navigator.pushNamed(
      context,
      "$organisationPath${link.toSlug()}",
      arguments: AppArguments(
        NavigationPath.organisation,
        OrganisationArguments(link: link),
      ),
    );
  }

  void goToLibrary(api.LibraryTopic topic) {
    Navigator.pushNamed(
      context,
      "$libraryPath${topic.value}",
      arguments: AppArguments(
        NavigationPath.library,
        LibraryArguments(topic: topic),
      ),
    );
  }

  void onBadgeTap(BadgeEnum badge) {
    goToLibrary(badge.toLibraryTopic());
  }

  void onScorerTap(ScorerEnum scorer) {
    goToLibrary(scorer.toLibraryTopic());
  }
}

class AppArguments {
  final NavigationPath path;
  final dynamic args;

  AppArguments(this.path, this.args);
}

class SustainityFrontend extends StatefulWidget {
  final api.DefaultApi fetcher;

  const SustainityFrontend({super.key, required this.fetcher});

  @override
  State<SustainityFrontend> createState() => _SustainityFrontendState();
}

class _SustainityFrontendState extends State<SustainityFrontend>
    with TickerProviderStateMixin {
  Settings _settings = Settings(regionCode: null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sustainity',
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
                    settings: _settings,
                    onSettingsChanged: (settings) {
                      setState(() {
                        _settings = settings;
                      });
                    },
                  );
                },
              );
            case NavigationPath.product:
              final args = appArgs.args as ProductArguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return ProductScreen(
                    link: args.link,
                    fetcher: widget.fetcher,
                    navigation: Navigation(context),
                    settings: _settings,
                  );
                },
              );
            case NavigationPath.organisation:
              final args = appArgs.args as OrganisationArguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return OrganisationScreen(
                    link: args.link,
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
      final slug = path.substring(Navigation.productPath.length);
      final link = ProductLink.fromSlug(slug);
      if (link != null) {
        return AppArguments(
          NavigationPath.product,
          ProductArguments(link: link),
        );
      } else {
        log.severe("Failed to parse path: '$path'");
        return AppArguments(NavigationPath.root, null);
      }
    }

    if (path.startsWith(Navigation.organisationPath)) {
      final slug = path.substring(Navigation.organisationPath.length);
      final link = OrganisationLink.fromSlug(slug);
      if (link != null) {
        return AppArguments(
          NavigationPath.organisation,
          OrganisationArguments(link: link),
        );
      } else {
        log.severe("Failed to parse path: '$path'");
        return AppArguments(NavigationPath.root, null);
      }
    }

    if (path.startsWith(Navigation.libraryPath)) {
      final topicName = path.substring(Navigation.libraryPath.length);
      final topic = api.LibraryTopic.fromJson(topicName);
      if (topic != null) {
        return AppArguments(
          NavigationPath.library,
          LibraryArguments(topic: topic),
        );
      }
    }

    return AppArguments(NavigationPath.root, null);
  }
}
