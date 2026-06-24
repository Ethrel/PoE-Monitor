import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:poe_monitor/models/PoEAPI/item_category.dart';
import 'package:poe_monitor/main.dart';

// ignore: must_be_immutable
class ConfigDrawer extends StatelessWidget {
  const ConfigDrawer({super.key});

  Widget _buildCategoryChecklist(BuildContext context, List<ItemCategory> categories, Widget? childWidget) {
    List<Widget> children = List.empty(growable: true);
    for (ItemCategory category in categories) {
      children.add(Row(
        children: [
          ValueListenableBuilder(
              valueListenable: apiData.watchedCategories,
              builder: (BuildContext context, HashSet<ItemCategory> watched, Widget? childWidget) {
                return Checkbox(
                    value: watched.contains(category),
                    onChanged: (bool? set) {
                      if (set == null) return;

                      if (set) {
                        apiData.watchedCategories.value.add(category);
                      } else {
                        apiData.watchedCategories.value.remove(category);
                      }
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      apiData.watchedCategories.notifyListeners();
                    });
              }),
          Text(category.name),
        ],
      ));
    }
    return Column(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        /*const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
              /*image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/cover.jpg'),
              ),*/
            ),
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),*/
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
        ),
        ListTile(
          title: const Center(
            child: Text("PoE Session ID"),
          ),
          subtitle: TextFormField(
            onChanged: (String newValue) {
              if (newValue.length >= 32) apiData.sessionID.value = newValue;
            },
            initialValue: apiData.sessionID.value,
          ),
          onTap: () => {},
        ),
        ListTile(
          title: ValueListenableBuilder(
            valueListenable: apiData.itemCategories,
            builder: _buildCategoryChecklist,
          ),
        ),
      ]),
    );
  }
}
