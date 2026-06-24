class UserProfile {
  String id;
  String name;
  int age;
  String parentName;
  String? profilePicture;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.parentName,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'parentName': parentName,
      'profilePicture': profilePicture,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      parentName: json['parentName'],
      profilePicture: json['profilePicture'] ?? json['profile_picture'], // handle both cases
    );
  }
}
