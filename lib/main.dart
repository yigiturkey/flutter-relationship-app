import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/training_provider.dart';
import 'providers/game_provider.dart';
import 'providers/podcast_provider.dart';
import 'services/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase başlatma
  // TODO: Add firebase_options.dart for production deployment
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(context.read<AuthProvider>()),
          update: (context, auth, _) => UserProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AnalysisProvider>(
          create: (context) => AnalysisProvider(context.read<AuthProvider>()),
          update: (context, auth, _) => AnalysisProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TrainingProvider>(
          create: (context) => TrainingProvider(context.read<AuthProvider>()),
          update: (context, auth, _) => TrainingProvider(auth),
        ),
        Provider<OpenAIService>(create: (_) => OpenAIService()),
        ChangeNotifierProxyProvider2<AuthProvider, OpenAIService, GameProvider>(
          create: (context) => GameProvider(
            context.read<AuthProvider>(),
            context.read<OpenAIService>(),
          ),
          update: (context, auth, openai, previous) => 
              previous ?? GameProvider(auth, openai),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PodcastProvider>(
          create: (context) => PodcastProvider(context.read<AuthProvider>()),
          update: (context, auth, _) => PodcastProvider(auth),
        ),
      ],
      child: const RelationshipApp(),
    ),
  );
}