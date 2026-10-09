import 'package:flutter/material.dart';
import 'pages/registration_page.dart';
import 'pages/user_info_page.dart';
import 'services/user_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RegistrationApp());
}

class RegistrationApp extends StatelessWidget {
  const RegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF4267B2);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registration Form',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: const Color(0xFFF7F8FC),
        ),
      ),
      home: const StartupPage(),
    );
  }
}

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRecord?>(
      future: UserStorage.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return const UserInfoPage();
        }

        return const RegistrationPage();
      },
    );
  }
}
