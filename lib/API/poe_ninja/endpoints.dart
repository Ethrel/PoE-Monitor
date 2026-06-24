import 'package:poe_monitor/API/endpoint.dart';
import 'package:poe_monitor/models/poe_ninja/item_price.dart';



enum PriceInfoCategories {
  currency(urlReplacement: "Currency", endpoint: "overview"),
  fragments(urlReplacement: "Fragment", endpoint: "overview"),
  wombgift(urlReplacement: "Wombgift", endpoint: "overview"),
  runegraft(urlReplacement: "Runegraft", endpoint: "overview"),
  allflameember(urlReplacement: "AllFlameEmber", endpoint: "overview"),
  tattoo(urlReplacement: "Tattoo", endpoint: "overview"),
  omen(urlReplacement: "Omen", endpoint: "overview"),
  djinncoin(urlReplacement: "DjinnCoin", endpoint: "overview"),
  divCard(urlReplacement: "DivinationCard", endpoint: "overview"),
  artifact(urlReplacement: "Artifact", endpoint: "overview"),
  oil(urlReplacement: "Oil", endpoint: "overview"),
  incubator(urlReplacement: "Incubator", endpoint: "overview"),
  scarab(urlReplacement: "Scarab", endpoint: "overview"),
  fossil(urlReplacement: "Fossil", endpoint: "overview"),
  resonator(urlReplacement: "Resonator", endpoint: "overview"),
  essence(urlReplacement: "Essence", endpoint: "overview"),

  /*
     Current unsupported
     -> Need to grab Path of Exile trade data for all other items...
     -> and decide what I can price and what I can't.
     => Not worth the effort yet.
  gem(urlReplacement: "SkillGem", endpoint: "itemoverview"),
  */

  /*
     Currently unsupported
     -> Need Path of Exile API to export unique tabs
     -> Need to care about doing it for other tabs?
  uniqWeapon(urlReplacement: "UniqueWeapon", endpoint: "itemoverview"),
  uniqArmour(urlReplacement: "UniqueArmour", endpoint: "itemoverview"),
  uniqAccessory(urlReplacement: "UniqueAccessory", endpoint: "itemoverview"),
  uniqFlask(urlReplacement: "UniqueFlask", endpoint: "itemoverview"),
  uniqJewel(urlReplacement: "UniqueJewel", endpoint: "itemoverview"),
  */
  ;

  const PriceInfoCategories({
    required this.endpoint,
    required this.urlReplacement,
  });
  final String endpoint;
  final String urlReplacement;
}

class Endpoints {
  static Future<List<ItemPrice>> getPriceInfo(String league, PriceInfoCategories category) => _PriceInfoEndpoint().getData(league, category);
}

class _PriceInfoEndpoint {
  Endpoint endpoint = Endpoint(
    urlString: "https://poe.ninja/poe1/api/economy/exchange/current/%endpoint\$?league=%league\$&type=%category\$",
    httpMethod: HTTPMethod.GET,
  );

  Future<List<ItemPrice>> getData(String league, PriceInfoCategories category) async {
    List<ItemPrice> prices = List.empty(growable: true);
    dynamic jsonData = await endpoint.getJSON(
      urlReplacements: {
        "endpoint": category.endpoint,
        "league": league,
        "category": category.urlReplacement,
      },
    );

    var items = <String,dynamic>{};
    if (jsonData != null && jsonData["items"] != null) {
      for(Map<String,dynamic> data in jsonData["items"]) {
        items[data["id"]] = data;
      }
    }

    if (jsonData != null && jsonData["lines"] != null) {
      for(var line in jsonData["lines"]) {
        if(items.containsKey(line["id"])) {
          line["name"] = items[line["id"]]!["name"];
        }
      }
      prices = jsonData["lines"].map<ItemPrice>((dynamic league) => ItemPrice.fromJSON(league)).toList();
    }

    return prices;
  }
}
