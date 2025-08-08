import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hurricane_watch/providers/weather_provider.dart';
import 'package:hurricane_watch/providers/news_provider.dart';
import 'package:hurricane_watch/providers/checklist_provider.dart';
import 'package:hurricane_watch/screens/main_screen.dart';
import 'package:hurricane_watch/utils/theme.dart';
import 'package:hurricane_watch/utils/cayman_map_cache.dart';
import 'package:hurricane_watch/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HurricaneWatchApp());

  // Run best-effort background tasks after first frame to avoid init races
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Prefetch Cayman tiles lightly (non-blocking)
    CaymanTilePrefetch.prefetchOnce();
    // Initialize local notifications (non-blocking)
    NotificationService().init();
  });
}

class HurricaneWatchApp extends StatelessWidget {
  const HurricaneWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
      ],
      child: MaterialApp(
        title: 'Cayman Hurricane Watch',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
