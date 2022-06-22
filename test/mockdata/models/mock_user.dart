class MockUser {
  final int id;
  final String email;

  const MockUser({
    required this.id,
    required this.email,
  });

  factory MockUser.fromJson(Map<String, dynamic> json) {
    return MockUser(
      id: json['id'],
      email: json['email'],
    );
  }
}
