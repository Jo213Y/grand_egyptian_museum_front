import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/halls_screen.dart';
import 'screens/booking_screen.dart';

void main() {
  runApp(const GrandEgyptianMuseumApp());
}

class GrandEgyptianMuseumApp extends StatelessWidget {
  const GrandEgyptianMuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grand Egyptian Museum',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/signin',
      routes: {
        '/signin': (_) => const SignInScreen(),
        '/home': (_) => const HomeScreen(),
        '/halls': (_) => const HallsScreen(),
        '/booking': (_) => const BookingScreen(),
      },
    );
  }
}