import 'package:flutter/material.dart';
import 'package:poe_monitor/models/PoEAPI/item_category.dart';

class ItemInfo {
  ItemInfo({
    required this.category,
    required this.name,
    required this.shortName,
    this.icon,
  });

  final ItemCategory? category;
  final String? name;
  final String? shortName;
  final Image? icon;

  double price = 0.0;

  factory ItemInfo.fromJSON(ItemCategory category, Map<String, dynamic> info) => ItemInfo(
        category: category,
        name: info["text"],
        shortName: info["id"],
        icon: info["image"] != null ? Image.network(Uri.https("web.poecdn.com", info["image"]).toString()) : null,
      );
}
