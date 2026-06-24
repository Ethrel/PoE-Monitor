class Character {
  Character({
    required this.name,
    required this.league,
    required this.classID,
    required this.ascendancyID,
    required this.characterClass,
    required this.level,
    required this.experience,
    required this.lastActive,
  });

  final String name;
  final String league;
  final int classID;
  final int ascendancyID;
  final String characterClass;
  final int level;
  final int experience;
  final bool lastActive;

  factory Character.fromJSON(Map<String, dynamic> charData) => Character(
        name: charData["name"],
        league: charData["league"],
        classID: charData["classId"],
        ascendancyID: charData["ascendancyClass"],
        characterClass: charData["class"],
        level: charData["level"],
        experience: charData["experience"],
        lastActive: charData["lastActive"] ?? false,
      );
}
