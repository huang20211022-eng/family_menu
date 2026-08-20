import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

/// Unified Supabase initialization layer.
///
/// Call once before [runApp]. When [AppConfig.isSupabaseConfigured] is false
/// (no URL / anon key supplied for this build), this is a no-op so the app
/// still runs for UI-only milestones.
///
/// After initialization, the shared client is available anywhere via
/// `Supabase.instance.client`.
Future<void> initSupabase() async {
  if (!AppConfig.isSupabaseConfigured) {
    return;
  }
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );
}
