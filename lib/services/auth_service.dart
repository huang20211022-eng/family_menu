import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over Supabase Auth.
///
/// Exposes the authentication surface the UI will consume in later
/// milestones. No screen wires into these methods yet — this milestone only
/// establishes the interface.
///
/// These methods require the Supabase client to be initialized (see
/// [initSupabase]); if the app is run without Supabase configured, calling
/// them throws.
class AuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Creates a new account with an email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _auth.signUp(email: email, password: password);
  }

  /// Signs in an existing user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  /// Signs out the current user.
  Future<void> signOut() => _auth.signOut();

  /// The current session, or `null` when signed out.
  Session? get currentSession => _auth.currentSession;

  /// Sends a password-reset email for [email].
  Future<void> resetPassword(String email) =>
      _auth.resetPasswordForEmail(email);
}
