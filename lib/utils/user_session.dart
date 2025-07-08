class UserSession {
  static int? userId;
  static String? username;
  static String? email;
  static bool isPremium = false;

  static void setUser({
    required int id,
    required String name,
    required String mail,
    required bool isPremium,
  }) {
    userId = id;
    username = name;
    email = mail;
    UserSession.isPremium = isPremium;
  }

  static void clear() {
    userId = null;
    username = null;
    email = null;
    isPremium = false;
  }
}