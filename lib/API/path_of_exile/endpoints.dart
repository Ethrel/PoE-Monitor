import 'package:poe_monitor/API/api_data.dart';
import 'package:poe_monitor/API/endpoint.dart';
import 'package:poe_monitor/models/PoEAPI/account_profile.dart';
import 'package:poe_monitor/models/PoEAPI/character.dart';
import 'package:poe_monitor/models/PoEAPI/league.dart';
import 'package:poe_monitor/models/PoEAPI/stash_item.dart';
import 'package:poe_monitor/models/PoEAPI/stash_layout.dart';
import 'package:poe_monitor/models/PoEAPI/stash_tab.dart';
import 'package:poe_monitor/models/PoEAPI/item_info.dart';
import 'package:poe_monitor/models/PoEAPI/item_category.dart';
/*
{
      "cookie": "POESESSID=${poeData.sessionID.value}",
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36",
      "accept": "text/html, application/json",
    }
    */

class Endpoints {
  static Future<List<League>> getLeagues() => _LeaguesEndpoint().getData();
  static Future<AccountProfile?> getProfile(String sessionID) => _ProfileEndpoint().getData(sessionID);
  static Future<List<Character>> getCharacters(String sessionID, String accountName) => _CharactersEndpoint().getData(sessionID, accountName);
  static Future<List<StashTab>> getStashTabs(String sessionID, String accountName, String leagueName) => _StashTabListEndpoint().getData(sessionID, accountName, leagueName);
  static Future<APIStashContentInfo> getStashContent(String sessionID, String accountName, String leagueName, StashTab stashTab, APIData api) => _StashContentEndpoint().getData(sessionID, accountName, leagueName, stashTab, api);
  static Future<APIItemInfo> getTradeItemInfo() => _ItemInfo().getData();
  static var getTradeIteInfo = _ItemInfo().getData;
}

class APIItemInfo {
  APIItemInfo({
    required this.itemInfoList,
    required this.itemCategoryList,
  });

  final List<ItemInfo> itemInfoList;
  final List<ItemCategory> itemCategoryList;
}

class APIStashContentInfo {
  APIStashContentInfo({
    required this.layout,
    required this.items,
    required this.isErrored,
  });

  final StashLayout? layout;
  final List<StashItem> items;
  final bool isErrored;
}

class _LeaguesEndpoint {
  Endpoint endpoint = Endpoint(
    urlString: "https://api.pathofexile.com/leagues",
    httpMethod: HTTPMethod.GET,
  );

  Future<List<League>> getData() async {
    List<League> leagues = List.empty(growable: true);
    dynamic jsonData = await endpoint.getJSON();

    if (jsonData != null) {
      leagues = jsonData.map<League>((dynamic league) => League.fromJSON(league)).toList();
    }
    return leagues;
  }
}

class _ProfileEndpoint {
  Endpoint endpoint = Endpoint(
    urlString: "https://api.pathofexile.com/profile",
    httpMethod: HTTPMethod.GET,
  );

  Future<AccountProfile?> getData(String sessionID) async {
    AccountProfile? profile;
    dynamic jsonData = await endpoint.getJSON(headers: {
      "cookie": "POESESSID=$sessionID",
    });

    if (jsonData != null) {
      profile = AccountProfile.fromJSON(jsonData);
    }

    return profile;
  }
}

class _CharactersEndpoint {
  Endpoint endpoint = Endpoint(
    urlString: "https://pathofexile.com/character-window/get-characters?AccountName=%Account\$",
    httpMethod: HTTPMethod.GET,
  );

  Future<List<Character>> getData(String sessionID, String accountName) async {
    List<Character> characters = List.empty(growable: true);
    dynamic jsonData = await endpoint.getJSON(headers: {
      "cookie": "POESESSID=$sessionID",
    }, urlReplacements: {
      "Account": accountName.replaceAll("#","%23"),
    });

    if (jsonData != null) {
      characters = jsonData.map<Character>((dynamic character) => Character.fromJSON(character)).toList();
    }

    return characters;
  }
}

class _StashTabListEndpoint {
  Endpoint endpoint = Endpoint(
    urlString: "https://www.pathofexile.com/character-window/get-stash-items?league=%League\$&tabs=1&tabIndex=0&accountName=%Account\$",
    httpMethod: HTTPMethod.GET,
  );

  Future<List<StashTab>> getData(String sessionID, String accountName, String leagueName) async {
    List<StashTab> tabs = List.empty(growable: true);
    dynamic jsonData = await endpoint.getJSON(headers: {
      "cookie": "POESESSID=$sessionID",
    }, urlReplacements: {
      "Account": accountName.replaceAll("#","%23"),
      "League": leagueName,
    });

    if (jsonData != null && jsonData["tabs"] != null) {
      tabs = jsonData["tabs"].map<StashTab>((dynamic tabData) => StashTab.fromJSON(tabData)).toList();
    }

    return tabs;
  }
}

class _StashContentEndpoint {
  Endpoint endpoint = Endpoint(
    urlString: "https://www.pathofexile.com/character-window/get-stash-items?league=%League\$&tabIndex=%TabIndex\$&accountName=%Account\$",
    httpMethod: HTTPMethod.GET,
  );

  Future<APIStashContentInfo> getData(String sessionID, String accountName, String leagueName, StashTab stashTab, APIData api) async {
    dynamic jsonData = await endpoint.getJSON(
      headers: {
        "cookie": "POESESSID=$sessionID",
      },
      urlReplacements: {
        "Account": accountName.replaceAll("#","%23"),
        "League": leagueName,
        "TabIndex": stashTab.index.toString(),
      },
      canRetry: false,
    );
    List<StashItem> items = List.empty(growable: true);

    if (jsonData != null) {
      for (dynamic itemInfo in jsonData["items"]) {
        items.add(StashItem.fromJSON(itemInfo, api));
      }
    }

    APIStashContentInfo content = APIStashContentInfo(layout: null, items: items, isErrored: jsonData == null);
    return content;
  }
}

class _ItemInfo {
  Endpoint endpoint = Endpoint(
    urlString: "https://pathofexile.com/api/trade/data/static",
    httpMethod: HTTPMethod.GET,
  );

  Future<APIItemInfo> getData() async {
    List<ItemCategory> categories = List.empty(growable: true);
    List<ItemInfo> items = List.empty(growable: true);
    APIItemInfo returnObject = APIItemInfo(itemInfoList: items, itemCategoryList: categories);
    dynamic jsonData = await endpoint.getJSON();

    if (jsonData != null) {
      for (Map<String, dynamic> cat in jsonData["result"]) {
        ItemCategory category = ItemCategory.fromJSON(cat);
        categories.add(category);
        for (Map<String, dynamic> item in cat["entries"]) {
          items.add(ItemInfo.fromJSON(category, item));
        }
      }
    }

    return returnObject;
  }
}
