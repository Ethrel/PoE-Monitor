import "package:poe_monitor/models/PoEAPI/realm.dart";

class AccountProfile {
  AccountProfile({
    required this.uuid,
    required this.name,
    //required this.realm,
    //this.guild,
    this.twitch,
  });

  final String uuid;
  final String name;
  //final LeagueRealm realm;
  //final Guild? guild;
  final Twitch? twitch;

  factory AccountProfile.fromJSON(Map<String, dynamic> profileInfo) =>
      AccountProfile(
        uuid: profileInfo["uuid"],
        name: profileInfo["name"],
        //realm: leagueRealmFromString(profileInfo["realm"]),
        /*
        guild: profileInfo["guild"] == null
            ? null
            : Guild.fromJSON(profileInfo["guild"]),
        */
        twitch: profileInfo["twitch"] == null
            ? null
            : Twitch.fromJSON(profileInfo["twitch"]),
      );
}

class Guild {
  Guild({
    required this.name,
  });

  final String name;

  factory Guild.fromJSON(Map<String, dynamic> guildInfo) =>
      Guild(name: guildInfo["name"]);
}

class Twitch {
  Twitch({
    required this.name,
  });

  final String name;

  factory Twitch.fromJSON(Map<String, dynamic> twitchInfo) =>
      Twitch(name: twitchInfo["name"]);
}
