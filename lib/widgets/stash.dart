import 'package:flutter/material.dart';
import 'package:poe_monitor/API/api_data.dart';
import 'package:poe_monitor/models/PoEAPI/stash_item.dart';
import 'package:poe_monitor/models/PoEAPI/stash_tab.dart';

// ignore: must_be_immutable
class Stash extends StatelessWidget {
  Stash({super.key});

  Future<APIData> futureAPIData = APIData.getInstance();
  late APIData apiData;

  List<Widget> _buildContents(List<StashTab> tabs) {
    List<Widget> contentDisplays = List.empty(growable: true);
    for (StashTab entry in tabs) {
      contentDisplays.add(ValueListenableBuilder(
          valueListenable: entry.content,
          builder: (BuildContext context, List<StashItem> value, Widget? childWidget) {
            if (value.isEmpty) {
              if (apiData.skipTypes.contains(entry.type)) {
                return Text("The Path of Exile API currently does not support exporting data of ${entry.type.name} tabs.");
              }
              if (entry.isEmpty) {
                return Text("Stash tab ${entry.name} is empty.");
              }
              if (entry.isErrored) {
                return Text("Stash tab ${entry.name} has encountered an error.");
              }
              return Text("Stash tab ${entry.name} has not yet been scanned.");
            } else {
              const Icon unknownIcon = Icon(Icons.question_mark);
              List<Widget> children = List.empty(growable: true);
              for (StashItem item in value) {
                if (item.icon != null) {
                  children.add(Card(
                      child: Center(
                        child: Column(children: [
                    FractionallySizedBox(widthFactor: 1/*, heightFactor: 0.5*/,  child: item.icon!),
                    Text(item.amount.toString()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${(item.price * item.amount).round()}"),
                        SizedBox(width: 20, height: 20, child: apiData.currencyImage.value ?? unknownIcon)
                      ]
                    ),
                  ]))));
                } else {
                  children.add(Card(child: Text("${item.amount} ${item.baseType} worth ${(item.price * item.amount).round()}c")));
                }
              }
              return GridView.extent(
                maxCrossAxisExtent: 100,
                childAspectRatio: 0.65,
                children: children,
              );
            }
          }));
    }
    return contentDisplays;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<APIData>(
        future: futureAPIData,
        builder: (BuildContext context, AsyncSnapshot<APIData> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ValueListenableBuilder(
              valueListenable: snapshot.data!.stashTabs,
              builder: (BuildContext context, List<StashTab> tabs, Widget? childWidget) {
                if (tabs.isEmpty) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Text("No stash tab data for ${snapshot.data!.activeLeague.value?.id} league on realm ${snapshot.data!.activeLeague.value?.realm.name}"),
                  );
                } else {
                  apiData = snapshot.data!;
                  return DefaultTabController(
                      length: tabs.length,
                      child: Scaffold(
                        appBar: TabBar(isScrollable: true, tabs: [
                          for (StashTab entry in tabs)
                            Tab(
                              text: entry.name,
                            )
                        ]),
                        body: TabBarView(
                          children: _buildContents(tabs),
                        ),
                      ));
                }
              },
            );
          }
        });
  }
}
