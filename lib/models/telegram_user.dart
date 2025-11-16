class TelegramUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String photoUrl;
  final String languageCode;

  TelegramUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.languageCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'language_code': languageCode,
    };
  }
}
