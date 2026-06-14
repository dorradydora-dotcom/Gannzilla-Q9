import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _webClientId =
      '446326650773-v335rpd56iflvrrk0n1ukd3t64mnf54d.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _currentUser;
  bool _isSubscribed = false;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isSubscribed => _isSubscribed;

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

    if (_currentUser != null) {
      _fetchSubscriptionStatus(_currentUser!.id);
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _currentUser = session.user;
        _status = AuthStatus.authenticated;
        _fetchSubscriptionStatus(_currentUser!.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        _isSubscribed = false;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchSubscriptionStatus(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select('is_subscribed')
          .eq('id', userId)
          .maybeSingle();
      _isSubscribed = (data?['is_subscribed'] as bool?) ?? false;
    } catch (_) {
      _isSubscribed = false;
    }
    notifyListeners();
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
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user != null) {
        try {
          await _supabase.from('users').upsert({
            'id': user.id,
            'email': user.email,
          });
        } catch (e) {
          debugPrint('Failed to upsert user in public.users: $e');
        }
      }

      // auth state listener سيتولى تحديث الـ status
      return true;
    } on PlatformException catch (e) {
      debugPrint('Google Sign In PlatformException: ${e.code}, ${e.message}');
      if (e.code == 'sign_in_failed' && e.message?.contains('10') == true) {
        _setError(
            'خطأ في إعدادات التطبيق (ApiException 10). تأكد من مطابقة SHA-1 في Firebase والـ Client ID.');
      } else {
        _setError(e.message ?? 'فشل تسجيل الدخول مع Google');
      }
      return false;
    } catch (e) {
      debugPrint('Google Sign In error: $e');
      _setError('Error data !!');
      return false;
    }
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _currentUser = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _setIdle();
      return false;
    } on AuthException catch (e) {
      debugPrint('Email Sign In error: $e');
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('Email Sign In error: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    }
  }

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور والاسم الكامل
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (response.user != null) {
        _currentUser = response.user;
        if (response.session != null) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
          _errorMessage = 'يرجى مراجعة بريدك الإلكتروني لتأكيد الحساب';
        }
        notifyListeners();
        return true;
      }
      _setIdle();
      return false;
    } on AuthException catch (e) {
      debugPrint('Email Sign Up error: $e');
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('Email Sign Up error: $e');
      _setError('حدث خطأ غير متوقع');
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
