import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/clip_provider.dart';
import 'screens/auth_gate.dart';

void main() {
  final apiClient = ApiClient();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ClipProvider(apiClient)),
      ],
      child: const ClipVidApp(),
    ),
  );
}

class ClipVidApp extends StatelessWidget {
  const ClipVidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClipVid — YouTube to Viral Shorts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const AuthGate(),
    );
  }
}
