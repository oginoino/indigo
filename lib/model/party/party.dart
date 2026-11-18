enum PartyType { person, organization }

class Party {
  const Party({required this.id, required this.type, required this.createdAt});

  final String id;
  final PartyType type;
  final DateTime createdAt;
}
