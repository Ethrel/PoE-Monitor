import 'package:poe_monitor/API/api_data.dart';
import 'package:poe_monitor/models/PoEAPI/stash_item.dart';
import 'package:poe_monitor/models/PoEAPI/stash_layout.dart';

class StashContent {
  StashContent({
    required this.layout,
    required this.content,
    required this.isErrored,
  });

  final StashLayout? layout;
  final List<StashItem> content;
  final bool isErrored;

  factory StashContent.fromJSON(Map<String, dynamic>? layout, List<dynamic> items, APIData api) => StashContent(
        layout: null, //StashLayout.fromJSON(layout),
        content: items.map<StashItem>((e) {
          return StashItem.fromJSON(e, api);
        }).toList(),
        isErrored: false,
      );
}
