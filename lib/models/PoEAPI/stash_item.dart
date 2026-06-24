import 'package:flutter/material.dart';
import 'package:poe_monitor/API/api_data.dart';
import 'package:poe_monitor/models/PoEAPI/league.dart';

enum FrameType {
  normal,
  magic,
  rare,
  unique,
  gem,
  currency,
  divinationCard,
  unknown7,
  unknown8,
  unknown9,
  unknown10,
  // ignore: constant_identifier_names
  UNKNOWN
}

FrameType frameTypeFromInt(int type) {
  try {
    return FrameType.values.elementAt(type);
  } on ArgumentError {
    return FrameType.UNKNOWN;
  }
}

class StashItem {
  StashItem({
    required this.displayName,
    required this.league,
    required this.id,
    required this.typeLine,
    required this.baseType,
    required this.amount,
    this.icon,
  });

  final String displayName;
  final League? league;
  final String id;
  final String typeLine;
  final String baseType;
  final int amount;
  final Image? icon;

  double price = 0.0;

  factory StashItem.fromJSON(Map<String, dynamic> item, APIData api) {
    return StashItem(
      league: api.findLeagueByID(item["league"]),
      id: item["id"],
      displayName: item["name"],
      typeLine: item["typeLine"],
      baseType: item["baseType"],
      amount: item["stackSize"] ?? 1,
      icon: item["icon"] != null ? Image.network(Uri.parse(item["icon"]).toString()) : null,
    );
  }
}
