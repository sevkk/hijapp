import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

/// Auth ekranı state'i
enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.idle, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

/// Auth işlemlerini yöneten notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      state = state.copyWith(status: AuthStatus.success);
    } on Exception catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseError(e.toString()),
      );
    }
  }

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(status: AuthStatus.success);
    } on Exception catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseError(e.toString()),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.success);
    } on Exception catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseError(e.toString()),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signInWithGoogle();
      state = state.copyWith(status: AuthStatus.success);
    } on Exception catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseError(e.toString()),
      );
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.idle, errorMessage: null);
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Bu e-posta ile kayıtlı hesap bulunamadı.';
    if (error.contains('wrong-password')) return 'Şifre hatalı.';
    if (error.contains('invalid-credential')) return 'E-posta veya şifre hatalı.';
    if (error.contains('email-already-in-use')) return 'Bu e-posta zaten kullanılıyor.';
    if (error.contains('weak-password')) return 'Şifre en az 6 karakter olmalı.';
    if (error.contains('invalid-email')) return 'Geçersiz e-posta adresi.';
    if (error.contains('too-many-requests')) return 'Çok fazla deneme. Lütfen biraz bekle.';
    if (error.contains('network-request-failed')) return 'İnternet bağlantını kontrol et.';
    return 'Bir hata oluştu. Tekrar dene.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
