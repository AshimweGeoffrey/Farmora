class Profile {
  String name;
  String email;
  String phoneNumber;
  String address;
  String? profilePicturePath;

  Profile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.profilePicturePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePicturePath': profilePicturePath,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      profilePicturePath: json['profilePicturePath'],
    );
  }
}
