import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load các biến môi trường từ file .env
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Route names
  static const String welcomeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/signup';
  static const String verificationRoute = '/verify';
  static const String homeRoute = '/home';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Try-On',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: welcomeRoute,
      routes: {
        welcomeRoute: (_) => const WelcomeScreen(),
        loginRoute: (_) => const LoginScreen(),
        registerRoute: (_) => const RegisterScreen(),
        homeRoute: (_) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == verificationRoute) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => VerificationScreen(
              userId: args['userId'],
              email: args['email'],
            ),
          );
        }
        return null;
      },
    );
  }
}