import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_lead_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/lead_success_screen.dart';
import 'screens/my_leads_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/support_screen.dart';
import 'screens/admin_records_screen.dart';

void main() {
  runApp(const BuildLeadApp());
}

class BuildLeadApp extends StatelessWidget {
  const BuildLeadApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildLead Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/post_lead': (context) => const PostLeadScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/success': (context) => const LeadSuccessScreen(),
        '/my_leads': (context) => const MyLeadsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/support': (context) => const SupportScreen(),
        '/admin_records': (context) => const AdminRecordsScreen(),
      },
    );
  }
}
