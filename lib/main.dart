import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/post/presentation/providers/post_provider.dart';
import 'features/friend/presentation/providers/friend_provider.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/notification/presentation/providers/notification_provider.dart';
import 'features/story/presentation/providers/story_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          return MaterialApp.router(
            title: 'Facebook Clone',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.createRouter(authProvider),
          );
        },
      ),
    );
  }
}
