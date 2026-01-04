class AppUser {
  final String uid;
  final String name;
  final bool online;

  AppUser({
    required this.uid,
    required this.name,
    required this.online,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, String uid) {
    return AppUser(
      uid: uid,
      name: json['name'] ?? '',
      online: json['online'] ?? false,
    );
  }
}
