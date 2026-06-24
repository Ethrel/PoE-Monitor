class ItemPrice {
  ItemPrice({
    required this.name,
    required this.price,
  });

  final String name;
  final double price;

  factory ItemPrice.fromJSON(dynamic priceInfo) => ItemPrice(
        name: priceInfo["name"] ?? "Unknown",

        // currency returns price in [receive][value] (slightly more accurate, preferred)
        // currency returns price in [chaosEquivalent] (slightly less accurate, but exists when confidence is low) (avg-ish of pay and receive values)
        // items return price in [chaosValue] (only option)
        price: (priceInfo["primaryValue"] is double ? priceInfo["primaryValue"] : priceInfo["primaryValue"].toDouble()) ?? 0.0
      );
}
