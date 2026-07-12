import 'package:flutter/foundation.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';

class AppSessionController extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthenticatedUser? _currentUser;
  bool _isAuthenticated = false;
  String _currentSection = 'dashboard';

  AppSessionController({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _initSessionListener();
  }

  void _initSessionListener() {
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;

        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.initialSession) {
          if (_currentUser == null && data.session != null) {
            final user = await _authRepository.restoreSession();
            if (user != null) {
              authenticate(user);
            }
          }
        } else if (event == AuthChangeEvent.signedOut) {
          logout();
        }
      });
    } catch (e) {
      // Ignore for tests where Supabase is not initialized
    }
  }

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
