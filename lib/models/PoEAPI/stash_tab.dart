// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import 'stash_item.dart';

enum StashType {
  UNKNOWN,
  Currency,
  Delve,
  Delirium,
  Metamorph,
  Blight,
  Essence,
  Quad,
  DivinationCard,
  Map,
  Fragment,
  Premium,
  Unique,
}

StashType stashTabTypeFromString(String stashTypeString) {
  try {
    stashTypeString = stashTypeString.replaceAll("Stash", "");
    return StashType.values.byName(stashTypeString);
  } on ArgumentError {
    return StashType.UNKNOWN;
  }
}

class StashTab {
  StashTab({
    required this.name,
    required this.index,
    required this.id,
    required this.type,
    this.isEmpty = false,
    this.isErrored = false,
  });

  final String name;
  final int index;
  final String id;
  final StashType type;

  bool isEmpty;
  bool isErrored;

  ValueNotifier<List<StashItem>> content = ValueNotifier(List.empty());

  factory StashTab.fromJSON(Map<String, dynamic> charData) => StashTab(
        name: charData["n"],
        index: charData["i"],
        id: charData["id"],
        type: stashTabTypeFromString(charData["type"]),
      );
}
