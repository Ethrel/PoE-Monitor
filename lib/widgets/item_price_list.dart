import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poe_monitor/API/api_data.dart';
import 'package:poe_monitor/widgets/item_price_card.dart';
import "../main.dart";

// ignore: must_be_immutable
class ItemPriceList extends StatelessWidget {
  late ThemeData theme;

  ItemPriceList({super.key});

  Widget? _itemBuilder(BuildContext context, int index) {
    PricedItem item = apiData.pricedList[index];
    return ValueListenableBuilder(
      valueListenable: apiData.currencyImage,
      builder: (BuildContext context, Image? currencyImage, Widget? childWidget) {
        return ItemPriceCard(
          icon: item.icon,
          name: item.name,
          amount: item.amount,
          price: item.pricePerPiece,
          height: 100,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return ListenableBuilder(
        listenable: apiData.pricedList,
        builder: (BuildContext context, Widget? childWidget) {
          return ListView.builder(itemCount: min(15, apiData.pricedList.length), itemBuilder: _itemBuilder);
        });
  }
}
