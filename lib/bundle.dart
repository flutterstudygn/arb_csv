import 'bundle_item.dart';

class Bundle {
  final DateTime lastModified;
  final String locale;
  final String context;
  final String author;
  final Set<BundleItem> items;

  Bundle(
      {DateTime lastModified,
      this.locale,
      this.context,
      this.author,
      this.items = const {}})
      : lastModified = lastModified ?? DateTime.now();

  factory Bundle.fromArb(Map<String, dynamic> arb) {
    final bundleItems = Map.fromEntries(
      arb.entries.where(
        (element) => !element.key.startsWith('@@'),
      ),
    );

    final bundle = Bundle(
      author: arb['@@author'],
      context: arb['@@context'],
      lastModified: DateTime.parse(arb['@@last_modified']),
      locale: arb['@@locale'],
      items: {},
    );

    for (final item in bundleItems.entries) {
      if (item.key.startsWith('@')) continue;

      final name = item.key;
      final value = item.value;
      final options = bundleItems['@$name'];

      bundle.items.add(BundleItem(
        name,
        value,
        description: options['description'],
        placeholders: {...(options['placeholders'] as Map).keys},
        type: options['type'],
      ));
    }

    return bundle;
  }

  Map<String, dynamic> get arb => {
        '@@last_modified': lastModified.toIso8601String(),
        '@@locale': locale,
        '@@context': context,
        '@@author': author,
      };

  @override
  String toString() => arb.toString();
}