import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthController() {
    _init();
  }

  void _init() {
    _currentUser = _supabase.auth.currentUser;
    _status = _currentUser != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _currentUser = session.user;
        _status = AuthStatus.authenticated;
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _setError('Login failed, please check your credentials');
      return false;
    } on AuthException catch (e) {
      _setError(_translateAuthError(e.message));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred, please try again');
      return false;
    }
  }

  /// Create new account
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading();
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        _currentUser = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _setError('Account creation failed, please try again');
      return false;
    } on AuthException catch (e) {
      _setError(_translateAuthError(e.message));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred, please try again');
      return false;
    }
  }

  /// Send password reset link
  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(_translateAuthError(e.message));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }

  String _translateAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (message.contains('Email not confirmed')) {
      return 'Please confirm your email first';
    } else if (message.contains('User already registered')) {
      return 'This email is already registered';
    } else if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long';
    } else if (message.contains('rate limit')) {
      return 'Rate limit exceeded, please wait a moment';
    }
    return message;
  }
}
