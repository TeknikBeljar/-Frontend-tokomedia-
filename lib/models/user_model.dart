class UserModel {
  final String name;
  final String email;
  final int cartCount;
  final int notifCount;
  final int mailCount;
  final String? avatarUrl;

  const UserModel({
    required this.name,
    required this.email,
    this.cartCount = 5,
    this.notifCount = 17,
    this.mailCount = 3,
    this.avatarUrl,
  });
}
