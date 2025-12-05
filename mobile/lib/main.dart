import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/biometric_auth_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'providers/loan_provider.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize local database
  await DatabaseService.instance.initialize();
  
  // Initialize notifications
  await NotificationService.instance.initialize();
  
  runApp(const LendLedgerApp());
}

class LendLedgerApp extends StatelessWidget {
  const LendLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
      ],
      child: MaterialApp(
        title: 'LendLedger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2196F3), // Blue for Cash
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            secondary: const Color(0xFF4CAF50), // Green for Bank
            error: const Color(0xFFFF5722), // Red for Overdue
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthenticationWrapper(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/auth': (context) => const BiometricAuthScreen(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const BiometricAuthScreen();
        }
      },
    );
  }
}
