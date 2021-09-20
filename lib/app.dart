import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:namaste/util/const.dart';
import 'package:namaste/util/theme_config.dart';

import 'providers/comments.dart';
import 'providers/follows.dart';
import 'providers/posts.dart';
import 'providers/reactions.dart';
import 'providers/user_notifications.dart';
import 'providers/users.dart';
import 'views/screens/animated_splash_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
        ChangeNotifierProvider.value(
          value: Users(),
        ),
        ChangeNotifierProvider.value(
          value: Posts(),
        ),
        ChangeNotifierProvider.value(
          value: Reactions(),
        ),
        ChangeNotifierProvider.value(
          value: Comments(),
        ),
        ChangeNotifierProvider.value(
          value: Follows(),
        ),
        ChangeNotifierProvider.value(
          value: UserNotifications(),
        ),
        
      ],
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: themeData(ThemeConfig.lightTheme),
      // darkTheme: themeData(ThemeConfig.darkTheme),
      home: AnimatedSplashScreen(),
    ) );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.sourceSansProTextTheme(
        theme.textTheme,
      ),
    );
  }
}
