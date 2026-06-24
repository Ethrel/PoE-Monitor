import 'package:flutter/material.dart';
import 'package:poe_monitor/models/PoEAPI/league.dart';
import 'package:poe_monitor/main.dart';

class LeagueSelector extends StatefulWidget {
  const LeagueSelector({super.key});

  @override
  State<StatefulWidget> createState() => LeagueSelectorData();
}

class LeagueSelectorData extends State<LeagueSelector> {
  List<DropdownMenuItem<String>> items = List.empty();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: apiData.leagues,
        builder: (BuildContext context, List<League> leagueList, Widget? childWidget) {
          return ValueListenableBuilder(
              valueListenable: apiData.activeLeague,
              builder: (BuildContext context, League? league, Widget? childWidget) {
                return DropdownButton<String>(
                  value: league?.id,
                  onChanged: (String? newLeague) {
                    apiData.activeLeague.value = apiData.findLeagueByID(newLeague);
                  },
                  items: leagueList.map<DropdownMenuItem<String>>(
                    (League value) {
                      return DropdownMenuItem<String>(
                        value: value.id,
                        child: Text(value.id),
                      );
                    },
                  ).toList(),
                );
              });
        });
  }
}
