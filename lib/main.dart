import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

const supabaseUrl = 'https://rfjjnlyklozbmqddohky.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmampubHlrbG96Ym1xZGRvaGt5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NDMyMzIsImV4cCI6MjA5NzIxOTIzMn0.s9aAunOy_0wvbs0V8ZkFb9k_IQly4q-nGVQ3Ed-4e7I';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const GestaoPrevApp());
}
