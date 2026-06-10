import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ Web Client ID من Google Cloud Console
  // اذهب إلى: console.cloud.google.com → APIs & Services → Credentials
  // وانسخ الـ "Client ID" الخاص بـ "Web application"
  static const String _webClientId =
      '446326650773-v335rpd56iflvrrk0n1ukd3t64mnf54d.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthController() {
    _googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
      scopes: ['email', 'profile'],
    );
    _init();
  }

  void _init() {
    _currentUser = _supabase.auth.currentUser;
    _status = _currentUser != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

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

  /// يفتح نافذة اختيار حساب Google داخل التطبيق (بدون متصفح خارجي)
  /// ثم يسجل الدخول عبر Supabase Authentication
  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      // 1. أظهر نافذة اختيار الحساب من Google داخل التطبيق
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // المستخدم أغلق النافذة
        _setIdle();
        return false;
      }

      // 2. احصل على الـ tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        _setError('Error data !!');
        return false;
      }

      // 3. سجّل الدخول في Supabase باستخدام Google tokens
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // auth state listener سيتولى تحديث الـ status
      return true;
    } catch (e) {
      debugPrint('Google Sign In error: $e');
      _setError('Error data !!');
      return false;
    }
  }

  /// تسجيل الخروج
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
    await _googleSignIn.signOut();
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

  void _setIdle() {
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }
}
