import 'package:flutter/material.dart';

import 'package:poe_monitor/API/api_data.dart';
import 'package:poe_monitor/models/PoEAPI/account_profile.dart';
import 'package:poe_monitor/widgets/config_drawer.dart';
import 'package:poe_monitor/widgets/league_select.dart';
import 'package:poe_monitor/widgets/item_price_list.dart';
import 'package:poe_monitor/widgets/price_list_sort_select.dart';
import 'package:poe_monitor/widgets/stash.dart';

late APIData apiData;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  apiData = await APIData.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoE monitor',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'PoE monitor home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: apiData.initialized,
        builder: (BuildContext context, bool initialized, Widget? childWidget) {
          return Scaffold(
              backgroundColor: Theme.of(context).canvasColor,
              endDrawer: const ConfigDrawer(),
              appBar: AppBar(
                title: ValueListenableBuilder(
                    valueListenable: apiData.profile,
                    builder: (BuildContext context, AccountProfile? profile, Widget? childWidget) {
                      return Text("PoE Monitor - ${profile == null ? "Unknown" : profile.name}");
                    }),
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                    ),
                  ),
                ],
              ),
              body: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Row(children: [
                        SizedBox(width: 250, child: PriceListSortSelector()),
                        Expanded(child: Padding(padding: EdgeInsets.all(5.0), child: Align(alignment: Alignment.centerRight, child: LeagueSelector()))),
                      ]),
                      Flexible(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 250,
                            child: ItemPriceList(),
                          ),
                          Expanded(child: Stash()),
                        ],
                      )),
                    ],
                  )));
        });
  }
}
