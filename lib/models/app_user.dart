/// The signed-in SecureGuard user.
///
/// SecureGuard deliberately stores only the minimum information needed to
/// raise an emergency alert: a name, an email address and a phone number.
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.bloodGroup = 'Not set',
    this.address = 'Not set',
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String bloodGroup;
  final String address;

  /// Initials shown in the avatar, e.g. "Anisa Abdi" -> "AA".
  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// First name only, used for the dashboard greeting.
  String get firstName {
    final String trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? bloodGroup,
    String? address,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'bloodGroup': bloodGroup,
    'address': address,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    bloodGroup: json['bloodGroup'] as String? ?? 'Not set',
    address: json['address'] as String? ?? 'Not set',
  );
}
