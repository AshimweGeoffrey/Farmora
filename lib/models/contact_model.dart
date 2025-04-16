class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? photoPath;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoPath': photoPath,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      photoPath: json['photoPath'],
    );
  }
}
