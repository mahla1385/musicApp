class AppSession {
  static bool _isGuest = false;

  static bool get isGuest => _isGuest;

  static void enterAsGuest() {
    _isGuest = true;
  }

  static void login() {
    _isGuest = false;
  }

  static void logout() {
    _isGuest = false;
  }
}