import 'package:flutter/services.dart';
import 'dart:convert';

void main() async {
  try {
    final String envString = await rootBundle.loadString('env.json');
    final Map<String, dynamic> envData = json.decode(envString);
    print('Successfully loaded env.json');
    print('URL: ${envData['SUPABASE_URL']}');
    print('Key: ${envData['SUPABASE_ANON_KEY']?.isNotEmpty == true ? 'Present' : 'Missing'}');
  } catch (e) {
    print('Error loading env.json: $e');
  }
}
