import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core import kiya gaya hai
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_lead_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/lead_success_screen.dart';
import 'screens/my_leads_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/support_screen.dart';
import 'screens/admin_records_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization with project configuration keys
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCj5ecFqw0yLiBY3Qf54jcfZPbEAK2u7GI",
      appId: "1:512564352355:web:03e3991ea198ce1dc0ef56",
      messagingSenderId: "512564352355",
      projectId: "build-lead-market",
      authDomain: "build-lead-market.firebaseapp.com",
      storageBucket: "build-lead-market.firebasestorage.app", // Updated storage bucket
      measurementId: "G-T9JSM35Q2B",
    ),
  );

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