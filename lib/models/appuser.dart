class AppUser {
  final String uid;
  final String name;
  final String mail;
  final String role;

  AppUser({
    required this.uid,
    required this.name,
    required this.mail,
    required this.role,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'mail': mail,
      'role': role,
    };
  }

  
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      mail: map['mail'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
