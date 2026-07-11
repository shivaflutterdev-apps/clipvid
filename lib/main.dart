import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/clip_provider.dart';
import 'blocs/theme_bloc/theme_bloc.dart';
import 'blocs/theme_bloc/theme_state.dart';
import 'screens/auth_gate.dart';

void main() {
  final apiClient = ApiClient();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ClipProvider(apiClient)),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
      ],
      child: const ClipVidApp(),
    ),
  );
}

class ClipVidApp extends StatelessWidget {
  const ClipVidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'ClipVid — YouTube to Viral Shorts',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(state.colors),
          themeMode: state.themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}
