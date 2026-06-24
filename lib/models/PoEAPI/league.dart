import "package:poe_monitor/models/PoEAPI/realm.dart";

class League {
  League({
    required this.id,
    required this.realm,
    required this.url,
    this.description = "",
    this.startAt,
    this.endAt,
    this.registerAt,
    this.delve = false,
    required this.rules,
  });

  final String id;
  final LeagueRealm realm;
  final Uri url;
  final String description;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? registerAt;
  final bool delve;
  final List<LeagueRule> rules;

  factory League.fromJSON(Map<String, dynamic> item) => League(
      id: item["id"] == null ? "nullLeague" : item["id"]!,
      realm: leagueRealmFromString(item["realm"]),
      url: item["url"] == null ? Uri.parse("") : Uri.parse(item["url"]!),
      description: item["description"] == null ? "" : item["description"]!,
      startAt:
          item["startAt"] == null ? null : DateTime.parse(item["startAt"]!),
      endAt: item["endAt"] == null ? null : DateTime.parse(item["endAt"]!),
      registerAt: item["registerAt"] == null
          ? null
          : DateTime.parse(item["registerAt"]!),
      delve: item["delveEvent"] == null ? false : item["delveEvent"]!,
      rules: item["rules"]
          .map<LeagueRule>((dynamic rule) => LeagueRule.fromJSON(rule))
          .toList());
  Map<String, dynamic> toJson() => {
        "id": id,
        "realm": realm,
        "url": url,
        "description": description,
        "startAt": startAt,
        "endAt": endAt,
        "registerAt": registerAt,
        "delveEvent": delve
      };
}

class LeagueRule {
  LeagueRule({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;

  factory LeagueRule.fromJSON(Map<String, dynamic> rule) => LeagueRule(
        id: rule["id"],
        name: rule["name"],
        description: rule["description"],
      );
}
