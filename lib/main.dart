import 'package:flutter/material.dart';

import 'app.dart';
import 'services/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const FamilyMenuApp());
}
