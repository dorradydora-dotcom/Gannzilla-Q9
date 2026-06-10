import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
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
        final currentDeviceId = await _getDeviceId();

        try {
          final userData = await _supabase
              .from('users')
              .select('current_device_id')
              .eq('id', response.user!.id)
              .maybeSingle();

          if (userData != null) {
            final activeDeviceId = userData['current_device_id'] as String?;
            if (activeDeviceId != null &&
                activeDeviceId.isNotEmpty &&
                activeDeviceId != currentDeviceId) {
              await _supabase.auth.signOut();
              _setError(
                  'This account is already logged in on another device. Please log out there first.');
              return false;
            }
          }

          await _supabase.from('users').update({
            'current_device_id': currentDeviceId,
          }).eq('id', response.user!.id);
        } catch (e) {
          debugPrint('Failed to verify device ID: $e');
        }

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
  }) async {
    _setLoading();
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        String? fcmToken;
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
        } catch (e) {
          debugPrint('Failed to get FCM token: $e');
        }

        final currentDeviceId = await _getDeviceId();

        try {
          await _supabase.from('users').insert({
            'id': response.user!.id,
            'email': email.trim(),
            'fcm_token': fcmToken,
            'current_device_id': currentDeviceId,
          });
        } catch (e) {
          debugPrint('Failed to insert user to Supabase: $e');
        }

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

  /// Sign out
  Future<void> signOut() async {
    if (_currentUser != null) {
      try {
        await _supabase.from('users').update({
          'current_device_id': null,
        }).eq('id', _currentUser!.id);
      } catch (e) {
        debugPrint('Failed to clear device ID: $e');
      }
    }
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
