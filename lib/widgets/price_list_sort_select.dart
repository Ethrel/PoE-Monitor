import 'package:flutter/material.dart';
import 'package:poe_monitor/API/api_data.dart';
import 'package:poe_monitor/main.dart';

class PriceListSortSelector extends StatefulWidget {
  const PriceListSortSelector({super.key});

  @override
  State<StatefulWidget> createState() => PriceListSortSelectorData();
}

class PriceListSortSelectorData extends State<PriceListSortSelector> {
  List<DropdownMenuItem<String>> items = List.empty();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: apiData.pricedList,
        builder: (BuildContext context, Widget? childWidget) {
          return DropdownButton<String>(
            value: apiData.pricedList.sortMethod.value.name,
            isExpanded: true,
            onChanged: (String? newSortMethod) {
              apiData.pricedList.sortMethod.value = PricedItemSortMethod.findByName(newSortMethod) ?? PricedItemSortMethod.values.first;
            },
            items: PricedItemSortMethod.values.map<DropdownMenuItem<String>>(
              (var value) {
                return DropdownMenuItem<String>(
                  value: value.name,
                  child: Center(child: Text(value.displayName)),
                );
              },
            ).toList(),
          );
        });
  }
}
