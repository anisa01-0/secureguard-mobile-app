/// A trusted person who is notified when the user raises an alert.
class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String relationship;
  final String phone;

  /// The primary contact is contacted first during an emergency.
  final bool isPrimary;

  String get initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  EmergencyContact copyWith({
    String? name,
    String? relationship,
    String? phone,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'relationship': relationship,
    'phone': phone,
    'isPrimary': isPrimary,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        relationship: json['relationship'] as String,
        phone: json['phone'] as String,
        isPrimary: json['isPrimary'] as bool? ?? false,
      );

  /// Relationship options offered in the add/edit contact form.
  static const List<String> relationshipOptions = <String>[
    'Mother',
    'Father',
    'Sister',
    'Brother',
    'Spouse',
    'Relative',
    'Friend',
    'Roommate',
    'Neighbour',
    'Colleague',
    'Other',
  ];
}
