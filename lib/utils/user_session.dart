import 'app_session.dart';

class UserSession {
  static int? userId;
  static String? username;
  static String? email;
  static bool isPremium = false;

  static var instance = UserSession();

  static bool get isLoggedIn => userId != null;
  static List<int> purchasedSongs = [];

  static bool hasPurchased(int songId) {
    return purchasedSongs.contains(songId);
  }

  static void addPurchase(int songId) {
    if (!hasPurchased(songId)) {
      purchasedSongs.add(songId);
    }
  }

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
    AppSession.login();
  }

  static void clear() {
    userId = null;
    username = null;
    email = null;
    isPremium = false;
    AppSession.enterAsGuest();
  }
}