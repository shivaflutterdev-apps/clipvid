import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'providers/clip_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ClipVidApp());
}

class ClipVidApp extends StatelessWidget {
  const ClipVidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClipProvider(ApiClient()),
      child: MaterialApp(
        title: 'ClipVid — YouTube to Viral Shorts',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
