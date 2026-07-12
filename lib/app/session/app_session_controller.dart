import 'package:flutter/foundation.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';

class AppSessionController extends ChangeNotifier {
  AuthenticatedUser? _currentUser;
  bool _isAuthenticated = false;
  String _currentSection = 'dashboard';

  AuthenticatedUser? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String get currentSection => _currentSection;

  void authenticate(AuthenticatedUser user) {
    _currentUser = user;
    _isAuthenticated = true;
    _currentSection = 'dashboard';
    notifyListeners();
  }

  void selectSection(String section) {
    if (_currentSection != section) {
      _currentSection = section;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _currentSection = 'dashboard';
    notifyListeners();
  }
}
