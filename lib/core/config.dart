/// Application configuration.
///
/// Environment-specific values are supplied **at build time** via
/// `--dart-define` and read through [String.fromEnvironment]. Nothing is
/// hard-coded into source, so the same code can be built for different
/// environments (local dev, CI, release) without edits.
///
/// Example:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
/// ```
///
/// ## Public vs. secret credentials
///
/// The **Supabase project URL** and the **publishable key** (also called the
/// anon/public key) are non-privileged credentials that are safe to ship in
/// the client — they are the only two Supabase values the app ever receives.
///
/// **Secrets** (the service-role key, the database password, the JWT secret,
/// etc.) are privileged and must **never** be passed via `--dart-define`,
/// written into Flutter source, or committed to Git. They live server-side
/// (e.g. in Supabase project settings or Cloudflare Worker secrets).
class AppConfig {
  AppConfig._();

  /// Supabase project URL (public), e.g. `https://<ref>.supabase.co`.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase **publishable** key (the anon/public key).
  ///
  /// This is the key intended for client applications. It is NOT a secret;
  /// see the class-level docs for the public/secret distinction.
  static const String supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Whether Supabase is configured for this build.
  ///
  /// When `false` (neither value supplied), the app skips Supabase
  /// initialization so UI-only milestones still run without a backend.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
