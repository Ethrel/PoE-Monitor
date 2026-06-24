// ignore: constant_identifier_names
enum LeagueRealm { pc, xbox, sony, UNKNOWN }

LeagueRealm leagueRealmFromString(String league) {
  try {
    return LeagueRealm.values.byName(league);
  } on ArgumentError {
    return LeagueRealm.UNKNOWN;
  }
}
