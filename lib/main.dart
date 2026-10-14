import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_lead_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/my_leads_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_records_screen.dart'; // <-- Yeh import hona chahiye

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildLead Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/post_lead': (context) => const PostLeadScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/my_leads': (context) => const MyLeadsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin_records': (context) => const AdminRecordsScreen(), // <-- Yeh route add hona chahiye
      },
    );
  }
}