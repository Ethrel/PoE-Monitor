import 'dart:async';
import 'dart:collection';
import 'package:complete_timer/complete_timer.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart'; // Required for .firstWhereOrNull() extension method

import 'package:poe_monitor/API/path_of_exile/endpoints.dart' as ggg_endpoints;
import 'package:poe_monitor/API/poe_ninja/endpoints.dart' as poe_ninja_endpoints;
import 'package:poe_monitor/models/PoEAPI/stash_item.dart';
import 'package:poe_monitor/settings.dart';

import 'package:poe_monitor/models/PoEAPI/account_profile.dart';
import 'package:poe_monitor/models/PoEAPI/item_category.dart';
import 'package:poe_monitor/models/PoEAPI/item_info.dart';
import 'package:poe_monitor/models/PoEAPI/league.dart';
import 'package:poe_monitor/models/PoEAPI/stash_tab.dart';
import 'package:poe_monitor/models/poe_ninja/item_price.dart';

class APIData {
  APIData._create();

  static APIData? _singleton;

  static Future<APIData> getInstance() async {
    if (_singleton == null) {
      _singleton = APIData._create();
      _singleton?._initialize();
    }
    return _singleton!;
  }

  Future _initialize() async {
    Future<void> staticData = _updateStaticData();

    _settings = await Settings.getInstance();
    sessionID.value = _settings.sessionID;

    if (sessionID.value.isNotEmpty) {
      Future leaguesAndProfile = Future.wait([
        _updateLeagues(),
        _updateProfile(),
      ]);
      await leaguesAndProfile;
      activeLeague.value = findLeagueByID(_settings.activeLeague) ?? leagues.value.first;

      await staticData;
      /*
      List<String> categories = _settings.pricedCategories;
      for (String catID in categories) {
        ItemCategory? category = findItemCategoryByID(catID);
        if (category == null) continue;
        watchedCategories.value.add(category);
      }*/

      if (activeLeague.value != null && profile.value != null) {
        Future tabsAndPricing = Future.wait([
          _updateTabsList(),
          _updatePriceInfo(),
        ]);
        await tabsAndPricing;
        _processQueue.addAll(stashTabs.value);
      }
    }

    await _hookListeners();
    await _setupRepeatable();
    initialized.value = true;
  }

  Future _hookListeners() async {
    sessionID.addListener(_updateProfile);
    sessionID.addListener(_updateLeagues);
    sessionID.addListener(() {
      if (_settings.sessionID != sessionID.value) _settings.sessionID = sessionID.value;
    });

    leagues.addListener(() {
      activeLeague.value = findLeagueByID(activeLeague.value?.id) ?? leagues.value.first;
    });

    activeLeague.addListener(_updateTabsList);
    activeLeague.addListener(_updatePriceInfo);
    activeLeague.addListener(() {
      String leagueid = activeLeague.value?.id ?? "";
      if (_settings.activeLeague != leagueid) _settings.activeLeague = leagueid;
    });

    stashTabs.addListener(() {
      _processQueue.clear();
      _processQueue.addAll(stashTabs.value);

      pricedList.clear();
    });

    watchedCategories.addListener(_refreshWatchedCategories);
    itemCategories.addListener(_refreshWatchedCategories);
  }

  void _refreshWatchedCategories() {
    List<String> watched = List.empty(growable: true);
    for (ItemCategory category in watchedCategories.value) {
      watched.add(category.id);
    }
    _settings.pricedCategories = watched;
  }

  final Queue<StashTab> _processQueue = Queue();
  Future _setupRepeatable() async {
    _scanTabTimer = CompleteTimer(
      duration: const Duration(seconds: 20),
      callback: (_) async {
        if (_processQueue.isEmpty) return;
        StashTab currentTab;
        int count = 0;
        do {
          currentTab = _processQueue.removeFirst();
          _processQueue.add(currentTab);
          if (++count > _processQueue.length) {
            return;
          }
        } while (skipTypes.contains(currentTab.type));
        await _updateTab(currentTab);
      },
      periodic: true,
    );
  }

  final ValueNotifier<bool> initialized = ValueNotifier(false);
  late Settings _settings;
  // ignore: unused_field
  late CompleteTimer _scanTabTimer;

  final ValueNotifier<String> sessionID = ValueNotifier("");

  final ValueNotifier<List<ItemCategory>> itemCategories = ValueNotifier(List.empty());
  ItemCategory? findItemCategoryByID(String? id) => id == null ? null : itemCategories.value.firstWhereOrNull((category) => category.id == id);
  final Map<String, ItemInfo> itemInfo = {};
  final ValueNotifier<Image?> currencyImage = ValueNotifier(null);
  Future<void> _updateStaticData() async {
    ggg_endpoints.APIItemInfo apiItemInfo = await ggg_endpoints.Endpoints.getTradeItemInfo();
    itemCategories.value = apiItemInfo.itemCategoryList;
    for (ItemInfo item in apiItemInfo.itemInfoList) {
      if (item.name == null) continue;
      itemInfo[item.name!] = item;

      if (item.name!.toLowerCase() == "chaos orb" && item.icon != null) {
        currencyImage.value = item.icon!;
      }
    }
  }

