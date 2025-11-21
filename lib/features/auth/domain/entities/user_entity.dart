class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final String? coverImage;
  final String? bio;
  final List<String> friends;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isOnline;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    this.coverImage,
    this.bio,
    this.friends = const [],
    required this.createdAt,
    this.lastSeen,
    this.isOnline = false,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    String? coverImage,
    String? bio,
    List<String>? friends,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      bio: bio ?? this.bio,
      friends: friends ?? this.friends,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
