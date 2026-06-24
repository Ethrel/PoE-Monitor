/*enum poeninjaCategories {
  Currency("currencyoverview", "Currency"),

  const poeninjaCategories({required this.endpoint, required this.type});
  final String endpoint;
  final String type;
}*/

class ItemCategory {
  ItemCategory({
    required this.id,
    required this.name,
    //required this.poeninja,
  });

  final String id;
  final String name;
  //final poeninjaCategories poeninja;

  factory ItemCategory.fromJSON(Map<String, dynamic> cat) => ItemCategory(
        id: cat['id'],
        name: cat['label'] ?? "UNKNOWN",
        //poeninja: getNinjaCategory(cat['id']),
      );
}