  final ValueNotifier<HashSet<ItemCategory>> watchedCategories = ValueNotifier(HashSet());

  final ValueNotifier<List<League>> leagues = ValueNotifier(List.empty());
  League? findLeagueByID(String? id) => id == null ? null : leagues.value.firstWhereOrNull((league) => league.id == id);
  Future<void> _updateLeagues() async => leagues.value = await ggg_endpoints.Endpoints.getLeagues();

  final ValueNotifier<League?> activeLeague = ValueNotifier(null);
  final ValueNotifier<AccountProfile?> profile = ValueNotifier(null);
  Future<void> _updateProfile() async => profile.value = await ggg_endpoints.Endpoints.getProfile(sessionID.value);

  final ValueNotifier<List<StashTab>> stashTabs = ValueNotifier(List.empty());
  final List<StashType> skipTypes = [StashType.Map, StashType.Unique];
  Future<void> _updateTabsList() async {
    if (profile.value == null || activeLeague.value == null) return;
    stashTabs.value = await ggg_endpoints.Endpoints.getStashTabs(sessionID.value, profile.value!.name, activeLeague.value!.id);
  }

  Future<void> _updatePriceInfo() async {
    List<Future<List<ItemPrice>>> prices = List.empty(growable: true);
    for (poe_ninja_endpoints.PriceInfoCategories category in poe_ninja_endpoints.PriceInfoCategories.values) {
      print("${activeLeague.value!.id} | $category");
      prices.add(poe_ninja_endpoints.Endpoints.getPriceInfo(activeLeague.value!.id, category));
    }
    List<List<ItemPrice>> priceLists = await Future.wait(prices);
    for (List<ItemPrice> priceList in priceLists) {
      for (ItemPrice price in priceList) {
        ItemInfo? item = itemInfo[price.name];
        if (item == null) continue;
        item.price = price.price;
      }
    }
  }

  final PricedItemList pricedList = PricedItemList();
  Future<void> _updateTab(StashTab tab) async {
    if (sessionID.value.isEmpty || profile.value == null || activeLeague.value == null) return;
    ggg_endpoints.APIStashContentInfo stash = await ggg_endpoints.Endpoints.getStashContent(sessionID.value, profile.value!.name, activeLeague.value!.id, tab, this);
    if (stash.isErrored) return;
    tab.content.value = stash.items;
    tab.isEmpty = stash.items.isEmpty;
    tab.isErrored = stash.isErrored;
    for (StashItem item in stash.items) {
      ItemInfo? itemData = itemInfo[item.baseType] ?? itemInfo[item.typeLine] ?? itemInfo[item.displayName];
      if (itemData == null) continue;

      item.price = itemData.price;
      pricedList.updateOrAdd(PricedItem(
        name: item.baseType,
        icon: item.icon,
        amount: item.amount,
        pricePerPiece: item.price,
      ));
    }
    pricedList.sort();
  }
}

class PricedItem {
  const PricedItem({
    required this.name,
    required this.icon,
    required this.amount,
    required this.pricePerPiece,
  });

  final String name;
  final Image? icon;
  final int amount;
  final double pricePerPiece;
}

enum PricedItemSortMethod {
  total(
    displayName: "Total",
    sortFunction: PricedItemList._sortByTotal,
  ),
  individual(
    displayName: "Individual",
    sortFunction: PricedItemList._sortByIndividual,
  ),
  ;

  const PricedItemSortMethod({
    required this.displayName,
    required this.sortFunction,
  });
  final String displayName;
  final int Function(PricedItem, PricedItem) sortFunction;

  static PricedItemSortMethod? findByName(String? name) {
    if (name == null) return null;
    for (PricedItemSortMethod method in PricedItemSortMethod.values) {
      if (method.name == name) return method;
    }
    return null;
  }
}

class PricedItemList extends ChangeNotifier {
  PricedItemList() {
    sortMethod.addListener(() {
      sort();
      notifyListeners();
    });
  }
  final List<PricedItem> _items = List.empty(growable: true);
  ValueNotifier<PricedItemSortMethod> sortMethod = ValueNotifier(PricedItemSortMethod.total);

  void updateOrAdd(PricedItem item) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].name == item.name) {
        _items[i] = item;
        return;
      }
    }
    _items.add(item);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void sort() {
    _items.sort(sortMethod.value.sortFunction);
    notifyListeners();
  }

  PricedItem operator [](int index) {
    PricedItem item = _items[index];
    return item;
  }

  int get length => _items.length;

  static int _sortByTotal(PricedItem item1, PricedItem item2) => (item2.amount * item2.pricePerPiece).compareTo(item1.amount * item1.pricePerPiece);
  static int _sortByIndividual(PricedItem item1, PricedItem item2) => item2.pricePerPiece.compareTo(item1.pricePerPiece);
}
